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
  });

  int get currentStageIndex => ProcurementStageType.values.indexOf(currentStage);

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    int stageIdx = json['currentStageIndex'] ?? 0;
    ProcurementStageType stage = ProcurementStageType.tokenGenerated;
    if (stageIdx < ProcurementStageType.values.length) {
      stage = ProcurementStageType.values[stageIdx];
    }
    return TokenModel(
      id: json['id'] ?? '',
      tokenNumber: json['tokenNumber'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      centreId: json['centreId'] ?? '',
      centreNameEn: json['centreNameEn'] ?? '',
      centreNameTa: json['centreNameTa'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      cropNameEn: json['cropNameEn'] ?? '',
      cropNameTa: json['cropNameTa'] ?? '',
      estimatedQuintals: (json['estimatedQuintals'] as num?)?.toDouble() ?? 0.0,
      estimatedBags: json['estimatedBags'] ?? 0,
      queuePosition: json['queuePosition'] ?? 1,
      currentStage: stage,
      status: TokenStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] ?? 'generated').toString().toLowerCase(),
        orElse: () => TokenStatus.generated,
      ),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
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
    );
  }
}
