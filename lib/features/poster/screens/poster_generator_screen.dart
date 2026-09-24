import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/export_helper.dart';

class PosterGeneratorScreen extends StatefulWidget {
  final DecodeResult result;

  const PosterGeneratorScreen({
    super.key,
    required this.result,
  });

  @override
  State<PosterGeneratorScreen> createState() => _PosterGeneratorScreenState();
}

class _PosterGeneratorScreenState extends State<PosterGeneratorScreen> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isExporting = false;
  String _selectedStrategyType = 'empathy';

  DecodeStrategy get _currentStrategy {
    if (_selectedStrategyType == 'empathy') {
      return widget.result.empathyStrategy ?? widget.result.strategies.first;
    } else if (_selectedStrategyType == 'humor') {
      return widget.result.humorStrategy ?? widget.result.strategies.first;
    } else {
      return widget.result.boundaryStrategy ?? widget.result.strategies.first;
    }
  }

  Future<void> _exportPoster() async {
    setState(() {
      _isExporting = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary =
          _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Canvas boundary unavailable');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final filename =
            'EmpathIQ_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';

        ExportHelper.downloadImage(bytes, filename);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.empathyGreen, size: 18),
                  SizedBox(width: 8),
                  Text('9:16 长图已生成并保存！'),
                ],
              ),
              backgroundColor: AppColors.surfaceHighlight,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: AppColors.flammableRedSubtle,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempColor = AppColors.getTemperatureColor(widget.result.temperature);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('生成分享长图 (9:16)'),
        actions: [
          IconButton(
            tooltip: '保存长图',
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.warmBeige),
                    ),
                  )
                : const Icon(Icons.file_download_outlined, color: AppColors.warmBeige),
            onPressed: _isExporting ? null : _exportPoster,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Strategy Selector Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildStrategyTab('empathy', '共情破局', AppColors.empathyGreen),
                  _buildStrategyTab('humor', '幽默破冰', AppColors.humorViolet),
                  _buildStrategyTab('boundary', '温和界限', AppColors.boundaryAmber),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // The 9:16 Canvas Card inside RepaintBoundary
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                child: RepaintBoundary(
                  key: _posterKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF14171E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmBeige,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.psychology_rounded,
                                    size: 16,
                                    color: AppColors.background,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'EmpathIQ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.warmBeige,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    Text(
                                      '看穿言外之意 · 接住真实情绪',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Rank Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.amberSand.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.amberSand.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'Lv.4 洞悉者',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.amberSand,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Relationship tag & Original speech
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.forum_rounded, size: 12, color: AppColors.warmBeige),
                                  const SizedBox(width: 4),
                                  Text(
                                    '情境对话 [${widget.result.relationship}]',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warmBeige,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '“${widget.result.inputText}”',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Iceberg Indicators Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('情绪温度', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${widget.result.temperature}° ${widget.result.temperatureLevel}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: tempColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('心防戒备值', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${widget.result.defensePercent}%',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFA78BFA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Subtext Insight
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amberSand.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.amberSand.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '【潜台词动机透视】',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.amberSand,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.result.realSubtext,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warmBeigeLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Golden Breaking Quote
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.warmBeige),
                                  const SizedBox(width: 4),
                                  Text(
                                    '破局金句 · ${_currentStrategy.title}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warmBeige,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _currentStrategy.actionText,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '心理底层机制：${_currentStrategy.mechanism}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  height: 1.4,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Card Footer: Watermark & QR representation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '长按扫码 · 免费测测你的人际潜台词',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('yyyy.MM.dd').format(widget.result.createdAt),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            // Simulated clean QR icon container
                            Container(
                              width: 38,
                              height: 38,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                size: 30,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Big Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportPoster,
                icon: const Icon(Icons.download_rounded),
                label: Text(_isExporting ? '生成导出中...' : '保存 9:16 长图至相册/设备'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmBeige,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyTab(String type, String label, Color color) {
    final isSelected = _selectedStrategyType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStrategyType = type;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
