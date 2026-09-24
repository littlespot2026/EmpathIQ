import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/theme/app_colors.dart';

class SandboxChatBubble extends StatelessWidget {
  final ChatMessage message;

  const SandboxChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Feedback Badge above NPC bubble
          if (!isUser && message.feedbackTag != null && message.feedbackTag!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (message.defenseDelta ?? 0) < 0
                      ? AppColors.empathyGreenSubtle
                      : AppColors.flammableRedSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (message.defenseDelta ?? 0) < 0
                        ? AppColors.empathyGreen.withValues(alpha: 0.5)
                        : AppColors.flammableRed.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  message.feedbackTag!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: (message.defenseDelta ?? 0) < 0
                        ? AppColors.empathyGreen
                        : const Color(0xFFFCA5A5),
                  ),
                ),
              ),
            ),

          // Chat Bubble Row
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight, width: 0.8),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 16, color: AppColors.amberSand),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Bubble Content
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.warmBeige : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? AppColors.warmBeige : AppColors.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: isUser ? AppColors.background : AppColors.textPrimary,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isUser
                              ? AppColors.background.withValues(alpha: 0.6)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.warmBeige.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warmBeige, width: 1),
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology, size: 16, color: AppColors.warmBeige),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
