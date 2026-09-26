import 'procurement_stage.dart';

enum TokenStatus {
  requested,
  generated,
  scheduled,
  waiting,
  called,
  processing,
  completed,
  missed,
  cancelled,
}

class TokenModel {
  final String id;
  final String tokenNumber;
  final String farmerId;
  final String farmerName;
  final String centreId;
  final String centreNameEn;
  final String centreNameTa;
  final String bookingDate;
  final String timeSlot;
  final String cropNameEn;
  final String cropNameTa;
  final double estimatedQuintals;
  final int estimatedBags;
  final int queuePosition;
  final ProcurementStageType currentStage;
  final TokenStatus status;
  final DateTime createdAt;

  final double? recordedWeightKg;
  final double? recordedQuintals;
  final int? recordedBags;
  final String? qualityStatus;
  final String? qualityGrade;
  final double? moisturePercentage;

  final Map<ProcurementStageType, DateTime> stageTimestamps;

  const TokenModel({
    required this.id,
    required this.tokenNumber,
    required this.farmerId,
    required this.farmerName,
    required this.centreId,
    required this.centreNameEn,
    required this.centreNameTa,
    required this.bookingDate,
    required this.timeSlot,
    required this.cropNameEn,
    required this.cropNameTa,
    required this.estimatedQuintals,
    required this.estimatedBags,
    required this.queuePosition,
    this.currentStage = ProcurementStageType.tokenGenerated,
    this.status = TokenStatus.generated,
    required this.createdAt,
    this.recordedWeightKg,
    this.recordedQuintals,
    this.recordedBags,
    this.qualityStatus,
    this.qualityGrade,
    this.moisturePercentage,
    this.stageTimestamps = const {},
  });

  int get currentStageIndex => ProcurementStageType.values.indexOf(currentStage);

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    int stageIdx = json['currentStageIndex'] ?? json['current_stage_index'] ?? 0;
    if (stageIdx >= ProcurementStageType.values.length) {
      stageIdx = ProcurementStageType.values.length - 1;
    }
    if (stageIdx < 0) {
      stageIdx = 0;
    }
    ProcurementStageType stage = ProcurementStageType.values[stageIdx];

    final weighRec = json['weighingRecord'] ?? json['weighing_record'];
    final qualRec = json['qualityRecord'] ?? json['quality_record'];

    final recKg = (weighRec?['weightKg'] ?? weighRec?['weight_kg'] ?? json['recordedWeightKg'])?.toDouble();
    final recQtl = (weighRec?['weightQuintals'] ?? weighRec?['weight_quintals'] ?? json['recordedQuintals'])?.toDouble();
    final recBags = weighRec?['bagCount'] ?? weighRec?['bag_count'] ?? json['recordedBags'];

    final qStatus = (qualRec?['qualityStatus'] ?? qualRec?['quality_status'] ?? json['qualityStatus'])?.toString();
    final qGrade = (qualRec?['qualityGrade'] ?? qualRec?['quality_grade'] ?? json['qualityGrade'])?.toString();
    final qMoisture = (qualRec?['moisturePercentage'] ?? qualRec?['moisture_percentage'] ?? json['moisturePercentage'])?.toDouble();

    final Map<ProcurementStageType, DateTime> parsedTimestamps = {};

    final history = json['statusHistory'] ?? json['status_history'];
    if (history != null && history is List) {
      for (final h in history) {
        if (h is Map<String, dynamic>) {
          final tsStr = h['timestamp'];
          final event = (h['triggerEvent'] ?? h['trigger_event'] ?? h['toStatus'] ?? h['to_status'] ?? '').toString().toUpperCase();
          if (tsStr != null) {
            final dt = DateTime.tryParse(tsStr.toString())?.toLocal();
            if (dt != null) {
              if (event == 'TOKEN_CALLED' || event == 'CALLED') {
                parsedTimestamps[ProcurementStageType.called] = dt;
              } else if (event == 'WEIGHT_RECEIVED' || event == 'WEIGHING_COMPLETED') {
                parsedTimestamps[ProcurementStageType.weighing] = dt;
              } else if (event == 'QUALITY_TEST_RECEIVED' || event == 'QUALITY_COMPLETED') {
                parsedTimestamps[ProcurementStageType.qualityCheck] = dt;
              } else if (event == 'PROCUREMENT_ACCEPTED' || event == 'ACCEPTED') {
                parsedTimestamps[ProcurementStageType.accepted] = dt;
              } else if (event == 'PAYMENT_INITIATED' || event == 'PAYMENT_PROCESSING') {
                parsedTimestamps[ProcurementStageType.paymentProcessing] = dt;
              } else if (event == 'PAYMENT_COMPLETED') {
                parsedTimestamps[ProcurementStageType.paymentCompleted] = dt;
              }
            }
          }
        }
      }
    }

    if (weighRec != null && weighRec['timestamp'] != null) {
      final dt = DateTime.tryParse(weighRec['timestamp'].toString())?.toLocal();
      if (dt != null) {
        parsedTimestamps[ProcurementStageType.weighing] = dt;
      }
    }

    if (qualRec != null && qualRec['timestamp'] != null) {
      final dt = DateTime.tryParse(qualRec['timestamp'].toString())?.toLocal();
      if (dt != null) {
        parsedTimestamps[ProcurementStageType.qualityCheck] = dt;
      }
    }

    final createdDt = (json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null)?.toLocal() ?? DateTime.now();
    parsedTimestamps[ProcurementStageType.tokenGenerated] = createdDt;
    parsedTimestamps[ProcurementStageType.waiting] ??= createdDt.add(const Duration(minutes: 10));

    return TokenModel(
      id: json['id'] ?? '',
      tokenNumber: json['tokenNumber'] ?? json['token_number'] ?? '',
      farmerId: json['farmerId'] ?? json['farmer_id'] ?? '',
      farmerName: json['farmerName'] ?? json['farmer_name'] ?? '',
      centreId: json['centreId'] ?? json['centre_id'] ?? '',
      centreNameEn: json['centreNameEn'] ?? json['centre_name_en'] ?? '',
      centreNameTa: json['centreNameTa'] ?? json['centre_name_ta'] ?? '',
      bookingDate: json['bookingDate'] ?? json['booking_date'] ?? '',
      timeSlot: json['timeSlot'] ?? json['time_slot'] ?? '',
      cropNameEn: json['cropNameEn'] ?? json['crop_name_en'] ?? '',
      cropNameTa: json['cropNameTa'] ?? json['crop_name_ta'] ?? '',
      estimatedQuintals: (json['estimatedQuintals'] ?? json['estimated_quintals'] as num?)?.toDouble() ?? 0.0,
      estimatedBags: json['estimatedBags'] ?? json['estimated_bags'] ?? 0,
      queuePosition: json['queuePosition'] ?? json['queue_position'] ?? 1,
      currentStage: stage,
      status: TokenStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] ?? 'generated').toString().toLowerCase(),
        orElse: () => TokenStatus.generated,
      ),
      createdAt: createdDt,
      recordedWeightKg: recKg,
      recordedQuintals: recQtl,
      recordedBags: recBags != null ? int.tryParse(recBags.toString()) : null,
      qualityStatus: qStatus,
      qualityGrade: qGrade,
      moisturePercentage: qMoisture,
      stageTimestamps: parsedTimestamps,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenNumber': tokenNumber,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'centreId': centreId,
        'centreNameEn': centreNameEn,
        'centreNameTa': centreNameTa,
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'cropNameEn': cropNameEn,
        'cropNameTa': cropNameTa,
        'estimatedQuintals': estimatedQuintals,
        'estimatedBags': estimatedBags,
        'queuePosition': queuePosition,
        'currentStageIndex': ProcurementStageType.values.indexOf(currentStage),
        'status': status.name.toUpperCase(),
        'createdAt': createdAt.toIso8601String(),
        if (recordedWeightKg != null) 'recordedWeightKg': recordedWeightKg,
        if (recordedQuintals != null) 'recordedQuintals': recordedQuintals,
        if (recordedBags != null) 'recordedBags': recordedBags,
        if (qualityStatus != null) 'qualityStatus': qualityStatus,
        if (qualityGrade != null) 'qualityGrade': qualityGrade,
        if (moisturePercentage != null) 'moisturePercentage': moisturePercentage,
      };

  TokenModel copyWith({
    String? id,
    String? tokenNumber,
    String? farmerId,
    String? farmerName,
    String? centreId,
    String? centreNameEn,
    String? centreNameTa,
    String? bookingDate,
    String? timeSlot,
    String? cropNameEn,
    String? cropNameTa,
    double? estimatedQuintals,
    int? estimatedBags,
    int? queuePosition,
    ProcurementStageType? currentStage,
    TokenStatus? status,
    DateTime? createdAt,
    double? recordedWeightKg,
    double? recordedQuintals,
    int? recordedBags,
    String? qualityStatus,
    String? qualityGrade,
    double? moisturePercentage,
    Map<ProcurementStageType, DateTime>? stageTimestamps,
  }) {
    return TokenModel(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      centreId: centreId ?? this.centreId,
      centreNameEn: centreNameEn ?? this.centreNameEn,
      centreNameTa: centreNameTa ?? this.centreNameTa,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      cropNameEn: cropNameEn ?? this.cropNameEn,
      cropNameTa: cropNameTa ?? this.cropNameTa,
      estimatedQuintals: estimatedQuintals ?? this.estimatedQuintals,
      estimatedBags: estimatedBags ?? this.estimatedBags,
      queuePosition: queuePosition ?? this.queuePosition,
      currentStage: currentStage ?? this.currentStage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      recordedWeightKg: recordedWeightKg ?? this.recordedWeightKg,
      recordedQuintals: recordedQuintals ?? this.recordedQuintals,
      recordedBags: recordedBags ?? this.recordedBags,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      moisturePercentage: moisturePercentage ?? this.moisturePercentage,
      stageTimestamps: stageTimestamps ?? this.stageTimestamps,
    );
  }
}
