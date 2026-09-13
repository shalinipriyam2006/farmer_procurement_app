class FarmerProfile {
  final String id;
  final String name;
  final String mobileNumber;
  final String farmerIdNumber;
  final String village;
  final String district;
  final String preferredCentreId;
  final String bankAccountMasked;
  final String ifscCode;
  final double landHoldingAcres;

  const FarmerProfile({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.farmerIdNumber,
    required this.village,
    required this.district,
    required this.preferredCentreId,
    required this.bankAccountMasked,
    required this.ifscCode,
    required this.landHoldingAcres,
  });

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      farmerIdNumber: json['farmerIdNumber'] ?? '',
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      preferredCentreId: json['preferredCentreId'] ?? '',
      bankAccountMasked: json['bankAccountMasked'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      landHoldingAcres: (json['landHoldingAcres'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobileNumber': mobileNumber,
        'farmerIdNumber': farmerIdNumber,
        'village': village,
        'district': district,
        'preferredCentreId': preferredCentreId,
        'bankAccountMasked': bankAccountMasked,
        'ifscCode': ifscCode,
        'landHoldingAcres': landHoldingAcres,
      };

  FarmerProfile copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    String? farmerIdNumber,
    String? village,
    String? district,
    String? preferredCentreId,
    String? bankAccountMasked,
    String? ifscCode,
    double? landHoldingAcres,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      farmerIdNumber: farmerIdNumber ?? this.farmerIdNumber,
      village: village ?? this.village,
      district: district ?? this.district,
      preferredCentreId: preferredCentreId ?? this.preferredCentreId,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      ifscCode: ifscCode ?? this.ifscCode,
      landHoldingAcres: landHoldingAcres ?? this.landHoldingAcres,
    );
  }
}
