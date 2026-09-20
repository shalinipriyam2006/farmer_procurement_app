class MissedSlot {
  final String id;
  final String tokenId;
  final String farmerId;
  final String centreId;
  final String originalBookingDate;
  final String originalTimeSlot;
  final String? missedReason;
  final String? rescheduledTokenId;
  final String createdAt;

  MissedSlot({
    required this.id,
    required this.tokenId,
    required this.farmerId,
    required this.centreId,
    required this.originalBookingDate,
    required this.originalTimeSlot,
    this.missedReason,
    this.rescheduledTokenId,
    required this.createdAt,
  });

  factory MissedSlot.fromJson(Map<String, dynamic> json) {
    return MissedSlot(
      id: json['id'] as String? ?? '',
      tokenId: json['tokenId'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      centreId: json['centreId'] as String? ?? '',
      originalBookingDate: json['originalBookingDate'] as String? ?? '',
      originalTimeSlot: json['originalTimeSlot'] as String? ?? '',
      missedReason: json['missedReason'] as String?,
      rescheduledTokenId: json['rescheduledTokenId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
