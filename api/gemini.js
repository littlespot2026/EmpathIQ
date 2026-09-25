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

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Please use POST.' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    console.error('[Gemini Proxy] Missing GEMINI_API_KEY in environment variables.');
    return res.status(500).json({
      error: 'GEMINI_API_KEY is not configured in Vercel environment variables.'
    });
  }

  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : (req.body || {});
    const model = body.model || 'gemini-1.5-flash';
    const contents = body.contents;
    const prompt = body.prompt;
    const generationConfig = body.generationConfig || {
      responseMimeType: 'application/json',
      temperature: 0.7
    };

    let payload;
    if (contents) {
      payload = { contents, generationConfig };
    } else if (prompt) {
      payload = {
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ],
        generationConfig
      };
    } else {
      return res.status(400).json({ error: 'Request body must contain "contents" or "prompt".' });
    }

    const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey.trim()}`;

    const upstreamResponse = await fetch(geminiEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const responseData = await upstreamResponse.json();

    if (!upstreamResponse.ok) {
      console.error('[Gemini Proxy] Upstream API error:', upstreamResponse.status, responseData);
      return res.status(upstreamResponse.status).json(responseData);
    }

    return res.status(200).json(responseData);
  } catch (error) {
    console.error('[Gemini Proxy] Uncaught handler error:', error);
    return res.status(500).json({
      error: 'Internal server error in Gemini proxy',
      message: error.message
    });
  }
};
