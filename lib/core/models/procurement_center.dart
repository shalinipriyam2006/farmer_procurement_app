class ProcurementCenter {
  final String id;
  final String nameEn;
  final String nameTa;
  final String district;
  final String taluk;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String workingHours;
  final String contactPhone;
  final String status; // OPEN, BUSY, CLOSED, TEMPORARILY_UNAVAILABLE
  final String? statusReason;
  final int dailyCapacityBags;
  final int activeTokensCount;
  final int currentServingToken;
  final double avgWaitMinutes;

  const ProcurementCenter({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.district,
    this.taluk = 'Central',
    required this.locationAddress,
    this.latitude = 10.7867,
    this.longitude = 79.1378,
    required this.workingHours,
    required this.contactPhone,
    this.status = 'OPEN',
    this.statusReason,
    required this.dailyCapacityBags,
    required this.activeTokensCount,
    required this.currentServingToken,
    required this.avgWaitMinutes,
  });

  factory ProcurementCenter.fromJson(Map<String, dynamic> json) {
    return ProcurementCenter(
      id: json['id'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nameTa: json['nameTa'] ?? '',
      district: json['district'] ?? '',
      taluk: json['taluk'] ?? 'Central',
      locationAddress: json['locationAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 10.7867,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.1378,
      workingHours: json['workingHours'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      status: json['status'] ?? 'OPEN',
      statusReason: json['statusReason'],
      dailyCapacityBags: json['dailyCapacityBags'] ?? 1000,
      activeTokensCount: json['activeTokensCount'] ?? 0,
      currentServingToken: json['currentServingToken'] ?? json['currentServingTokenNum'] ?? 101,
      avgWaitMinutes: (json['avgWaitMinutes'] as num?)?.toDouble() ?? 12.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameTa': nameTa,
        'district': district,
        'taluk': taluk,
        'locationAddress': locationAddress,
        'latitude': latitude,
        'longitude': longitude,
        'workingHours': workingHours,
        'contactPhone': contactPhone,
        'status': status,
        'statusReason': statusReason,
        'dailyCapacityBags': dailyCapacityBags,
        'activeTokensCount': activeTokensCount,
        'currentServingToken': currentServingToken,
        'avgWaitMinutes': avgWaitMinutes,
      };
}
