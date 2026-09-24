import 'package:flutter/material.dart';
import '../../../core/constants/dilemma_seed.dart';
import '../../../core/models/dilemma_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

class DilemmaChallengeScreen extends StatefulWidget {
  final DilemmaModel? initialDilemma;

  const DilemmaChallengeScreen({
    super.key,
    this.initialDilemma,
  });

  @override
  State<DilemmaChallengeScreen> createState() => _DilemmaChallengeScreenState();
}

class _DilemmaChallengeScreenState extends State<DilemmaChallengeScreen> {
  int _currentIndex = 0;
  DilemmaOption? _selectedOption;
  bool _hasRevealed = false;

  List<DilemmaModel> get _dilemmas => DilemmaSeed.dilemmas;
  DilemmaModel get _currentDilemma => _dilemmas[_currentIndex];

  void _selectOption(DilemmaOption option) {
    if (_hasRevealed) return;
    setState(() {
      _selectedOption = option;
      _hasRevealed = true;
    });

    // Mark today's check-in
    StorageService.getInstance().then((storage) {
      storage.checkInToday();
    });
  }

  void _nextDilemma() {
    if (_currentIndex < _dilemmas.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasRevealed = false;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dilemma = _currentDilemma;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('今日社交残局挑战'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amberSand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.amberSand.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    dilemma.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberSand,
                    ),
                  ),
                ),
                Text(
                  '第 ${_currentIndex + 1} / ${_dilemmas.length} 局',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              dilemma.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Scenario background
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dilemma.scenario,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warmBeige.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      dilemma.spokenText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.warmBeige,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prompt text
            Row(
              children: const [
                Icon(Icons.touch_app_rounded, size: 16, color: AppColors.warmBeige),
                SizedBox(width: 6),
                Text(
                  '此时你会如何回应破局？（点击选择）',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Options List
            ...dilemma.options.map((option) {
              final isChosen = _selectedOption?.id == option.id;
              final showResult = _hasRevealed;

              Color borderColor = AppColors.borderSubtle;
              Color bgColor = AppColors.surface;

              if (showResult) {
                if (option.isOptimal) {
                  borderColor = AppColors.empathyGreen;
                  bgColor = AppColors.empathyGreenSubtle;
                } else if (isChosen) {
                  borderColor = AppColors.flammableRed;
                  bgColor = AppColors.flammableRedSubtle;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _selectOption(option),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: isChosen || (showResult && option.isOptimal) ? 1.5 : 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isChosen ? AppColors.warmBeige : AppColors.surfaceElevated,
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Center(
                                child: Text(
                                  option.id.replaceAll('opt_', ''),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isChosen ? AppColors.background : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isChosen ? AppColors.textPrimary : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (showResult && option.isOptimal)
                              const Icon(Icons.check_circle_rounded, color: AppColors.empathyGreen, size: 20)
                            else if (showResult && isChosen && !option.isOptimal)
                              const Icon(Icons.cancel_rounded, color: AppColors.flammableRed, size: 20),
                          ],
                        ),

                        // Revealed Feedback
                        if (showResult && (isChosen || option.isOptimal)) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.feedback,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: option.isOptimal ? AppColors.empathyGreen : const Color(0xFFFCA5A5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '机制解析：${option.mechanism}',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 18),

            // Next or Finish Button
            if (_hasRevealed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextDilemma,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmBeige,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _currentIndex < _dilemmas.length - 1 ? '挑战下一局' : '完成今日残局挑战',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
