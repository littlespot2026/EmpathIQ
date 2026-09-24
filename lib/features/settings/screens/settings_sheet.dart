import 'package:flutter/material.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
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
    });
  }

  void _onProviderChanged(String provider) {
    setState(() {
      _provider = provider;
      if (provider == 'gemini') {
        _baseUrlController.text = 'https://generativelanguage.googleapis.com';
        _modelController.text = 'gemini-1.5-flash';
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
        const SnackBar(
          content: Text('配置已保存生效！'),
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
        const SnackBar(
          content: Text('已重置今日透视配额为 3 次！'),
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
                  children: const [
                    Icon(Icons.tune_rounded, size: 20, color: AppColors.warmBeige),
                    SizedBox(width: 8),
                    Text(
                      'AI 引擎与配置',
                      style: TextStyle(
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

            // Provider selection
            const Text(
              '接口协议 (API Protocol)',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
                    'OpenAI 格式接口',
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
                labelText: 'API 密钥 (API_KEY)',
                hintText: _provider == 'gemini' ? 'AIzaSy...' : 'sk-...',
                prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppColors.warmBeige),
                helperText: '密钥仅保存在设备本地，绝不上云',
                helperStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            // Base URL field
            TextField(
              controller: _baseUrlController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'API 端点 (Base URL)',
                prefixIcon: Icon(Icons.dns_rounded, size: 18, color: AppColors.amberSand),
              ),
            ),
            const SizedBox(height: 12),

            // Model Name field
            TextField(
              controller: _modelController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '模型名称 (Model)',
                prefixIcon: Icon(Icons.psychology_rounded, size: 18, color: AppColors.humorViolet),
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
                      children: const [
                        Text(
                          '免 Key 智能心理学沙盒模式',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '未填 Key 或断网时，自动启用高质量本地情境引擎',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
              label: const Text('【测试调试】重置今日 3 次免费额度'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amberSand,
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),

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
                child: const Text('保存并应用设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
