import 'package:farmer_procurement_app/core/models/farmer_profile.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/core/models/app_notification.dart';
import 'package:farmer_procurement_app/data/mock_data.dart';
import 'package:farmer_procurement_app/data/providers/procurement_data_provider.dart';

class DevelopmentProcurementProvider implements ProcurementDataProvider {
  @override
  Future<List<ProcurementCenter>> getCentres() async {
    return MockData.centers;
  }

  @override
  Future<ProcurementCenter> getCentreById(String id) async {
    return MockData.centers.firstWhere(
      (c) => c.id == id,
      orElse: () => MockData.centers[0],
    );
  }

  @override
  Future<FarmerProfile> getFarmerProfile(String farmerId) async {
    return MockData.demoFarmer;
  }

  @override
  Future<TokenModel?> getActiveToken(String farmerId) async {
    return MockData.initialToken;
  }

  @override
  Future<QueueStateModel> getQueueState(String farmerId, String centreId) async {
    return QueueStateModel(
      currentServingToken: 'TK-101',
      userToken: 'TK-104',
      farmersAhead: 3,
      estimatedWaitMinutes: 36,
      queueStatusEn: 'Moving Smoothly (~12 mins/farmer)',
      queueStatusTa: 'சீரான வேகம் (~12 நிமிடம்/விவசாயி)',
      totalServedToday: 21,
      queueSequence: [],
    );
  }

  @override
  Future<PaymentModel> getPaymentDetails(String farmerId) async {
    return MockData.initialPayment;
  }

  @override
  Future<List<AppNotification>> getNotifications(String farmerId) async {
    return MockData.initialNotifications;
  }

  @override
  Future<TokenModel> bookToken({
    required String farmerId,
    required String centreId,
    required String bookingDate,
    required String timeSlot,
    required String cropNameEn,
    required String cropNameTa,
    required double estimatedQuintals,
    required int estimatedBags,
  }) async {
    return TokenModel(
      id: 'TOKEN-${DateTime.now().millisecondsSinceEpoch}',
      tokenNumber: 'TK-105',
      farmerId: farmerId,
      farmerName: MockData.demoFarmer.name,
      centreId: centreId,
      centreNameEn: MockData.centers[0].nameEn,
      centreNameTa: MockData.centers[0].nameTa,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      cropNameEn: cropNameEn,
      cropNameTa: cropNameTa,
      estimatedQuintals: estimatedQuintals,
      estimatedBags: estimatedBags,
      queuePosition: 4,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> submitGrievance({
    required String farmerId,
    required String category,
    required String description,
  }) async {
    // No-op for dev mock
  }
}
