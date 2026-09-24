import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../home/widgets/language_selector_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late Animation<double> _ambientAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _activeTab = 0; // 0: Quick Guest, 1: Login

  int _activeQuoteIndex = 0;
  Timer? _quoteTimer;

  final List<Map<String, dynamic>> _demoQuotes = [
    {
      'quoteKey': 'landing_quote_1',
      'subKey': 'landing_quote_1_sub',
      'temp': 82,
      'status': 'temp_flammable',
      'statusColor': AppColors.flammableRed,
      'context': 'rel_partner',
    },
    {
      'quoteKey': 'landing_quote_2',
      'subKey': 'landing_quote_2_sub',
      'temp': 65,
      'status': 'temp_agitated',
      'statusColor': AppColors.amberSand,
      'context': 'rel_workplace',
    },
    {
      'quoteKey': 'landing_quote_3',
      'subKey': 'landing_quote_3_sub',
      'temp': 30,
      'status': 'temp_cold',
      'statusColor': AppColors.coldBlue,
      'context': 'rel_friend',
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLocale.instance.addListener(_onLocaleChanged);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _ambientAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOut,
    );

    // Auto-advance quotes carousel
    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _activeQuoteIndex = (_activeQuoteIndex + 1) % _demoQuotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    AppLocale.instance.removeListener(_onLocaleChanged);
    _ambientController.dispose();
    _quoteTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _enterAsGuest() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('landing_email_hint')),
          backgroundColor: AppColors.flammableRedSubtle,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final storage = await StorageService.getInstance();
    await storage.setUserLoggedIn(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _enterAsGuest();
    }
  }

  void _fillDemoAccount() {
    setState(() {
      _emailController.text = 'demo@empathiq.ai';
      _passwordController.text = 'empathiq2026';
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeQuote = _demoQuotes[_activeQuoteIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ambientAnimation,
          builder: (context, _) {
            final glowAlpha = 0.08 + (_ambientAnimation.value * 0.08);

            return Stack(
              children: [
                // Ambient dynamic background glow
                Positioned(
                  top: -80,
                  right: -60,
                  width: 320,
                  height: 320,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.warmBeige.withValues(alpha: glowAlpha * 1.5),
                          AppColors.amberSand.withValues(alpha: glowAlpha),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -80,
                  width: 340,
                  height: 340,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6366F1).withValues(alpha: glowAlpha * 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Scrollable Content
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        // Top Header: Logo + Language Switcher
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.warmBeige,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.warmBeige.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.psychology_rounded,
                                      size: 20,
                                      color: AppColors.background,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  const Text(
                                    'EmpathIQ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const LanguageSelectorButton(),
                            ],
                          ),
                        ),

                        // Scrollable Body
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),

                                // Hero Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.warmBeige.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.warmBeige.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 13,
                                        color: AppColors.warmBeige,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          tr('landing_badge'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.warmBeige,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Hero Title
                                Text(
                                  tr('landing_hero_title'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.25,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Hero Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    tr('landing_hero_sub'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Dynamic Live Subtext Scanner Card (Preview)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: (activeQuote['statusColor'] as Color).withValues(alpha: 0.4),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (activeQuote['statusColor'] as Color).withValues(alpha: 0.12),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Scanner status row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: activeQuote['statusColor'] as Color,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: (activeQuote['statusColor'] as Color).withValues(alpha: 0.6),
                                                        blurRadius: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                Flexible(
                                                  child: Text(
                                                    tr(activeQuote['context'] as String),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (activeQuote['statusColor'] as Color).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${activeQuote['temp']}°C · ${tr(activeQuote['status'] as String)}',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: activeQuote['statusColor'] as Color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Spoken Text
                                      Text(
                                        tr(activeQuote['quoteKey'] as String),
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Decoded Subtext Box
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.borderSubtle,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.lightbulb_rounded,
                                              size: 15,
                                              color: AppColors.warmBeige,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                tr(activeQuote['subKey'] as String),
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  height: 1.4,
                                                  color: AppColors.warmBeigeLight,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Carousel indicators
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(_demoQuotes.length, (index) {
                                          final isCur = index == _activeQuoteIndex;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _activeQuoteIndex = index;
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              width: isCur ? 18 : 6,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: isCur ? AppColors.warmBeige : AppColors.borderLight,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Glassmorphic Action Box: Dual Tab (Guest / Login)
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.warmBeige.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Tab Selector
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => setState(() => _activeTab = 0),
                                                borderRadius: BorderRadius.circular(10),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                                  decoration: BoxDecoration(
                                                    color: _activeTab == 0
                                                        ? AppColors.warmBeige
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      tr('landing_tab_guest'),
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: _activeTab == 0
                                                            ? AppColors.background
                                                            : AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => setState(() => _activeTab = 1),
                                                borderRadius: BorderRadius.circular(10),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                                  decoration: BoxDecoration(
                                                    color: _activeTab == 1
                                                        ? AppColors.warmBeige
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      tr('landing_tab_login'),
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: _activeTab == 1
                                                            ? AppColors.background
                                                            : AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Tab 0 Content: Instant Guest Experience
                                      if (_activeTab == 0) ...[
                                        Text(
                                          tr('landing_guest_desc'),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            height: 1.45,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _enterAsGuest,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.warmBeige,
                                              foregroundColor: AppColors.background,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              elevation: 4,
                                              shadowColor: AppColors.warmBeige.withValues(alpha: 0.4),
                                            ),
                                            child: Text(
                                              tr('landing_guest_btn'),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],

                                      // Tab 1 Content: Login & Account
                                      if (_activeTab == 1) ...[
                                        TextField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            hintText: tr('landing_email_hint'),
                                            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textMuted),
                                            filled: true,
                                            fillColor: AppColors.surfaceElevated,
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            hintText: tr('landing_password_hint'),
                                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textMuted),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                                size: 18,
                                                color: AppColors.textMuted,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: AppColors.surfaceElevated,
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: _fillDemoAccount,
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text(
                                                tr('landing_demo_login_btn'),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.warmBeige,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _handleLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.warmBeige,
                                              foregroundColor: AppColors.background,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                                                    ),
                                                  )
                                                : Text(
                                                    tr('landing_login_btn'),
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),

                                        // Social Login Buttons
                                        Center(
                                          child: Text(
                                            tr('landing_or_social'),
                                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: _enterAsGuest,
                                                icon: const Icon(Icons.g_mobiledata_rounded, size: 20),
                                                label: Text(
                                                  tr('landing_google'),
                                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.textPrimary,
                                                  side: const BorderSide(color: AppColors.borderLight),
                                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: _enterAsGuest,
                                                icon: const Icon(Icons.apple_rounded, size: 18),
                                                label: Text(
                                                  tr('landing_apple'),
                                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.textPrimary,
                                                  side: const BorderSide(color: AppColors.borderLight),
                                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Value Proposition Feature Highlights (3 Cards)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureCard(
                                        icon: Icons.water_drop_rounded,
                                        iconColor: AppColors.coldBlue,
                                        title: tr('landing_feature_1_title'),
                                        desc: tr('landing_feature_1_desc'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildFeatureCard(
                                        icon: Icons.thermostat_rounded,
                                        iconColor: AppColors.amberSand,
                                        title: tr('landing_feature_2_title'),
                                        desc: tr('landing_feature_2_desc'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildFeatureCard(
                                        icon: Icons.tips_and_updates_rounded,
                                        iconColor: AppColors.warmBeige,
                                        title: tr('landing_feature_3_title'),
                                        desc: tr('landing_feature_3_desc'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              height: 1.35,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
