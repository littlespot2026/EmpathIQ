// api/gemini.js
// Vercel Serverless Function: Secure Gemini API Proxy

module.exports = async function handler(req, res) {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization'
  );

  // Handle preflight OPTIONS
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    console.error('[Gemini Proxy] Missing GEMINI_API_KEY in environment variables.');
    return res.status(500).json({
      error: 'GEMINI_API_KEY is not configured in Vercel environment variables.'
    });
  }

  // Allow GET to list available models for this key
  if (req.method === 'GET') {
    try {
      const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey.trim()}`);
      const data = await resp.json();
      return res.status(resp.status).json(data);
    } catch (e) {
      return res.status(500).json({ error: e.message });
    }
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Please use POST.' });
  }

  try {
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch (e) {
        return res.status(400).json({ error: 'Malformed JSON request body: ' + e.message });
      }
    } else if (!body && req.readable) {
      const buffers = [];
      for await (const chunk of req) {
        buffers.push(chunk);
      }
      const raw = Buffer.concat(buffers).toString('utf8');
      try {
        body = JSON.parse(raw);
      } catch (e) {
        return res.status(400).json({ error: 'Malformed JSON stream: ' + e.message });
      }
    }
    body = body || {};

    let model = body.model || 'gemini-3.5-flash';
    // Remap deprecated or discontinued model identifiers to active stable models
    if (model.includes('1.5') || model.includes('2.0') || model.includes('2.5')) {
      model = 'gemini-3.5-flash';
    }

    const contents = body.contents;
    const prompt = body.prompt;
    const image = body.image;
    const generationConfig = body.generationConfig || {
      responseMimeType: 'application/json',
      temperature: 0.7
    };

    let payload;
    if (contents && Array.isArray(contents)) {
      if (image && (image.base64Data || image.data) && contents[0] && contents[0].parts) {
        contents[0].parts.unshift({
          inlineData: {
            mimeType: image.mimeType || 'image/jpeg',
            data: image.base64Data || image.data
          }
        });
      }
      payload = { contents, generationConfig };
    } else if (prompt || (image && (image.base64Data || image.data))) {
      const parts = [];
      if (image && (image.base64Data || image.data)) {
        parts.push({
          inlineData: {
            mimeType: image.mimeType || 'image/jpeg',
            data: image.base64Data || image.data
          }
        });
      }
      if (prompt) {
        parts.push({ text: prompt });
      }
      payload = {
        contents: [
          {
            parts
          }
        ],
        generationConfig
      };
    } else {
      return res.status(400).json({ error: 'Request body must contain "contents", "prompt", or "image".' });
    }

    async function callUpstream(modelName) {
      const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey.trim()}`;
      const upstreamResponse = await fetch(geminiEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      const responseText = await upstreamResponse.text();
      let responseData;
      try {
        responseData = JSON.parse(responseText);
      } catch (_) {
        responseData = { rawResponse: responseText };
      }
      return { status: upstreamResponse.status, ok: upstreamResponse.ok, data: responseData };
    }

    let result = await callUpstream(model);

    // If deprecated (404) or high demand (503), automatically attempt fallback
    if (!result.ok && (result.status === 404 || result.status === 503)) {
      const fallbackModel = model === 'gemini-3.5-flash' ? 'gemini-3.5-flash-lite' : 'gemini-3.5-flash';
      console.warn(`[Gemini Proxy] Model ${model} returned status ${result.status}, trying fallback ${fallbackModel}`);
      const fallbackResult = await callUpstream(fallbackModel);
      if (fallbackResult.ok) {
        result = fallbackResult;
      }
    }

    if (!result.ok) {
      console.error('[Gemini Proxy] Upstream API error:', result.status, result.data);
      return res.status(result.status).json(result.data);
    }

    return res.status(200).json(result.data);
  } catch (error) {
    console.error('[Gemini Proxy] Uncaught handler error:', error);
    return res.status(500).json({
      error: 'Internal server error in Gemini proxy',
      message: error.message,
      stack: error.stack
    });
  }
};
