import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/landing_screen.dart';
import '../../subscription/widgets/pro_paywall_modal.dart';

class SettingsSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const SettingsSheet({
    super.key,
    required this.onSaved,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  String _provider = 'gemini';
  bool _enableMock = true;
  String? _userEmail;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    AppLocale.instance.addListener(_onLocaleChanged);
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    AppLocale.instance.removeListener(_onLocaleChanged);
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCurrentSettings() async {
    final storage = await StorageService.getInstance();
    final settings = storage.getSettings();
    setState(() {
      _apiKeyController.text = settings.apiKey;
      _baseUrlController.text = settings.baseUrl;
      _modelController.text = settings.modelName;
      _provider = settings.provider;
      _enableMock = settings.enableMockSimulation;
      _userEmail = storage.getUserEmail();
      _isPro = storage.isUserPro();
    });
  }

  void _goToWelcome() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _signOut() async {
    final storage = await StorageService.getInstance();
    await storage.setUserLoggedOut();
    _goToWelcome();
  }

  void _onProviderChanged(String provider) {
    setState(() {
      _provider = provider;
      if (provider == 'gemini') {
        _baseUrlController.text = 'https://generativelanguage.googleapis.com';
        _modelController.text = 'gemini-3.5-flash';
      } else {
        _baseUrlController.text = 'https://api.openai.com/v1';
        _modelController.text = 'gpt-4o-mini';
      }
    });
  }

  Future<void> _saveSettings() async {
    final storage = await StorageService.getInstance();
    final updated = AppSettings(
      apiKey: _apiKeyController.text.trim(),
      provider: _provider,
      baseUrl: _baseUrlController.text.trim(),
      modelName: _modelController.text.trim(),
      enableMockSimulation: _enableMock,
    );
    await storage.saveSettings(updated);
    widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('settings_saved')),
          backgroundColor: AppColors.surfaceHighlight,
        ),
      );
    }
  }

  Future<void> _resetQuota() async {
    final storage = await StorageService.getInstance();
    await storage.resetDailyQuota();
    widget.onSaved();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('quota_reset_toast')),
          backgroundColor: AppColors.empathyGreenSubtle,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 20, color: AppColors.warmBeige),
                    const SizedBox(width: 8),
                    Text(
                      tr('settings_title'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selector Section
            Text(
              tr('language_select'),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppLocale.supportedLanguages.map((lang) {
                final isSelected = lang.code == AppLocale.instance.currentCode;
                return InkWell(
                  onTap: () {
                    AppLocale.instance.setLanguage(lang.code);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warmBeige.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.warmBeige : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          lang.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.warmBeige : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Provider selection
            Text(
              tr('api_protocol'),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    'Google Gemini API',
                    _provider == 'gemini',
                    () => _onProviderChanged('gemini'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChoiceChip(
                    'OpenAI Compatible',
                    _provider == 'openai',
                    () => _onProviderChanged('openai'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // API Key field
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: tr('api_key_label'),
                hintText: _provider == 'gemini' ? 'AIzaSy...' : 'sk-...',
                prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppColors.warmBeige),
                helperText: tr('api_key_helper'),
                helperStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            // Base URL field
            TextField(
              controller: _baseUrlController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: tr('base_url_label'),
                prefixIcon: const Icon(Icons.dns_rounded, size: 18, color: AppColors.amberSand),
              ),
            ),
            const SizedBox(height: 12),

            // Model Name field
            TextField(
              controller: _modelController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: tr('model_label'),
                prefixIcon: const Icon(Icons.psychology_rounded, size: 18, color: AppColors.humorViolet),
              ),
            ),
            const SizedBox(height: 14),

            // Mock Simulator Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('mock_mode_title'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('mock_mode_desc'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableMock,
                    activeThumbColor: AppColors.warmBeige,
                    onChanged: (val) {
                      setState(() {
                        _enableMock = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Developer Testing: Reset Quota
            OutlinedButton.icon(
              onPressed: _resetQuota,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(tr('reset_quota_btn')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amberSand,
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),

            // Pro Membership Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isPro ? AppColors.warmBeige.withValues(alpha: 0.12) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPro ? AppColors.warmBeige.withValues(alpha: 0.5) : AppColors.borderSubtle,
                  width: _isPro ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isPro ? Icons.workspace_premium_rounded : Icons.diamond_outlined,
                          size: 22,
                          color: AppColors.warmBeige,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPro ? tr('pro_member_badge') : 'EmpathIQ Free',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isPro ? tr('pro_unlimited') : tr('landing_guest_desc'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ProPaywallModal.show(context, onSubscribed: () {
                        _loadCurrentSettings();
                        widget.onSaved();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmBeige,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isPro ? 'Manage' : tr('upgrade_pro_btn'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Account / Welcome Page Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle_outlined, size: 20, color: AppColors.warmBeige),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _userEmail != null
                                ? tr('logged_in_as', [_userEmail!])
                                : tr('landing_tab_guest'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _userEmail != null ? _signOut : _goToWelcome,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _userEmail != null ? tr('sign_out') : tr('back_to_welcome'),
                      style: const TextStyle(color: AppColors.warmBeige, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmBeige,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(tr('save_settings_btn'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warmBeige.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.warmBeige : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.warmBeige : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
