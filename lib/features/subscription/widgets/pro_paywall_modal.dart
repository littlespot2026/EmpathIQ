import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';

class ProPaywallModal extends StatefulWidget {
  final VoidCallback? onSubscribed;

  const ProPaywallModal({
    super.key,
    this.onSubscribed,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onSubscribed}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProPaywallModal(onSubscribed: onSubscribed),
    );
  }

  @override
  State<ProPaywallModal> createState() => _ProPaywallModalState();
}

class _ProPaywallModalState extends State<ProPaywallModal> {
  String _selectedPlan = 'yearly'; // 'yearly', 'weekly', 'monthly', 'pack_10'
  bool _isProcessing = false;

  Future<void> _handleCheckout({bool forceSandbox = true}) async {
    setState(() {
      _isProcessing = true;
    });

    final success = await PaymentService.instance.processCheckout(
      context: context,
      planId: _selectedPlan,
      forceSandbox: forceSandbox,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        final msg = _selectedPlan == 'pack_10'
            ? tr('purchase_pack_success')
            : tr('purchase_success');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.warmBeige,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onSubscribed?.call();
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isProcessing = true;
    });

    final isPro = await PaymentService.instance.restorePurchases();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (isPro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('purchase_success')),
            backgroundColor: AppColors.warmBeige,
          ),
        );
        widget.onSubscribed?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscription found to restore.'),
            backgroundColor: AppColors.surfaceHighlight,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
          maxWidth: 520,
        ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.warmBeige.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient radial glow
          Positioned(
            top: -50,
            right: -30,
            width: 200,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.warmBeige.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top close pill & dismiss button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warmBeige.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.warmBeige),
                            const SizedBox(width: 5),
                            Text(
                              tr('pro_badge'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warmBeige,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Diamond Logo & Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warmBeige,
                          AppColors.amberSand,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warmBeige.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      size: 34,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    tr('pro_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr('pro_slogan'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.warmBeigeLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Feature Checklist
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(tr('pro_feature_1')),
                        const SizedBox(height: 8),
                        _buildFeatureRow(tr('pro_feature_2')),
                        const SizedBox(height: 8),
                        _buildFeatureRow(tr('pro_feature_3')),
                        const SizedBox(height: 8),
                        _buildFeatureRow(tr('pro_feature_4')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Subscription Tier Cards
                  // Option 1: Yearly (Best Value)
                  _buildPlanOption(
                    id: 'yearly',
                    title: tr('plan_yearly'),
                    price: tr('plan_yearly_price'),
                    subtitle: tr('plan_yearly_sub'),
                    badgeText: tr('plan_yearly_badge'),
                    isHighlight: true,
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Weekly (3-Day Free Trial)
                  _buildPlanOption(
                    id: 'weekly',
                    title: tr('plan_weekly'),
                    price: tr('plan_weekly_price'),
                    subtitle: tr('plan_weekly_trial'),
                    badgeText: '3-DAY TRIAL',
                  ),
                  const SizedBox(height: 10),

                  // Option 3: Monthly (Most Popular)
                  _buildPlanOption(
                    id: 'monthly',
                    title: tr('plan_monthly'),
                    price: tr('plan_monthly_price'),
                    subtitle: 'Full flexible monthly access',
                    badgeText: tr('plan_monthly_badge'),
                  ),
                  const SizedBox(height: 10),

                  // Option 4: Emergency 10-Pack (One-time)
                  _buildPlanOption(
                    id: 'pack_10',
                    title: tr('plan_pack'),
                    price: tr('plan_pack_price'),
                    subtitle: tr('plan_pack_desc'),
                    badgeText: 'NO SUB',
                  ),
                  const SizedBox(height: 20),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _handleCheckout(forceSandbox: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmBeige,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.warmBeige.withValues(alpha: 0.5),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                              ),
                            )
                          : Text(
                              _selectedPlan == 'weekly'
                                  ? tr('btn_start_trial')
                                  : (_selectedPlan == 'pack_10'
                                      ? tr('btn_buy_pack')
                                      : tr('btn_upgrade_pro')),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Encrypted Notice
                  Text(
                    tr('cancel_anytime'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Utilities: Restore purchases & Sandbox Toggle
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        onPressed: _isProcessing ? null : _handleRestore,
                        child: Text(
                          tr('restore_purchase'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isProcessing ? null : () => _handleCheckout(forceSandbox: true),
                        icon: const Icon(Icons.bolt_rounded, size: 14, color: AppColors.warmBeige),
                        label: Text(
                          tr('simulate_payment'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warmBeige,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_rounded, size: 15, color: AppColors.warmBeige),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanOption({
    required String id,
    required String title,
    required String price,
    required String subtitle,
    required String badgeText,
    bool isHighlight = false,
  }) {
    final isSelected = _selectedPlan == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlan = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warmBeige.withValues(alpha: 0.12)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.warmBeige
                : (isHighlight
                    ? AppColors.warmBeige.withValues(alpha: 0.4)
                    : AppColors.borderSubtle),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.warmBeige.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.warmBeige : AppColors.borderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.warmBeige : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 13, color: AppColors.background),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? AppColors.warmBeige
                              : AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isHighlight
                                ? AppColors.background
                                : AppColors.warmBeigeLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              price,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.warmBeige : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
