class ChatMessage {
  final String id;
  final String sender; // 'user', 'npc', 'coach'
  final String content;
  final DateTime timestamp;
  final int? defenseDelta; // e.g. -15 or +10
  final String? feedbackTag; // e.g. "【怒气 -15%】精准共情"
  final String? innerThought; // NPC's live subtext thought
  final String? coachingHint; // Advice for next turn

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.defenseDelta,
    this.feedbackTag,
    this.innerThought,
    this.coachingHint,
  });

  bool get isUser => sender == 'user';
  bool get isNpc => sender == 'npc';
  bool get isCoach => sender == 'coach';
}
