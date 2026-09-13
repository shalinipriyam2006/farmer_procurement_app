enum PaymentStatus { notInitiated, processing, completed, failed }

class PaymentModel {
  final String id;
  final String tokenNumber;
  final String cropNameEn;
  final String cropNameTa;
  final double quantityQuintals;
  final int bagCount;
  final double mspRatePerQuintal;
  final double deductions; // Moisture/foreign matter deduction
  final double netAmount;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final String bankReferenceNumber;
  final String maskedBankAccount;
  final String ifscCode;
  final String qualityGrade;
  final double moisturePercentage;

  const PaymentModel({
    required this.id,
    required this.tokenNumber,
    required this.cropNameEn,
    required this.cropNameTa,
    required this.quantityQuintals,
    required this.bagCount,
    required this.mspRatePerQuintal,
    required this.deductions,
    required this.netAmount,
    required this.status,
    this.paymentDate,
    required this.bankReferenceNumber,
    required this.maskedBankAccount,
    required this.ifscCode,
    this.qualityGrade = 'Grade A',
    this.moisturePercentage = 14.2,
  });

  double get grossAmount => quantityQuintals * mspRatePerQuintal;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      tokenNumber: json['tokenNumber'] ?? '',
      cropNameEn: json['cropNameEn'] ?? '',
      cropNameTa: json['cropNameTa'] ?? '',
      quantityQuintals: (json['quantityQuintals'] as num?)?.toDouble() ?? 0.0,
      bagCount: json['bagCount'] ?? 0,
      mspRatePerQuintal: (json['mspRatePerQuintal'] as num?)?.toDouble() ?? 2320.0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      status: PaymentStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] ?? 'processing').toString().toLowerCase(),
        orElse: () => PaymentStatus.processing,
      ),
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
      bankReferenceNumber: json['bankReferenceNumber'] ?? '',
      maskedBankAccount: json['maskedBankAccount'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      qualityGrade: json['qualityGrade'] ?? 'Grade A',
      moisturePercentage: (json['moisturePercentage'] as num?)?.toDouble() ?? 14.2,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenNumber': tokenNumber,
        'cropNameEn': cropNameEn,
        'cropNameTa': cropNameTa,
        'quantityQuintals': quantityQuintals,
        'bagCount': bagCount,
        'mspRatePerQuintal': mspRatePerQuintal,
        'deductions': deductions,
        'netAmount': netAmount,
        'status': status.name.toUpperCase(),
        'paymentDate': paymentDate?.toIso8601String(),
        'bankReferenceNumber': bankReferenceNumber,
        'maskedBankAccount': maskedBankAccount,
        'ifscCode': ifscCode,
        'qualityGrade': qualityGrade,
        'moisturePercentage': moisturePercentage,
      };

  PaymentModel copyWith({
    String? id,
    String? tokenNumber,
    String? cropNameEn,
    String? cropNameTa,
    double? quantityQuintals,
    int? bagCount,
    double? mspRatePerQuintal,
    double? deductions,
    double? netAmount,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? bankReferenceNumber,
    String? maskedBankAccount,
    String? ifscCode,
    String? qualityGrade,
    double? moisturePercentage,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      cropNameEn: cropNameEn ?? this.cropNameEn,
      cropNameTa: cropNameTa ?? this.cropNameTa,
      quantityQuintals: quantityQuintals ?? this.quantityQuintals,
      bagCount: bagCount ?? this.bagCount,
      mspRatePerQuintal: mspRatePerQuintal ?? this.mspRatePerQuintal,
      deductions: deductions ?? this.deductions,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      bankReferenceNumber: bankReferenceNumber ?? this.bankReferenceNumber,
      maskedBankAccount: maskedBankAccount ?? this.maskedBankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      moisturePercentage: moisturePercentage ?? this.moisturePercentage,
    );
  }
}
