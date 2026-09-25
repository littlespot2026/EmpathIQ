import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/prompt_constants.dart';
import '../localization/app_locale.dart';
import '../models/app_settings.dart';
import '../models/chat_message.dart';
import '../models/decode_result.dart';
import '../theme/app_colors.dart';

class LLMService {
  static final LLMService instance = LLMService._();
  LLMService._();

  /// Main method to decode subtext with AI, falling back cleanly to smart mock engine
  Future<DecodeResult> decodeSubtext({
    required String inputText,
    required String relationship,
    required AppSettings settings,
  }) async {
    // If user has provided an API key (custom or env) and mock is disabled
    final effectiveKey = settings.effectiveApiKey;
    if (effectiveKey.isNotEmpty && !settings.enableMockSimulation) {
      try {
        final effectiveSettings = settings.copyWith(apiKey: effectiveKey);
        if (settings.provider == 'gemini') {
          return await _callGeminiDecoder(
            inputText: inputText,
            relationship: relationship,
            settings: effectiveSettings,
          );
        } else {
          return await _callOpenAIDecoder(
            inputText: inputText,
            relationship: relationship,
            settings: effectiveSettings,
          );
        }
      } catch (e) {
        debugPrint('[EmpathIQ LLM] Live API failed, falling back to smart engine: $e');
        // Fall back gracefully
      }
    }

    // Smart contextual fallback engine
    await Future.delayed(const Duration(milliseconds: 1100)); // Realistic processing feel
    return _generateContextualMockResult(inputText, relationship);
  }

  /// Call Google Gemini API
  Future<DecodeResult> _callGeminiDecoder({
    required String inputText,
    required String relationship,
    required AppSettings settings,
  }) async {
    final langName = AppLocale.instance.currentLanguage.name;
    final model = settings.modelName.isNotEmpty ? settings.modelName : 'gemini-1.5-flash';
    final url = Uri.parse(
        '${settings.baseUrl}/v1beta/models/$model:generateContent?key=${settings.apiKey.trim()}');

    final prompt = '''
${PromptConstants.systemPrompt}

Language Instruction:
Please output all JSON text content (surface_meaning, real_subtext, core_pain_point, strategy titles, action_text, mechanism, initial_npc_thought, initial_npc_speech) natively and fluently in: $langName.

【Input Context】：
- Relationship Context: $relationship
- Utterance: "$inputText"

Output pure JSON conforming strictly to the schema.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.7,
      }
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('Gemini API Error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response candidates from Gemini');
    }

    final text = candidates[0]['content']['parts'][0]['text'] as String;
    final jsonMap = _extractCleanJson(text);
    return _parseResultFromJson(jsonMap, inputText, relationship);
  }

  /// Call OpenAI-compatible API
  Future<DecodeResult> _callOpenAIDecoder({
    required String inputText,
    required String relationship,
    required AppSettings settings,
  }) async {
    final langName = AppLocale.instance.currentLanguage.name;
    final baseUrl = settings.baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final url = Uri.parse('$baseUrl/chat/completions');

    final messages = [
      {
        'role': 'system',
        'content':
            '${PromptConstants.systemPrompt}\n\nIMPORTANT: Output all field values (real_subtext, core_pain_point, strategies, action_text, mechanism, npc lines) in: $langName.'
      },
      {
        'role': 'user',
        'content':
            'Relationship context: $relationship\nSpeaker said: "$inputText"\nProvide in-depth subtext analysis and 3 breakthrough strategies in $langName, formatted as JSON.'
      }
    ];

    final body = jsonEncode({
      'model': settings.modelName.isNotEmpty ? settings.modelName : 'gpt-4o-mini',
      'messages': messages,
      'response_format': {'type': 'json_object'},
      'temperature': 0.7,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey.trim()}',
      },
      body: body,
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('OpenAI API Error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String;
    final jsonMap = _extractCleanJson(content);
    return _parseResultFromJson(jsonMap, inputText, relationship);
  }

  /// Interactive Sandbox turn generator
  Future<Map<String, dynamic>> generateSandboxTurn({
    required String originalSubtext,
    required String relationship,
    required List<ChatMessage> history,
    required String userReply,
    required int currentDefense,
    required AppSettings settings,
  }) async {
    // If real API configured (custom or env key)
    final effectiveKey = settings.effectiveApiKey;
    if (effectiveKey.isNotEmpty && !settings.enableMockSimulation) {
      try {
        final langName = AppLocale.instance.currentLanguage.name;
        final prompt = '''
${PromptConstants.sandboxFeedbackPrompt}

Language Instruction:
Please output feedback_tag, inner_thought, npc_reply, and coaching_hint fluently in: $langName.

【Scenario Setting】：
- Relationship Context: $relationship
- Initial Trigger Phrase: "$originalSubtext"
- NPC Current Defense/Anger: $currentDefense%

【Conversation History】：
${history.map((m) => '${m.isUser ? "User" : "NPC"}: ${m.content}').join('\n')}
User Reply: "$userReply"

Calculate defense_delta, provide psychological review tag, inner monologue, next NPC response, and coaching hint in $langName. Output strict pure JSON.
''';
        if (settings.provider == 'gemini') {
          final model = settings.modelName.isNotEmpty ? settings.modelName : 'gemini-1.5-flash';
          final url = Uri.parse(
              '${settings.baseUrl}/v1beta/models/$model:generateContent?key=$effectiveKey');
          final resp = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {'responseMimeType': 'application/json'}
            }),
          ).timeout(const Duration(seconds: 15));
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            final txt = data['candidates'][0]['content']['parts'][0]['text'] as String;
            return _extractCleanJson(txt);
          }
        }
      } catch (e) {
        debugPrint('[Sandbox LLM] Fallback to simulator: $e');
      }
    }

    // Dynamic smart simulator based on empathy keywords
    await Future.delayed(const Duration(milliseconds: 900));
    return _simulateSandboxTurn(userReply, currentDefense, relationship);
  }

  Map<String, dynamic> _simulateSandboxTurn(String userReply, int currentDefense, String rel) {
    final lower = userReply.toLowerCase();
    final bool hasEmpathyKeywords = lower.contains('抱歉') ||
        lower.contains('对不起') ||
        lower.contains('感受') ||
        lower.contains('委屈') ||
        lower.contains('理解') ||
        lower.contains('在乎') ||
        lower.contains('陪你') ||
        lower.contains('听你说') ||
        lower.contains('辛苦') ||
        lower.contains('难受') ||
        lower.contains('sorry') ||
        lower.contains('apologize') ||
        lower.contains('understand') ||
        lower.contains('feeling') ||
        lower.contains('heard') ||
        lower.contains('listen') ||
        lower.contains('care') ||
        lower.contains('with you');

    final bool hasTriggerKeywords = lower.contains('你怎么又') ||
        lower.contains('随便') ||
        lower.contains('至于吗') ||
        lower.contains('多大点事') ||
        lower.contains('烦不烦') ||
        lower.contains('无理取闹') ||
        lower.contains('行了行了') ||
        lower.contains('我也没办法') ||
        lower.contains('whatever') ||
        lower.contains('again') ||
        lower.contains('annoying') ||
        lower.contains('overreacting') ||
        lower.contains('not a big deal') ||
        lower.contains('deal with it') ||
        lower.contains('calm down') ||
        lower.contains('always');

    final bool isZh = AppLocale.instance.currentCode == 'zh';

    int delta;
    String feedbackTag;
    String innerThought;
    String npcReply;
    String coachingHint;

    if (hasEmpathyKeywords && !hasTriggerKeywords) {
      delta = -20;
      final newDef = (currentDefense + delta).clamp(10, 100);
      if (isZh) {
        feedbackTag = '【怒气 -20%】精准识别情绪，心防瓦解';
        innerThought = '原来他真的没有敷衍我，他能懂我的不易...';
        if (newDef <= 30) {
          npcReply = '好啦...我刚才也是太着急了，其实我只是想让你多在乎一下我的感受。';
          coachingHint = '💡 对方心防已基本降至安全区，此刻提出共同解决方案最容易达成共识。';
        } else {
          npcReply = '说得好听...不过听你这么讲，我心里确实没刚才那么堵了。那你打算怎么做？';
          coachingHint = '💡 对方正在验证你的诚意，给出具体的行动步骤或时间承诺。';
        }
      } else {
        feedbackTag = '【Tension -20%】Guard disarmed with genuine empathy';
        innerThought = 'They really aren\'t brushing me off; they actually care how I feel...';
        if (newDef <= 30) {
          npcReply = 'Alright... I guess I was being reactive earlier too. I just really wanted to feel like my feelings mattered to you.';
          coachingHint = '💡 Counterpart guard has dropped into the safe zone. Proposing a collaborative solution now is most effective.';
        } else {
          npcReply = 'That sounds nice... Hearing you say that actually helps take the edge off. So what are we going to do about it?';
          coachingHint = '💡 They are testing your sincerity. Offer concrete action steps or a clear timeline.';
        }
      }
      return {
        'defense_delta': delta,
        'new_defense_percent': newDef,
        'feedback_tag': feedbackTag,
        'inner_thought': innerThought,
        'npc_reply': npcReply,
        'coaching_hint': coachingHint,
      };
    } else if (hasTriggerKeywords) {
      delta = 15;
      final newDef = (currentDefense + delta).clamp(0, 100);
      if (isZh) {
        feedbackTag = '【怒气 +15%】触发自恋防御，对抗升级';
        innerThought = '看吧，他根本没有半点耐心，果然是在应付我！';
        npcReply = '行，你永远都是这套说辞！既然你觉得是我无理取闹，那我们也没什么好说的了！';
        coachingHint = '⚠️ 警惕指责性字眼与说教，试着停下来先倾听，承认对方的挫败感。';
      } else {
        feedbackTag = '【Tension +15%】Defensive trigger hit, conflict escalated';
        innerThought = 'See? Zero patience as usual. Completely brushing me off!';
        npcReply = 'Right, it\'s always my fault! If you think I\'m just overreacting, then there\'s nothing left to talk about!';
        coachingHint = '⚠️ Beware of dismissive phrasing or lecturing. Pause, listen, and acknowledge their frustration first.';
      }
      return {
        'defense_delta': delta,
        'new_defense_percent': newDef,
        'feedback_tag': feedbackTag,
        'inner_thought': innerThought,
        'npc_reply': npcReply,
        'coaching_hint': coachingHint,
      };
    } else {
      // Neutral response
      delta = -8;
      final newDef = (currentDefense + delta).clamp(10, 100);
      if (isZh) {
        feedbackTag = '【怒气 -8%】情绪趋于平稳，保持耐心';
        innerThought = '他在试着跟我沟通，但感觉还是有点官方...';
        npcReply = '反正今天这事确实让我挺不痛快的，你先别急着下结论，先听我把话说完。';
        coachingHint = '💡 试着运用复述技术：“你刚才提到...是感觉被忽视了对吗？”深化信任。';
      } else {
        feedbackTag = '【Tension -8%】Emotions steadying, stay patient';
        innerThought = 'They’re trying to communicate, though it still feels a bit formal...';
        npcReply = 'Look, this whole thing really bothered me. Don’t jump to conclusions yet—just hear me out.';
        coachingHint = '💡 Try reflective listening: “You felt overlooked earlier, right?” to deepen rapport.';
      }
      return {
        'defense_delta': delta,
        'new_defense_percent': newDef,
        'feedback_tag': feedbackTag,
        'inner_thought': innerThought,
        'npc_reply': npcReply,
        'coaching_hint': coachingHint,
      };
    }
  }

  Map<String, dynamic> _extractCleanJson(String text) {
    try {
      // Remove any markdown code blocks
      var cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        final firstNewline = cleaned.indexOf('\n');
        if (firstNewline != -1) {
          cleaned = cleaned.substring(firstNewline + 1);
        }
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.length - 3);
        }
        cleaned = cleaned.trim();
      }
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // Find first { and last }
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final substring = text.substring(start, end + 1);
        return jsonDecode(substring) as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  DecodeResult _parseResultFromJson(
      Map<String, dynamic> json, String input, String rel) {
    final temp = (json['temperature'] as num?)?.toInt() ?? 65;
    final level = json['temperature_level'] as String? ??
        (temp <= 30 ? '冷淡蓝' : temp <= 70 ? '焦躁黄' : '易燃红');
    final defense = (json['defense_percent'] as num?)?.toInt() ?? 70;
    final surface = json['surface_meaning'] as String? ?? input;
    final subtext = json['real_subtext'] as String? ?? '渴望被理解与关注，但出于防御心理使用了反向言语包装。';
    final pain = json['core_pain_point'] as String? ?? '担心自己的需求不被重视，缺乏心理安全感。';

    final rawStrategies = json['strategies'] as List<dynamic>? ?? [];
    final List<DecodeStrategy> strategies = [];
    for (final item in rawStrategies) {
      if (item is Map<String, dynamic>) {
        strategies.add(DecodeStrategy.fromMap(item));
      }
    }

    if (strategies.isEmpty) {
      if (AppLocale.instance.currentCode == 'zh') {
        strategies.addAll([
          const DecodeStrategy(
            type: 'empathy',
            title: '稳妥共情牌',
            actionText: '我能感到你现在有些失落。手头的事我先放下，能跟我说说你心里的真实想法吗？',
            mechanism: '通过放下手头事务打破对方的冷漠预期，迅速建立情绪安全港。',
          ),
          const DecodeStrategy(
            type: 'humor',
            title: '幽默破冰牌',
            actionText: '报告！雷达已捕获紧急信号，我哪敢走开，快给我一个为你揉肩泡茶戴罪立功的机会吧~',
            mechanism: '用角色扮演和轻松自嘲化解剑拔弩张的对抗僵局。',
          ),
          const DecodeStrategy(
            type: 'boundary',
            title: '温和界限牌',
            actionText: '我珍惜我们的关系，如果你现在需要独处我尊重你的节奏；当你准备好了我们随时敞开聊聊。',
            mechanism: '既给予空间，又坚定拒绝猜心游戏，确立成熟边界。',
          ),
        ]);
      } else {
        strategies.addAll([
          const DecodeStrategy(
            type: 'empathy',
            title: 'Strategy A · Safe Empathy',
            actionText: 'I can sense you feel hurt right now. Let me set aside what I\'m doing—could you tell me what\'s on your mind?',
            mechanism: 'Disrupts their expectation of indifference by physically pausing tasks, instantly establishing emotional safety.',
          ),
          const DecodeStrategy(
            type: 'humor',
            title: 'Strategy B · Humorous Icebreaker',
            actionText: 'Red Alert! EmpathIQ sensor just caught a high-level tension signal! I wouldn\'t dare walk away—let me brew you a warm cup of tea~',
            mechanism: 'Diffuses deadlock through playful warmth and eliminates adversarial tension.',
          ),
          const DecodeStrategy(
            type: 'boundary',
            title: 'Strategy C · Gentle Boundary',
            actionText: 'I truly value our relationship. If you need some quiet space right now I respect that; whenever you\'re ready, let\'s talk openly.',
            mechanism: 'Offers space while firmly declining guessing games, establishing healthy adult boundaries.',
          ),
        ]);
      }
    }

    final isZh = AppLocale.instance.currentCode == 'zh';

    return DecodeResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      inputText: input,
      relationship: rel,
      temperature: temp,
      temperatureLevel: level,
      defensePercent: defense,
      surfaceMeaning: surface,
      realSubtext: subtext,
      corePainPoint: pain,
      strategies: strategies,
      initialNpcThought: json['initial_npc_thought'] as String? ??
          (isZh ? '他要是真不管我，今天就彻底完了。' : 'If they really walk away now, we are completely done.'),
      initialNpcSpeech: json['initial_npc_speech'] as String? ??
          (isZh ? '不用管我，反正我怎么想的一点都不重要。' : 'Don\'t bother with me. What I think doesn\'t matter anyway.'),
    );
  }

  /// Context-aware smart mock data generation
  DecodeResult _generateContextualMockResult(String input, String rel) {
    if (AppLocale.instance.currentCode == 'zh') {
      return _generateChineseMockResult(input, rel);
    }
    return _generateEnglishMockResult(input, rel);
  }

  DecodeResult _generateEnglishMockResult(String input, String rel) {
    final lower = input.toLowerCase();
    final lowerRel = rel.toLowerCase();

    int temp = 68;
    int defense = 75;
    String surface = input;
    String subtext;
    String pain;
    String thought;
    String speech;
    List<DecodeStrategy> strategies;

    if (lower.contains('fine') ||
        lower.contains('whatever') ||
        lower.contains('nothing') ||
        lower.contains('never mind') ||
        lower.contains('leave me alone') ||
        lowerRel.contains('partner') ||
        lowerRel.contains('伴侣')) {
      temp = 78;
      defense = 85;
      subtext =
          'I am feeling deeply hurt, unseen, and emotionally disconnected. Saying "I am fine" is a test to see if you actually care enough to notice. If you take it literally and walk away, it will confirm my deepest fear—that I truly don\'t matter to you.';
      pain =
          'Deep emotional vulnerability and craving for unconditional reassurance, combined with the fear that expressing need will lead to dismissal.';
      thought =
          'If they just say "okay cool" and walk away, I am going to completely shut down.';
      speech =
          'Don\'t worry about me. Go attend to your important stuff. I\'m used to handling things alone anyway.';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: 'Strategy A · Safe Empathy',
          actionText:
              '“How could you be fine? Seeing you like this breaks my heart. Whatever I was doing can wait—you matter way more. Come sit with me; tell me what you\'re feeling.”',
          mechanism:
              '【Reverse Expectation Disruption】: Shatters the counterpart\'s fear of neglect by deliberately halting tasks and offering immediate emotional priority.',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: 'Strategy B · Humorous Icebreaker',
          actionText:
              '“Red Alert! EmpathIQ sensor just caught a Category 5 \'I\'m Fine\' alarm! I wouldn\'t dare walk away—grant me a chance to brew you tea and make amends~”',
          mechanism:
              '【Low-Stakes Desensitization】: Diffuses adversarial tension through playful self-deprecation, lowering defensive ego and creating an easy off-ramp to smile.',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: 'Strategy C · Gentle Boundary',
          actionText:
              '“I can sense heavy emotions right now, and I genuinely want to talk it through. If you need some quiet space first, I respect that—I\'ll be right here whenever you\'re ready.”',
          mechanism:
              '【Warm Yet Firm】: Declines passive-aggressive mind games while maintaining an unwavering, dependable presence and clear adult boundaries.',
        ),
      ];
    } else if (lowerRel.contains('work') ||
        lowerRel.contains('boss') ||
        lowerRel.contains('职场') ||
        lower.contains('as you wish') ||
        lower.contains('up to you')) {
      temp = 55;
      defense = 65;
      subtext =
          'I have serious reservations about this delivery or progress, but I don\'t want to spend extra energy micromanaging right now. If you turn this in as is, you bear full responsibility for any fallout.';
      pain =
          'Loss of control and risk aversion; lack of confidence in subordinate delivery execution.';
      thought =
          'Why are they missing the core risk? This proposal will run into serious pushback.';
      speech =
          'Fine, if you think this proposal is good to go, proceed on your own judgment.';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: 'Strategy A · Safe Empathy',
          actionText:
              '“I sense you have reservations about the delivery timeline and conversion risks. I\'ve structured Options A and B with risk hedges—could I get 3 minutes of your direction to align?”',
          mechanism:
              '【Proactive Risk Absorption】: Relieves managerial anxiety by offering structured options, instantly creating a dependable, professional impression.',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: 'Strategy B · Humorous Icebreaker',
          actionText:
              '“From that look, I know this draft hasn\'t earned your gold star yet! Give me two pointers and I\'ll polish it into something we\'re both proud of.”',
          mechanism:
              '【Positive Reframing】: Reframes critique into mentorship, preserving authority while demonstrating high coachability and resilience.',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: 'Strategy C · Gentle Boundary',
          actionText:
              '“Understood. To ensure our delivery meets expectations, I\'ve outlined the key milestones and resource requirements in writing. If aligned, I will proceed on this baseline.”',
          mechanism:
              '【Written Alignment Guard】: Uses objective facts and documented milestones to prevent retroactive ambiguity or blame shifting.',
        ),
      ];
    } else if (lowerRel.contains('family') ||
        lowerRel.contains('parent') ||
        lowerRel.contains('长辈') ||
        lower.contains('busy') ||
        lower.contains('don\'t worry')) {
      temp = 42;
      defense = 70;
      subtext =
          'I miss you dearly and feel increasingly disconnected from your fast-paced life, but I dread being a burden, so I put on a stoic front to mask loneliness and vulnerability.';
      pain =
          'Deep fear of becoming irrelevant or an emotional burden to their grown children as they age.';
      thought =
          'They are all grown up and busy with their own lives. We barely get to see them anymore.';
      speech =
          'Go take care of your career. Don\'t worry about us; we have everything we need at home.';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: 'Strategy A · Safe Empathy',
          actionText:
              '“Hearing you say that tugs at my heart. Work is never more important than family. I\'m booking a ticket right now and coming home this weekend for your home-cooked meal!”',
          mechanism:
              '【Anchoring to Primary Nurturing】: Reactivates the parent\'s primary caring instinct (cooking/care), restoring their pride and sense of purpose.',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: 'Strategy B · Humorous Icebreaker',
          actionText:
              '“Listen to that formal tone—anyone would think I wasn\'t your kid! You can\'t shake me off that easily. I\'m coming over to raid the fridge this weekend!”',
          mechanism:
              '【Playful Child Role】: Stepping back into the role of the cared-for child dissolves generational stiffness instantly.',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: 'Strategy C · Gentle Boundary',
          actionText:
              '“I\'m in the final sprint of this project through Thursday. Once it wraps on Friday evening, let\'s do a dedicated 30-minute video call so we can catch up properly.”',
          mechanism:
              '【Predictable Commitment Anchor】: Provides an explicit, guaranteed commitment node, allowing parents to feel prioritized without disrupting work sprints.',
        ),
      ];
    } else {
      // General Friend/Social
      temp = 62;
      defense = 68;
      subtext =
          'I don\'t fully agree with your perspective or current choice, but I don\'t want to create social tension, so I\'m keeping a safe, polite distance.';
      pain =
          'Fear of interpersonal conflict rupturing superficial harmony; subconscious reluctance to risk disagreement.';
      thought =
          'Since we are not on the same page, it is safer to wrap this up cordially.';
      speech =
          'Sounds great, whatever works for you! At the end of the day, it\'s your call.';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: 'Strategy A · Safe Empathy',
          actionText:
              '“We\'ve known each other for years, and your honest opinion is what I value most. Are you seeing blind spots I missed? Don\'t hold back—I want your unfiltered view.”',
          mechanism:
              '【Emotional Immunity Grant】: Actively removes the counterpart\'s fear of conflict, granting explicit psychological permission to speak frankly.',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: 'Strategy B · Humorous Icebreaker',
          actionText:
              '“Whoa, why so polite all of a sudden? Who are you and what have you done with my friend? I\'m buying coffee right now so you can ruthlessly roast my idea!”',
          mechanism:
              '【Informal Re-anchoring】: Uses playful penalty rituals (coffee/drinks) to bring the dialogue back into comfortable camaraderie.',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: 'Strategy C · Gentle Boundary',
          actionText:
              '“Thanks for sharing your perspective! Everyone\'s situation is different, and I\'ve weighed the risks. Even if I stumble, it\'s a lesson I need to experience. Let\'s hang out soon!”',
          mechanism:
              '【Separation of Tasks】: Adlerian task separation—gratefully receives feedback while preventing another\'s hesitation from eroding personal agency.',
        ),
      ];
    }

    final level = AppColors.getTemperatureLevelName(temp);

    return DecodeResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      inputText: input,
      relationship: rel,
      temperature: temp,
      temperatureLevel: level,
      defensePercent: defense,
      surfaceMeaning: surface,
      realSubtext: subtext,
      corePainPoint: pain,
      strategies: strategies,
      initialNpcThought: thought,
      initialNpcSpeech: speech,
    );
  }

  DecodeResult _generateChineseMockResult(String input, String rel) {
    final lower = input.toLowerCase();

    // Default values tailored to relationships
    int temp = 68;
    int defense = 75;
    String surface = input;
    String subtext;
    String pain;
    String thought;
    String speech;
    List<DecodeStrategy> strategies;

    if (lower.contains('没事') || lower.contains('不用了') || lower.contains('随你') || lower.contains('别管我')) {
      temp = 78;
      defense = 85;
      subtext = '我现在满肚子委屈和难过，我嘴上说没事是想看看你心里到底有没有我，如果你真信了，我只会更加绝望。';
      pain = '渴望无条件被关注与偏爱，深层恐惧“我即使说了也会被漠视或嫌弃”。';
      thought = '他要是真一句“哦那我忙去了”，我就拉黑他三天。';
      speech = '不用管我，你忙你的大事业去吧，我反正习惯了。';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: '稳妥共情牌',
          actionText: '“怎么可能没事呢？看着你这样我心里特别揪着。天大的事都没你重要，过来抱抱，我们不憋在心里好吗？”',
          mechanism: '【反向阻断预期】：对方预判你会顺水推舟，你直接用绝对偏爱击碎其“我不重要”的恐惧，直达情感内核。',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: '幽默破冰牌',
          actionText: '“嘀嘀嘀！ EmpathIQ 警报：检测到最高级‘没事’危险警报！小人怎敢轻举妄动，特来负荆请罪请娘娘发落~”',
          mechanism: '【降维脱敏法】：用戏谑与适度自嘲拆解自恋防御，给对方一个体面破涕为笑的台阶，避免两人在对峙中下不来台。',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: '温和界限牌',
          actionText: '“我能感觉到你此刻的情绪波动，我也很想陪你好好聊开。如果你现在需要自己静一静我尊重你，但别把门锁死，我一直在门外等你。”',
          mechanism: '【温和而坚定】：既不被对方的被动攻击牵着鼻子走，又持续释放安全可依赖的在场信号，划定健康边界。',
        ),
      ];
    } else if (rel.contains('职场') || rel.contains('主管') || lower.contains('行吧') || lower.contains('问题不大') || lower.contains('你看着办')) {
      temp = 55;
      defense = 65;
      subtext = '我对这个进度或交付质量并不满意，但我现在不想承担额外沟通成本，如果你直接这么交差，后续风险你将全责背书。';
      pain = '掌控感丧失与潜在责任风险顾虑，缺乏明确的确定感与对下属交付能力的信任。';
      thought = '这届新人怎么总抓不住重点，方案漏洞百出还不自知。';
      speech = '行吧，你觉得这个方案能交差那就按你的想法来。';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: '稳妥共情牌',
          actionText: '“领导，我感觉您对这个方案的转化预估还有些顾虑。我把A/B两个备选方案的风险对冲都整理好了，想占用您三分钟帮我圈点把关一下。”',
          mechanism: '【主动接盘确定性】：不让领导承担模糊风险，提供具体选项让领导做决策，瞬间建立靠谱专业形象。',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: '幽默破冰牌',
          actionText: '“看您这表情，我这方案离您心里的满分作业显然还差点火候！您稍微提点两句，我连夜把它精雕细琢成爆款。”',
          mechanism: '【正向期待重构】：将批评降格为“指导进阶”，既保全了领导权威，又展示出极佳的皮实度和进取心。',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: '温和界限牌',
          actionText: '“明白您的要求。为了确保交付结果符合预期，我把本周的关键里程碑和资源需求列在这里，若无异议我将按此标准推进。”',
          mechanism: '【书面闭环防护】：用客观的事实与流程对齐边界，避免后续因口头模糊约定产生权责扯皮。',
        ),
      ];
    } else if (rel.contains('长辈') || rel.contains('父母') || lower.contains('不用回') || lower.contains('挺好的') || lower.contains('不缺')) {
      temp = 42;
      defense = 70;
      subtext = '我很想你，也觉得在你的生活中越来越插不上话而感到失落，但我怕成为你的累赘，只能用故作坚强来掩盖衰老与孤单。';
      pain = '深层价值感丧失与衰老焦虑，渴望被需要、被记挂，却又害怕成为子女的负担。';
      thought = '孩子长大了，翅膀硬了，一年到头也见不上两面。';
      speech = '你忙你的大事情去，家里不用你操心，我们俩有吃有喝挺好的。';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: '稳妥共情牌',
          actionText: '“妈，听您这么说我心里酸酸的。工作再忙哪有陪您重要，我已经把高铁票看好了，这周末就回去吃您包的饺子！”',
          mechanism: '【情感需求具象化】：跳过表面的拒绝推辞，直接锚定父母擅长的“做饭/照料”需求，让父母重新找回被需要的成就感。',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: '幽默破冰牌',
          actionText: '“听听这语气，不知道的还以为我不是亲生的呢！不许嫌弃我，我不仅要回去蹭饭，还要带好吃的给二老检查作业！”',
          mechanism: '【撒娇破冰法】：在父母面前放下成年人的防备扮演被照顾的角色，是化解代际疏离感最有效的催化剂。',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: '温和界限牌',
          actionText: '“爸妈，我最近手头这个大项目确实到了收尾攻坚期，等这周四忙完，周五晚上我一定跟你们通半小时视频，我们都保重好身体。”',
          mechanism: '【承诺确定性节点】：给父母一个具体的期待预期，既保护当下工作节奏，又让父母明确感知到自己被挂念在日程表上。',
        ),
      ];
    } else {
      // General Friend/Social
      temp = 62;
      defense = 68;
      subtext = '我并不赞同你的决定或此时的处境，但我不想当坏人，所以我选择用中立客套的话拉开社交安全距离。';
      pain = '担心人际冲突打破表面和谐，潜意识里缺乏真实面对分歧的勇气。';
      thought = '既然话不投机，那还是客气客气早点散场吧。';
      speech = '挺好的啊，看你自己想法呗，反正人生是你自己的。';
      strategies = [
        const DecodeStrategy(
          type: 'empathy',
          title: '稳妥共情牌',
          actionText: '“我们认识这么多年了，我最在乎你的真话。你是不是看到了我没注意到的盲区？直说没关系，我想听你的真知灼见。”',
          mechanism: '【赋予豁免权】：主动免除对方的冲突顾虑，给对方提供直言不讳的心理安全许可。',
        ),
        const DecodeStrategy(
          type: 'humor',
          title: '幽默破冰牌',
          actionText: '“听这客气劲儿，咱们俩什么时候生分成这样啦？必须罚你喝一杯奶茶，顺便狠狠批判批判我的蠢主意！”',
          mechanism: '【非正式环境唤醒】：用非正式惩罚（奶茶）拉回熟人语境，打碎客套的面具。',
        ),
        const DecodeStrategy(
          type: 'boundary',
          title: '温和界限牌',
          actionText: '“感谢你的建议。每个人处境不同，我自己深思熟虑过了，即便踩坑也是我的必修课，咱们改天一起聚聚！”',
          mechanism: '【独立课题分离】：课题分离，既礼貌接纳反馈，又不把对方的消极态度内化为自我怀疑。',
        ),
      ];
    }

    final level = AppColors.getTemperatureLevelName(temp);

    return DecodeResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      inputText: input,
      relationship: rel,
      temperature: temp,
      temperatureLevel: level,
      defensePercent: defense,
      surfaceMeaning: surface,
      realSubtext: subtext,
      corePainPoint: pain,
      strategies: strategies,
      initialNpcThought: thought,
      initialNpcSpeech: speech,
    );
  }
}
