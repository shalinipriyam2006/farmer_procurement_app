import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/widgets/status_timeline_widget.dart';
import 'package:farmer_procurement_app/presentation/screens/payment/payment_details_screen.dart';

class ProcurementStatusScreen extends StatelessWidget {
  const ProcurementStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        final stages = repo.getStageProgressList();
        final token = repo.activeToken;
        final currentStage = token?.currentStage ?? ProcurementStageType.called;
        final stagesList = ProcurementStageType.values;
        final currentIdx = stagesList.indexOf(currentStage);
        final completedCount =
            currentStage == ProcurementStageType.paymentCompleted
            ? 8
            : currentIdx;
        final progressRatio = (completedCount / 8).clamp(0.125, 1.0);

        final currentStageInfo = stages.firstWhere(
          (s) => s.stage == currentStage,
          orElse: () => stages[0],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Summary Hero Banner & Progress Meter
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.timeline_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil
                                    ? 'கொள்முதல் நேரலை நிலை'
                                    : 'Procurement Lifecycle Status',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                token != null
                                    ? 'Token ${token.tokenNumber} • ${isTamil ? token.centreNameTa : token.centreNameEn}'
                                    : 'No active lot',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Progress Bar Meter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTamil
                              ? 'ஒட்டுமொத்த முன்னேற்றம் (${(progressRatio * 100).toInt()}%)'
                              : 'Overall Progress (${(progressRatio * 100).toInt()}%)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isTamil
                              ? 'நிலை ${currentStage == ProcurementStageType.paymentCompleted ? 8 : currentIdx + 1} / 8'
                              : 'Stage ${currentStage == ProcurementStageType.paymentCompleted ? 8 : currentIdx + 1} of 8',
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Active Stage Highlight Box
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(
                    color: AppColors.secondary,
                    width: 1.5,
                  ),
                ),
                color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          currentStageInfo.icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTamil
                                  ? 'தற்போது இயங்கும் நிலை'
                                  : 'Current Active Status',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentStageInfo.localizedTitle(lang),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentStageInfo.localizedDescription(lang),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Complete 8-Stage Timeline Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isTamil
                                  ? '8-நிலை நேரலை காலக்கோடு'
                                  : 'Complete 8-Stage Flow',
                              style: const TextStyle(
                                fontSize: 18.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isTamil ? 'நேரலை புதுப்பிப்பு' : 'Live Sync',
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      StatusTimelineWidget(stages: stages, language: lang),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 4. View Payment Slip Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentDetailsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: Text(
                  isTamil
                      ? 'கொள்முதல் பண ரசீதை பார்க்கவும்'
                      : 'View Procurement Payment Slip',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
