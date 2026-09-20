import 'package:flutter/foundation.dart';

@immutable
class ProcurementReceipt {
  final String id;
  final String receiptNumber;
  final String tokenId;
  final String farmerId;
  final String farmerName;
  final String centreId;
  final String centreName;
  final String cropName;
  final double weightQuintals;
  final int bagCount;
  final String qualityGrade;
  final double moisturePercentage;
  final double applicableRate;
  final double grossAmount;
  final double deductions;
  final double netAmount;
  final DateTime issuedAt;
  final String documentUrl;

  const ProcurementReceipt({
    required this.id,
    required this.receiptNumber,
    required this.tokenId,
    required this.farmerId,
    required this.farmerName,
    required this.centreId,
    required this.centreName,
    required this.cropName,
    required this.weightQuintals,
    required this.bagCount,
    required this.qualityGrade,
    required this.moisturePercentage,
    required this.applicableRate,
    required this.grossAmount,
    required this.deductions,
    required this.netAmount,
    required this.issuedAt,
    required this.documentUrl,
  });

  factory ProcurementReceipt.fromJson(Map<String, dynamic> json) {
    return ProcurementReceipt(
      id: json['id'] ?? '',
      receiptNumber: json['receiptNumber'] ?? json['receipt_number'] ?? '',
      tokenId: json['tokenId'] ?? json['token_id'] ?? '',
      farmerId: json['farmerId'] ?? json['farmer_id'] ?? '',
      farmerName: json['farmerName'] ?? json['farmer_name'] ?? 'Raja Ramanathan',
      centreId: json['centreId'] ?? json['centre_id'] ?? 'CENTRE-01',
      centreName: json['centreName'] ?? json['centre_name'] ?? 'Thanjavur DPC',
      cropName: json['cropName'] ?? json['crop_name'] ?? 'Paddy (Grade A)',
      weightQuintals: (json['weightQuintals'] ?? json['weight_quintals'] ?? 0.0).toDouble(),
      bagCount: (json['bagCount'] ?? json['bag_count'] ?? 0).toInt(),
      qualityGrade: json['qualityGrade'] ?? json['quality_grade'] ?? 'Grade A',
      moisturePercentage: (json['moisturePercentage'] ?? json['moisture_percentage'] ?? 14.2).toDouble(),
      applicableRate: (json['applicableRate'] ?? json['applicable_rate'] ?? 2320.0).toDouble(),
      grossAmount: (json['grossAmount'] ?? json['gross_amount'] ?? 0.0).toDouble(),
      deductions: (json['deductions'] ?? json['deductions'] ?? 0.0).toDouble(),
      netAmount: (json['netAmount'] ?? json['net_amount'] ?? 0.0).toDouble(),
      issuedAt: json['issuedAt'] != null || json['issued_at'] != null
          ? DateTime.tryParse(json['issuedAt'] ?? json['issued_at']) ?? DateTime.now()
          : DateTime.now(),
      documentUrl: json['documentUrl'] ?? json['document_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'tokenId': tokenId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'centreId': centreId,
      'centreName': centreName,
      'cropName': cropName,
      'weightQuintals': weightQuintals,
      'bagCount': bagCount,
      'qualityGrade': qualityGrade,
      'moisturePercentage': moisturePercentage,
      'applicableRate': applicableRate,
      'grossAmount': grossAmount,
      'deductions': deductions,
      'netAmount': netAmount,
      'issuedAt': issuedAt.toIso8601String(),
      'documentUrl': documentUrl,
    };
  }
}
