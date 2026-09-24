import 'package:flutter/material.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/iceberg_gauge.dart';
import '../widgets/strategy_card.dart';
import '../../poster/screens/poster_generator_screen.dart';
import '../../sandbox/screens/conflict_sandbox_screen.dart';

class DecoderResultScreen extends StatefulWidget {
  final DecodeResult result;

  const DecoderResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<DecoderResultScreen> createState() => _DecoderResultScreenState();
}

class _DecoderResultScreenState extends State<DecoderResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToPoster() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosterGeneratorScreen(result: widget.result),
      ),
    );
  }

  void _navigateToSandbox() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConflictSandboxScreen(decodeResult: widget.result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('潜台词与情绪冰山透视'),
        actions: [
          IconButton(
            tooltip: '生成分享卡片',
            icon: const Icon(Icons.share_rounded, color: AppColors.warmBeige),
            onPressed: _navigateToPoster,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Relationship & Header Capsule
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warmBeige.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '人际维度 · ${widget.result.relationship}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warmBeige,
                          ),
                        ),
                      ),
                      Text(
                        'EmpathIQ 深度认知解析',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 1. Emotional Iceberg Card
                  IcebergGauge(result: widget.result),
                  const SizedBox(height: 20),

                  // Section Title: 实战破局三策
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, size: 18, color: AppColors.amberSand),
                      SizedBox(width: 8),
                      Text(
                        '实战破局三策',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '针对被动攻击或心防退缩，提供三套不同维度的即时回复与心理学机制：',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Battle-Tested 3 Strategies
                  if (widget.result.strategies.isNotEmpty)
                    ...widget.result.strategies.asMap().entries.map(
                          (entry) => StrategyCard(
                            strategy: entry.value,
                            index: entry.key,
                          ),
                        )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('暂无策略方案', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(
                top: BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Button 1: Save Share Poster
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _navigateToPoster,
                      icon: const Icon(Icons.photo_album_outlined, size: 17),
                      label: const Text('保存分享卡片'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warmBeige,
                        side: const BorderSide(color: AppColors.warmBeige, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Button 2: Enter Conflict Sandbox
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToSandbox,
                      icon: const Icon(Icons.sports_kabaddi_rounded, size: 18),
                      label: const Text('带入情境对练'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmBeige,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
