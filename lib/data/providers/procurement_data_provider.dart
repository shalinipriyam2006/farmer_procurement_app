import 'package:farmer_procurement_app/core/models/farmer_profile.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/core/models/app_notification.dart';

abstract class ProcurementDataProvider {
  Future<List<ProcurementCenter>> getCentres();
  Future<ProcurementCenter> getCentreById(String id);
  Future<FarmerProfile> getFarmerProfile(String farmerId);
  Future<TokenModel?> getActiveToken(String farmerId);
  Future<QueueStateModel> getQueueState(String farmerId, String centreId);
  Future<PaymentModel> getPaymentDetails(String farmerId);
  Future<List<AppNotification>> getNotifications(String farmerId);
  
  Future<TokenModel> bookToken({
    required String farmerId,
    required String centreId,
    required String bookingDate,
    required String timeSlot,
    required String cropNameEn,
    required String cropNameTa,
    required double estimatedQuintals,
    required int estimatedBags,
  });

  Future<void> submitGrievance({
    required String farmerId,
    required String category,
    required String description,
  });
}

abstract class AuthorizedGovernmentProcurementProvider extends ProcurementDataProvider {
  // Configured with government portal endpoints and security authorization keys.
  // Will throw UnsupportedError if government gateway is unavailable.
}
