class FarmerFeedback {
  final String id;
  final String farmerId;
  final String farmerName;
  final String? receiptId;
  final int overallRating;
  final int queueRating;
  final int centreRating;
  final int staffRating;
  final int paymentRating;
  final String? comment;
  final String createdAt;

  FarmerFeedback({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    this.receiptId,
    required this.overallRating,
    required this.queueRating,
    required this.centreRating,
    required this.staffRating,
    required this.paymentRating,
    this.comment,
    required this.createdAt,
  });

  factory FarmerFeedback.fromJson(Map<String, dynamic> json) {
    return FarmerFeedback(
      id: json['id'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? 'Raja Ramanathan',
      receiptId: json['receiptId'] as String?,
      overallRating: json['overallRating'] is int ? json['overallRating'] as int : 5,
      queueRating: json['queueRating'] is int ? json['queueRating'] as int : 5,
      centreRating: json['centreRating'] is int ? json['centreRating'] as int : 5,
      staffRating: json['staffRating'] is int ? json['staffRating'] as int : 5,
      paymentRating: json['paymentRating'] is int ? json['paymentRating'] as int : 5,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
