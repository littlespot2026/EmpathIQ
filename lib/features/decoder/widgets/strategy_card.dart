import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../subscription/widgets/pro_paywall_modal.dart';

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
  bool _isUserPro = false;

  @override
  void initState() {
    super.initState();
    _isUserPro = StorageService.proStatusNotifier.value;
    StorageService.proStatusNotifier.addListener(_onProStatusChanged);
    _checkProStatus();
  }

  @override
  void dispose() {
    StorageService.proStatusNotifier.removeListener(_onProStatusChanged);
    super.dispose();
  }

  void _onProStatusChanged() {
    if (mounted) {
      setState(() {
        _isUserPro = StorageService.proStatusNotifier.value;
      });
    }
  }

  Future<void> _checkProStatus() async {
    final storage = await StorageService.getInstance();
    if (mounted) {
      setState(() {
        _isUserPro = storage.isUserPro();
      });
    }
  }

  bool get _isLocked => widget.index > 0 && !_isUserPro;

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
    if (widget.strategy.type == 'empathy') return tr('strategy_a');
    if (widget.strategy.type == 'humor') return tr('strategy_b');
    if (widget.strategy.type == 'boundary') return tr('strategy_c');
    final letters = ['A', 'B', 'C'];
    final letter = widget.index < letters.length ? letters[widget.index] : '';
    return 'Strategy $letter · ${widget.strategy.title}';
  }

  void _handleCopy() {
    if (_isLocked) {
      ProPaywallModal.show(context, onSubscribed: _checkProStatus);
      return;
    }

    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: widget.strategy.actionText));
    setState(() {
      _isCopied = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.empathyGreen, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr('copy_success_toast'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isLocked
              ? AppColors.warmBeige.withValues(alpha: 0.35)
              : (_isCopied ? _accentColor : AppColors.borderSubtle),
          width: _isCopied ? 1.5 : 1,
        ),
        boxShadow: _isLocked
            ? [
                BoxShadow(
                  color: AppColors.warmBeige.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
                    if (_isUserPro && widget.index > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warmBeige.withValues(alpha: 0.4),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded, size: 11, color: AppColors.warmBeige),
                            const SizedBox(width: 3),
                            Text(
                              tr('pro_member_badge'),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warmBeige,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Copy Button with animated checkmark or Lock icon
                InkWell(
                  onTap: _handleCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isLocked
                          ? AppColors.warmBeige.withValues(alpha: 0.15)
                          : (_isCopied
                              ? AppColors.empathyGreen.withValues(alpha: 0.18)
                              : AppColors.surfaceElevated),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isLocked
                            ? AppColors.warmBeige.withValues(alpha: 0.4)
                            : (_isCopied ? AppColors.empathyGreen : AppColors.borderLight),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLocked) ...[
                          const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.warmBeige),
                          const SizedBox(width: 4),
                          const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warmBeige,
                            ),
                          ),
                        ] else ...[
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                              key: ValueKey<bool>(_isCopied),
                              size: 13,
                              color: _isCopied ? AppColors.empathyGreen : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isCopied ? tr('copied') : tr('one_click_copy'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _isCopied ? AppColors.empathyGreen : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content: Blurred stack if locked, normal if unlocked
          if (_isLocked)
            Container(
              constraints: const BoxConstraints(minHeight: 140),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Layer 1: Frosted Blurred dummy content preview
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.strategy.actionText,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Glassmorphic Lock Overlay with CTA
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ProPaywallModal.show(context, onSubscribed: _checkProStatus);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warmBeige.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_rounded, size: 14, color: AppColors.warmBeige),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    tr('pro_locked_badge'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.warmBeige,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('pro_locked_desc'),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ProPaywallModal.show(context, onSubscribed: _checkProStatus);
                              },
                              icon: const Icon(Icons.diamond_rounded, size: 13),
                              label: Text(
                                tr('pro_unlock_btn'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warmBeige,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Normal Unlocked View
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
                              tr('why_effective'),
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
        ],
      ),
    );

    if (_isLocked) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ProPaywallModal.show(context, onSubscribed: _checkProStatus);
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
