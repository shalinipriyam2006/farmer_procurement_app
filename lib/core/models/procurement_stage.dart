import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';

enum ProcurementStageType {
  tokenGenerated,
  waiting,
  called,
  weighing,
  qualityCheck,
  accepted,
  paymentProcessing,
  paymentCompleted,
}

class StageProgressInfo {
  final ProcurementStageType stage;
  final String titleKey;
  final String descriptionEn;
  final String descriptionTa;
  final DateTime? completedTime;
  final bool isCurrent;
  final bool isCompleted;
  final String? officerRemark;
  final IconData icon;

  const StageProgressInfo({
    required this.stage,
    required this.titleKey,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.icon,
    this.completedTime,
    this.isCurrent = false,
    this.isCompleted = false,
    this.officerRemark,
  });

  String localizedTitle(AppLanguage language) {
    return AppTranslations.text(titleKey, language);
  }

  String localizedDescription(AppLanguage language) {
    return language == AppLanguage.tamil ? descriptionTa : descriptionEn;
  }
}
