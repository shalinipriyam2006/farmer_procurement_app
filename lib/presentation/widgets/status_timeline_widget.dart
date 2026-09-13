import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';

class StatusTimelineWidget extends StatelessWidget {
  final List<StageProgressInfo> stages;
  final AppLanguage language;

  const StatusTimelineWidget({
    super.key,
    required this.stages,
    required this.language,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isLast = index == stages.length - 1;

        Color nodeBgColor;
        Widget iconWidget;

        if (stage.isCompleted) {
          nodeBgColor = AppColors.success;
          iconWidget = const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 20,
          );
        } else if (stage.isCurrent) {
          nodeBgColor = AppColors.secondary;
          iconWidget = Icon(stage.icon, color: Colors.white, size: 19);
        } else {
          nodeBgColor = Colors.grey.shade200;
          iconWidget = Icon(stage.icon, color: Colors.grey.shade500, size: 18);
        }

        final timeStr = _formatTime(stage.completedTime);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node & Connecting Line
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: nodeBgColor,
                        shape: BoxShape.circle,
                        border: stage.isCurrent
                            ? Border.all(
                                color: AppColors.secondaryLight,
                                width: 3.5,
                              )
                            : (stage.isCompleted
                                  ? Border.all(
                                      color: Colors.green.shade600,
                                      width: 1.5,
                                    )
                                  : Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    )),
                        boxShadow: stage.isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(child: iconWidget),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 3.5,
                          color: stage.isCompleted
                              ? AppColors.success
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Stage Details Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: stage.isCurrent
                          ? AppColors.secondaryContainer.withValues(alpha: 0.45)
                          : (stage.isCompleted
                                ? Colors.white
                                : AppColors.surfaceVariant),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: stage.isCurrent
                            ? AppColors.secondary
                            : (stage.isCompleted
                                  ? AppColors.success.withValues(alpha: 0.35)
                                  : AppColors.divider),
                        width: stage.isCurrent ? 2.0 : 1,
                      ),
                      boxShadow: stage.isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}. ${stage.localizedTitle(language)}',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: stage.isCurrent
                                      ? AppColors.secondary
                                      : (stage.isCompleted
                                            ? AppColors.textPrimary
                                            : AppColors.textTertiary),
                                ),
                              ),
                            ),
                            if (stage.isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      language == AppLanguage.tamil
                                          ? 'செயலில்'
                                          : 'ACTIVE',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (stage.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green.shade700,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      language == AppLanguage.tamil
                                          ? 'முடிந்தது'
                                          : 'Done',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stage.localizedDescription(language),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: stage.isCompleted || stage.isCurrent
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                            height: 1.35,
                          ),
                        ),
                        if (timeStr.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: stage.isCurrent
                                    ? AppColors.secondary
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${language == AppLanguage.tamil ? 'நேரம்' : 'Time'}: $timeStr',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: stage.isCurrent
                                      ? AppColors.secondary
                                      : AppColors.textTertiary,
                                  fontWeight: stage.isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (stage.officerRemark != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.55,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  size: 15,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    stage.officerRemark!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
