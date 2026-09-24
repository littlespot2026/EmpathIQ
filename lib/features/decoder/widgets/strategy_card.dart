import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/theme/app_colors.dart';

class StrategyCard extends StatefulWidget {
  final DecodeStrategy strategy;
  final int index;

  const StrategyCard({
    super.key,
    required this.strategy,
    required this.index,
  });

  @override
  State<StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<StrategyCard>
    with SingleTickerProviderStateMixin {
  bool _isCopied = false;
  bool _isExpanded = false;

  Color get _accentColor {
    switch (widget.strategy.type) {
      case 'empathy':
        return AppColors.empathyGreen;
      case 'humor':
        return AppColors.humorViolet;
      case 'boundary':
        return AppColors.boundaryAmber;
      default:
        return AppColors.warmBeige;
    }
  }

  Color get _subtleColor {
    switch (widget.strategy.type) {
      case 'empathy':
        return AppColors.empathyGreenSubtle;
      case 'humor':
        return AppColors.humorVioletSubtle;
      case 'boundary':
        return AppColors.boundaryAmberSubtle;
      default:
        return AppColors.surfaceElevated;
    }
  }

  IconData get _strategyIcon {
    switch (widget.strategy.type) {
      case 'empathy':
        return Icons.favorite_rounded;
      case 'humor':
        return Icons.sentiment_very_satisfied_rounded;
      case 'boundary':
        return Icons.shield_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  String get _tagTitle {
    final letters = ['A', 'B', 'C'];
    final letter = widget.index < letters.length ? letters[widget.index] : '';
    return '策略 $letter · ${widget.strategy.title}';
  }

  void _handleCopy() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.strategy.actionText));
    setState(() {
      _isCopied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制：${widget.strategy.title} 回复语'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCopied ? _accentColor : AppColors.borderSubtle,
          width: _isCopied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _subtleColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_strategyIcon, size: 13, color: _accentColor),
                          const SizedBox(width: 4),
                          Text(
                            _tagTitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Copy Button with animated checkmark
                InkWell(
                  onTap: _handleCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isCopied
                          ? _accentColor.withValues(alpha: 0.2)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isCopied ? _accentColor : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                            key: ValueKey<bool>(_isCopied),
                            size: 13,
                            color: _isCopied ? _accentColor : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isCopied ? '已复制' : '一键复制',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _isCopied ? _accentColor : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action speech block
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, width: 0.6),
              ),
              child: SelectableText(
                widget.strategy.actionText,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          // Collapsible: Why it works (Psychology mechanism)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology_alt_rounded,
                            size: 14,
                            color: _isExpanded ? AppColors.warmBeige : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '为什么有效（心理机制与底层逻辑）',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _isExpanded ? AppColors.warmBeige : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          widget.strategy.mechanism,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
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
