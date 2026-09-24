import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../decoder/screens/decoder_result_screen.dart';
import '../../dilemma/screens/dilemma_challenge_screen.dart';
import '../../settings/screens/settings_sheet.dart';
import '../widgets/dilemma_card.dart';
import '../widgets/history_card.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/relationship_chip_group.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedRelationshipKey = 'rel_partner';
  int _remainingQuota = 3;
  List<DecodeResult> _historyList = [];
  bool _isLoading = false;
  String? _detectedClipboardText;
  bool _hasPromptedClipboard = false;
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
    _checkClipboard();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_hasPromptedClipboard) {
        _checkClipboard();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
      _refreshStorageData();
    }
  }

  Future<void> _loadInitialData() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _remainingQuota = storage.getRemainingDailyQuota();
      _historyList = storage.getHistory();
      _settings = storage.getSettings();
    });
  }

  Future<void> _refreshStorageData() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _remainingQuota = storage.getRemainingDailyQuota();
      _historyList = storage.getHistory();
      _settings = storage.getSettings();
    });
  }

  Future<void> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty &&
          text.length <= 300 &&
          text != _inputController.text.trim() &&
          text != _detectedClipboardText) {
        setState(() {
          _detectedClipboardText = text;
        });
      }
    } catch (_) {
      // Clipboard access might be denied on some platforms
    }
  }

  void _applyClipboardText() {
    if (_detectedClipboardText != null) {
      _inputController.text = _detectedClipboardText!;
      setState(() {
        _detectedClipboardText = null;
        _hasPromptedClipboard = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('paste')),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.surfaceHighlight,
        ),
      );
    }
  }

  void _dismissClipboardBanner() {
    setState(() {
      _detectedClipboardText = null;
      _hasPromptedClipboard = true;
    });
  }

  Future<void> _handleDecode() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (_remainingQuota <= 0) {
      _showQuotaExceededDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = await StorageService.getInstance();
      await storage.consumeDailyQuota();

      final result = await LLMService.instance.decodeSubtext(
        inputText: text,
        relationship: tr(_selectedRelationshipKey),
        settings: _settings,
      );

      await storage.saveDecodeResult(result);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _remainingQuota = storage.getRemainingDailyQuota();
          _historyList = storage.getHistory();
        });

        // Navigate to Decoder Results Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DecoderResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('btn_decode')} error: $e'),
            backgroundColor: AppColors.flammableRedSubtle,
          ),
        );
      }
    }
  }

  void _showQuotaExceededDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        title: Row(
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: AppColors.amberSand, size: 22),
            const SizedBox(width: 8),
            Text(
              tr('quota_exceeded_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          tr('quota_exceeded_desc'),
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('understood'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmBeige,
              foregroundColor: AppColors.background,
            ),
            child: Text(tr('go_to_settings'), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsSheet(onSaved: _refreshStorageData),
    );
  }

  void _openDilemmaChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DilemmaChallengeScreen()),
    );
  }

  void _openHistoryDetail(DecodeResult item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DecoderResultScreen(result: item),
      ),
    );
  }

  Future<void> _deleteHistoryItem(String id) async {
    final storage = await StorageService.getInstance();
    await storage.deleteHistoryItem(id);
    _refreshStorageData();
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _inputController.text.length;
    final isInputValid = textLength > 0 && textLength <= 300;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480), // Mobile viewport on Web/Desktop
            child: Column(
              children: [
                // Top App Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Slogan
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.warmBeige,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.psychology_rounded,
                                size: 19,
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'EmpathIQ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Text(
                                    tr('app_slogan'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Right Capsule: Language Switcher, Daily Quota & Settings
                      Row(
                        children: [
                          // Language Switcher dropdown
                          const LanguageSelectorButton(),
                          const SizedBox(width: 5),

                          // Quota capsule
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _remainingQuota > 0
                                    ? AppColors.warmBeige.withValues(alpha: 0.4)
                                    : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 13,
                                  color: _remainingQuota > 0
                                      ? AppColors.warmBeige
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  tr('daily_scans_left', [_remainingQuota.toString()]),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: _remainingQuota > 0
                                        ? AppColors.warmBeige
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 19, color: AppColors.textSecondary),
                            onPressed: _openSettings,
                            tooltip: tr('settings_title'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clipboard Toast / Suggestion Banner
                        if (_detectedClipboardText != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.warmBeige.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warmBeige.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.content_paste_rounded, size: 16, color: AppColors.warmBeige),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tr('clipboard_detected'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.warmBeigeLight),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _applyClipboardText,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(tr('paste'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.warmBeige)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                  onPressed: _dismissClipboardBanner,
                                ),
                              ],
                            ),
                          ),

                        // Card 1: Core Subtext Decoder Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderSubtle, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.radar_rounded, size: 16, color: AppColors.amberSand),
                                  const SizedBox(width: 6),
                                  Text(
                                    tr('subtext_decoder'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Text Area
                              TextField(
                                controller: _inputController,
                                focusNode: _focusNode,
                                maxLines: 4,
                                maxLength: 300,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: tr('decoder_hint'),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated,
                                  counterText: tr('char_counter', [textLength.toString()]),
                                  counterStyle: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Relationship chips
                              Text(
                                tr('relationship_title'),
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              RelationshipChipGroup(
                                selectedRelationship: _selectedRelationshipKey,
                                onSelected: (relKey) {
                                  setState(() {
                                    _selectedRelationshipKey = relKey;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Main Action Button: Decode Subtext
                              SizedBox(
                                width: double.infinity,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: ElevatedButton(
                                    onPressed: isInputValid && !_isLoading ? _handleDecode : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInputValid ? AppColors.warmBeige : AppColors.surfaceElevated,
                                      foregroundColor: isInputValid ? AppColors.background : AppColors.textMuted,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                tr('analyzing'),
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.remove_red_eye_rounded, size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                tr('btn_decode'),
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Card 2: Secondary Card (Daily Dilemma)
                        DilemmaCard(
                          onTap: _openDilemmaChallenge,
                        ),
                        const SizedBox(height: 20),

                        // Card 3: Recent History List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history_rounded, size: 16, color: AppColors.warmBeige),
                                const SizedBox(width: 6),
                                Text(
                                  tr('recent_history'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_historyList.isNotEmpty)
                              Text(
                                tr('history_count', [_historyList.length.toString()]),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_historyList.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inbox_outlined, size: 32, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                Text(
                                  tr('empty_history_title'),
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tr('empty_history_sub'),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._historyList.map(
                            (item) => HistoryCard(
                              item: item,
                              onTap: () => _openHistoryDetail(item),
                              onDelete: () => _deleteHistoryItem(item.id),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
