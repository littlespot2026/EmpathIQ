import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../auth/screens/landing_screen.dart';
import '../../subscription/widgets/pro_paywall_modal.dart';

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
  bool _isUserPro = false;
  List<DecodeResult> _historyList = [];
  bool _isLoading = false;
  String? _detectedClipboardText;
  bool _hasPromptedClipboard = false;
  AppSettings _settings = const AppSettings();

  // Multimodal Vision / Chat Screenshot State
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  int? _selectedImageSize;
  int _loadingStage = 0;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLocale.instance.addListener(_onLocaleChanged);
    StorageService.proStatusNotifier.addListener(_refreshStorageData);
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
    _loadingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    AppLocale.instance.removeListener(_onLocaleChanged);
    StorageService.proStatusNotifier.removeListener(_refreshStorageData);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
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
      _isUserPro = storage.isUserPro();
      _historyList = storage.getHistory();
      _settings = storage.getSettings();
    });
  }

  Future<void> _refreshStorageData() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _remainingQuota = storage.getRemainingDailyQuota();
      _isUserPro = storage.isUserPro();
      _historyList = storage.getHistory();
      _settings = storage.getSettings();
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 4096,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.lengthInBytes > 4 * 1024 * 1024) {
        final sizeMb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('image_too_large', ['${sizeMb}MB'])),
              backgroundColor: AppColors.flammableRedSubtle,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
        _selectedImageSize = bytes.lengthInBytes;
      });
    } catch (e) {
      debugPrint('[HomeScreen] Failed to pick image: $e');
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _selectedImageSize = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _detectMimeType(String? name) {
    if (name == null) return 'image/jpeg';
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  String _getLoadingText() {
    if (_selectedImageBytes != null) {
      switch (_loadingStage) {
        case 0:
          return tr('analyzing_vision_step_1');
        case 1:
          return tr('analyzing_vision_step_2');
        case 2:
        default:
          return tr('analyzing_vision_step_3');
      }
    }
    return tr('analyzing');
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warmBeige.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _selectedImageBytes!,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.image_rounded, size: 14, color: AppColors.warmBeige),
                    const SizedBox(width: 5),
                    Text(
                      tr('screenshot_attached'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${_selectedImageName ?? "screenshot.jpg"} (${_formatFileSize(_selectedImageSize ?? 0)})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _clearSelectedImage,
            icon: const Icon(Icons.close_rounded, size: 16),
            color: AppColors.textMuted,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceHighlight.withValues(alpha: 0.6),
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(28, 28),
            ),
            tooltip: tr('remove_screenshot'),
          ),
        ],
      ),
    );
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
    final hasImage = _selectedImageBytes != null;
    if ((text.isEmpty && !hasImage) || _isLoading) return;

    if (_remainingQuota <= 0) {
      _showQuotaExceededDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingStage = 0;
    });

    if (hasImage) {
      _loadingTimer?.cancel();
      _loadingTimer = Timer.periodic(const Duration(milliseconds: 1400), (t) {
        if (mounted && _isLoading) {
          setState(() {
            _loadingStage = (_loadingStage + 1) % 3;
          });
        } else {
          t.cancel();
        }
      });
    }

    try {
      final storage = await StorageService.getInstance();
      await storage.consumeDailyQuota();

      final result = await LLMService.instance.decodeSubtext(
        inputText: text,
        relationship: tr(_selectedRelationshipKey),
        settings: _settings,
        imageBytes: _selectedImageBytes,
        mimeType: _detectMimeType(_selectedImageName),
      );

      await storage.saveDecodeResult(result);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _remainingQuota = storage.getRemainingDailyQuota();
          _historyList = storage.getHistory();
        });

        _inputController.clear();
        _clearSelectedImage();

        // If running in simulation/mock mode (either mock toggle is ON or offline fallback)
        if (result.isMock) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warmBeige, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr('mock_mode_notice'),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surfaceHighlight,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(
                label: tr('go_to_settings').split(' ').first,
                textColor: AppColors.warmBeige,
                onPressed: _openSettings,
              ),
            ),
          );
        }

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
    } finally {
      _loadingTimer?.cancel();
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
            Flexible(
              child: Text(
                tr('quota_exceeded_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          tr('quota_exceeded_desc'),
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openSettings();
            },
            child: Text(tr('go_to_settings'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ProPaywallModal.show(context, onSubscribed: _refreshStorageData);
            },
            icon: const Icon(Icons.diamond_rounded, size: 16),
            label: Text(tr('upgrade_pro_btn')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmBeige,
              foregroundColor: AppColors.background,
              elevation: 3,
            ),
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

  void _goToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _inputController.text.length;
    final hasImage = _selectedImageBytes != null;
    final isInputValid = (textLength > 0 && textLength <= 300) || hasImage;

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
                      // Logo & Slogan (Clickable to return to Welcome)
                      Expanded(
                        child: InkWell(
                          onTap: _goToWelcome,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Right Capsule: Language Switcher, Daily Quota & Settings
                      Row(
                        children: [
                          // Language Switcher dropdown
                          const LanguageSelectorButton(),
                          const SizedBox(width: 5),

                          // Quota / Pro capsule
                          InkWell(
                            onTap: () => ProPaywallModal.show(context, onSubscribed: _refreshStorageData),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: _isUserPro
                                    ? AppColors.warmBeige.withValues(alpha: 0.16)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _isUserPro
                                      ? AppColors.warmBeige.withValues(alpha: 0.5)
                                      : (_remainingQuota > 0
                                          ? AppColors.warmBeige.withValues(alpha: 0.4)
                                          : AppColors.flammableRed.withValues(alpha: 0.5)),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isUserPro
                                        ? Icons.workspace_premium_rounded
                                        : (_remainingQuota > 0 ? Icons.bolt_rounded : Icons.diamond_rounded),
                                    size: 13,
                                    color: _isUserPro
                                        ? AppColors.warmBeige
                                        : (_remainingQuota > 0 ? AppColors.warmBeige : AppColors.amberSand),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _isUserPro
                                        ? 'PRO'
                                        : (_remainingQuota > 0
                                            ? tr('daily_scans_left', [_remainingQuota.toString()])
                                            : tr('upgrade_pro_btn')),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: _isUserPro
                                          ? AppColors.warmBeige
                                          : (_remainingQuota > 0 ? AppColors.warmBeige : AppColors.amberSand),
                                    ),
                                  ),
                                ],
                              ),
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

                              // Thumbnail Preview Bar (if image attached)
                              _buildImagePreview(),

                              // Text Area
                              TextField(
                                controller: _inputController,
                                focusNode: _focusNode,
                                maxLines: 4,
                                maxLength: 300,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: hasImage ? tr('decoder_hint_with_image') : tr('decoder_hint'),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Card action bar: Upload screenshot button + char counter
                              Row(
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      onTap: _isLoading ? null : _pickImage,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: hasImage
                                              ? AppColors.warmBeige.withValues(alpha: 0.15)
                                              : AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: hasImage
                                                ? AppColors.warmBeige
                                                : AppColors.borderSubtle,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 15,
                                              color: hasImage ? AppColors.warmBeige : AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                hasImage ? tr('screenshot_attached') : tr('btn_upload_screenshot'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: hasImage ? AppColors.warmBeige : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    tr('char_counter', [textLength.toString()]),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

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
                                              Flexible(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 250),
                                                  child: Text(
                                                    _getLoadingText(),
                                                    key: ValueKey<String>(_getLoadingText()),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
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
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, size: 16, color: AppColors.warmBeige),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      tr('recent_history'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_historyList.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  tr('history_count', [_historyList.length.toString()]),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
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
