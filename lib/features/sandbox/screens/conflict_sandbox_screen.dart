import 'package:flutter/material.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/hud_status_bar.dart';
import '../widgets/sandbox_chat_bubble.dart';
import '../widgets/settlement_dialog.dart';

class ConflictSandboxScreen extends StatefulWidget {
  final DecodeResult decodeResult;

  const ConflictSandboxScreen({
    super.key,
    required this.decodeResult,
  });

  @override
  State<ConflictSandboxScreen> createState() => _ConflictSandboxScreenState();
}

class _ConflictSandboxScreenState extends State<ConflictSandboxScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late int _currentDefense;
  late String _currentInnerThought;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _userRoundsCount = 0;
  String? _activeCoachingHint;
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    _currentDefense = widget.decodeResult.defensePercent;
    _currentInnerThought = widget.decodeResult.initialNpcThought.isNotEmpty
        ? widget.decodeResult.initialNpcThought
        : '他要是真不当回事，我就彻底不再抱希望了。';

    _activeCoachingHint = '💡 对方防御值较高，优先倾听与复述感受，切忌自辩或讲大道理。';

    _loadSettings();
    _initFirstMessage();
  }

  Future<void> _loadSettings() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _settings = storage.getSettings();
    });
  }

  void _initFirstMessage() {
    final initialSpeech = widget.decodeResult.initialNpcSpeech.isNotEmpty
        ? widget.decodeResult.initialNpcSpeech
        : widget.decodeResult.inputText;

    _messages.add(
      ChatMessage(
        id: 'msg_0',
        sender: 'npc',
        content: initialSpeech,
        timestamp: DateTime.now(),
        innerThought: _currentInnerThought,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendReply([String? prefilledText]) async {
    final text = (prefilledText ?? _inputController.text).trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _userRoundsCount++;
      _messages.add(
        ChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          sender: 'user',
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final feedback = await LLMService.instance.generateSandboxTurn(
        originalSubtext: widget.decodeResult.inputText,
        relationship: widget.decodeResult.relationship,
        history: _messages,
        userReply: text,
        currentDefense: _currentDefense,
        settings: _settings,
      );

      final int delta = (feedback['defense_delta'] as num?)?.toInt() ?? -10;
      final int newDef = (feedback['new_defense_percent'] as num?)?.toInt() ??
          (_currentDefense + delta).clamp(10, 100);
      final String tag = feedback['feedback_tag'] as String? ?? '【情绪稳定】已接住对方话头';
      final String thought = feedback['inner_thought'] as String? ?? '他在认真听我说...';
      final String npcReply = feedback['npc_reply'] as String? ?? '行吧，你既然都这么说了...';
      final String hint = feedback['coaching_hint'] as String? ??
          '💡 继续肯定对方的情绪感受，巩固安全信任。';

      setState(() {
        _currentDefense = newDef;
        _currentInnerThought = thought;
        _activeCoachingHint = hint;
        _messages.add(
          ChatMessage(
            id: 'npc_${DateTime.now().millisecondsSinceEpoch}',
            sender: 'npc',
            content: npcReply,
            timestamp: DateTime.now(),
            defenseDelta: delta,
            feedbackTag: tag,
            innerThought: thought,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();

      // Check for round settlement (after 3 rounds or defense successfully lowered to <= 25)
      if (_userRoundsCount >= 3 || _currentDefense <= 25) {
        Future.delayed(const Duration(milliseconds: 600), _showSettlement);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSettlement() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SettlementDialog(
        finalDefense: _currentDefense,
        totalTurns: _userRoundsCount,
        onRetry: () {
          Navigator.of(ctx).pop();
          setState(() {
            _messages.clear();
            _userRoundsCount = 0;
            _currentDefense = widget.decodeResult.defensePercent;
            _currentInnerThought = widget.decodeResult.initialNpcThought;
            _initFirstMessage();
          });
        },
        onFinish: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strategies = widget.decodeResult.strategies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('1分钟冲突对练沙盒'),
        actions: [
          TextButton.icon(
            onPressed: _showSettlement,
            icon: const Icon(Icons.analytics_outlined, size: 16, color: AppColors.warmBeige),
            label: const Text(
              '结算复盘',
              style: TextStyle(color: AppColors.warmBeige, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed HUD Status Bar
          HudStatusBar(
            characterName: '对方 (${widget.decodeResult.relationship})',
            relationship: widget.decodeResult.relationship,
            defensePercent: _currentDefense,
            currentInnerThought: _currentInnerThought,
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return SandboxChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Loading skeleton state
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.warmBeige),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '对方正在经历心理防御动摇...',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Coaching Hint Capsule
          if (_activeCoachingHint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.surface,
              child: Text(
                _activeCoachingHint!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amberSand,
                ),
              ),
            ),

          // Quick Strategy Prompts Chips
          if (strategies.isNotEmpty)
            Container(
              color: AppColors.surface,
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: strategies.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
                      avatar: const Icon(Icons.bolt_rounded, size: 13, color: AppColors.warmBeige),
                      label: Text(
                        '使用【${s.title}】话术',
                        style: const TextStyle(fontSize: 11, color: AppColors.textWarm),
                      ),
                      onPressed: () => _handleSendReply(s.actionText),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Bottom Input Field
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.borderSubtle, width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '输入你的回应，尝试瓦解对方心防...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.warmBeige),
                      ),
                    ),
                    onSubmitted: (_) => _handleSendReply(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.warmBeige,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.background),
                    onPressed: _handleSendReply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
