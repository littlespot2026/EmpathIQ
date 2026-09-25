import 'dart:convert';

class DecodeStrategy {
  final String type; // 'empathy', 'humor', 'boundary'
  final String title; // '稳妥共情牌', '幽默破冰牌', '温和界限牌'
  final String actionText; // The ready-to-send copyable reply
  final String mechanism; // The psychological breakdown

  const DecodeStrategy({
    required this.type,
    required this.title,
    required this.actionText,
    required this.mechanism,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'action_text': actionText,
      'mechanism': mechanism,
    };
  }

  factory DecodeStrategy.fromMap(Map<String, dynamic> map) {
    return DecodeStrategy(
      type: map['type'] as String? ?? 'empathy',
      title: map['title'] as String? ?? 'Strategy A',
      actionText: map['action_text'] as String? ?? map['actionText'] as String? ?? '',
      mechanism: map['mechanism'] as String? ?? '',
    );
  }
}

class DecodeResult {
  final String id;
  final DateTime createdAt;
  final String inputText;
  final String relationship; // 伴侣, 职场/主管, 朋友, 长辈/父母
  final int temperature; // 0 - 100
  final String temperatureLevel; // 冷淡蓝, 焦躁黄, 易燃红
  final int defensePercent; // 0 - 100
  final String surfaceMeaning; // 表面字面意思
  final String realSubtext; // 真实潜台词 (真实心理动机)
  final String corePainPoint; // 核心痛点
  final List<DecodeStrategy> strategies;
  final String initialNpcThought; // 沙盒初始角色内心活动
  final String initialNpcSpeech; // 沙盒初始角色对白
  final bool isMock;

  const DecodeResult({
    required this.id,
    required this.createdAt,
    required this.inputText,
    required this.relationship,
    required this.temperature,
    required this.temperatureLevel,
    required this.defensePercent,
    required this.surfaceMeaning,
    required this.realSubtext,
    required this.corePainPoint,
    required this.strategies,
    this.initialNpcThought = '',
    this.initialNpcSpeech = '',
    this.isMock = false,
  });

  DecodeStrategy? get empathyStrategy {
    try {
      return strategies.firstWhere((s) => s.type == 'empathy');
    } catch (_) {
      return strategies.isNotEmpty ? strategies[0] : null;
    }
  }

  DecodeStrategy? get humorStrategy {
    try {
      return strategies.firstWhere((s) => s.type == 'humor');
    } catch (_) {
      return strategies.length > 1 ? strategies[1] : null;
    }
  }

  DecodeStrategy? get boundaryStrategy {
    try {
      return strategies.firstWhere((s) => s.type == 'boundary');
    } catch (_) {
      return strategies.length > 2 ? strategies[2] : null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'input_text': inputText,
      'relationship': relationship,
      'temperature': temperature,
      'temperature_level': temperatureLevel,
      'defense_percent': defensePercent,
      'surface_meaning': surfaceMeaning,
      'real_subtext': realSubtext,
      'core_pain_point': corePainPoint,
      'strategies': strategies.map((s) => s.toMap()).toList(),
      'initial_npc_thought': initialNpcThought,
      'initial_npc_speech': initialNpcSpeech,
      'is_mock': isMock,
    };
  }

  factory DecodeResult.fromMap(Map<String, dynamic> map) {
    return DecodeResult(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      inputText: map['input_text'] as String? ?? '',
      relationship: map['relationship'] as String? ?? 'Partner',
      temperature: (map['temperature'] as num?)?.toInt() ?? 50,
      temperatureLevel: map['temperature_level'] as String? ?? 'Agitated Yellow',
      defensePercent: (map['defense_percent'] as num?)?.toInt() ?? 60,
      surfaceMeaning: map['surface_meaning'] as String? ?? '',
      realSubtext: map['real_subtext'] as String? ?? '',
      corePainPoint: map['core_pain_point'] as String? ?? '',
      strategies: (map['strategies'] as List<dynamic>?)
              ?.map((e) => DecodeStrategy.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      initialNpcThought: map['initial_npc_thought'] as String? ?? '',
      initialNpcSpeech: map['initial_npc_speech'] as String? ?? '',
      isMock: map['is_mock'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory DecodeResult.fromJson(String jsonStr) =>
      DecodeResult.fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
}
