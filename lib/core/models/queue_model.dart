class QueueItem {
  final String tokenNumber;
  final String farmerName;
  final String crop;
  final bool isServing;
  final bool isPast;
  final bool isUser;

  const QueueItem({
    required this.tokenNumber,
    required this.farmerName,
    required this.crop,
    this.isServing = false,
    this.isPast = false,
    this.isUser = false,
  });
}

class QueueStateModel {
  final String currentServingToken;
  final String userToken;
  final int farmersAhead;
  final int estimatedWaitMinutes;
  final String queueStatusEn;
  final String queueStatusTa;
  final int totalServedToday;
  final List<QueueItem> queueSequence;

  const QueueStateModel({
    required this.currentServingToken,
    required this.userToken,
    required this.farmersAhead,
    required this.estimatedWaitMinutes,
    required this.queueStatusEn,
    required this.queueStatusTa,
    required this.totalServedToday,
    required this.queueSequence,
  });
}
