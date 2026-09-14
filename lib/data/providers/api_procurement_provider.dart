import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:farmer_procurement_app/core/config/app_config.dart';
import 'package:farmer_procurement_app/core/models/farmer_profile.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/core/models/app_notification.dart';
import 'package:farmer_procurement_app/data/providers/procurement_data_provider.dart';

class ApiProcurementProvider implements ProcurementDataProvider {
  final String baseUrl;
  String? _authToken;

  ApiProcurementProvider({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConfig.apiBaseUrl;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Auth APIs
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/send'),
        headers: _headers,
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {'success': true, 'data': body['data']};
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'error': body['error'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        headers: _headers,
        body: jsonEncode({'mobileNumber': mobileNumber, 'otp': otp}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        _authToken = body['token'];
        return {
          'success': true,
          'isRegistered': body['isRegistered'] ?? true,
          'token': _authToken,
          'user': body['user'],
          'message': body['message'],
        };
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'error': body['error'] ?? 'OTP verification failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<String?> loginFarmer(String mobileNumber) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/farmer/login'),
        headers: _headers,
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        _authToken = body['token'];
        return _authToken;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> loginOfficer(String badgeId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/officer/login'),
        headers: _headers,
        body: jsonEncode({'badgeId': badgeId}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        _authToken = body['token'];
        return _authToken;
      }
    } catch (_) {}
    return null;
  }

  // Farmer APIs
  @override
  Future<List<ProcurementCenter>> getCentres() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/procurement/centres'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List;
        return list.map((json) => ProcurementCenter.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getProcurementRates() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/procurement/rates'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List;
        return list.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<ProcurementCenter> getCentreById(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/procurement/centres/$id'),
      headers: _headers,
    );
    final body = jsonDecode(res.body);
    return ProcurementCenter.fromJson(body['data']);
  }

  @override
  Future<FarmerProfile> getFarmerProfile(String farmerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/farmers/$farmerId'),
      headers: _headers,
    );
    final body = jsonDecode(res.body);
    return FarmerProfile.fromJson(body['data']);
  }

  @override
  Future<TokenModel?> getActiveToken(String farmerId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/farmers/$farmerId/token'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return TokenModel.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<QueueStateModel> getQueueState(String farmerId, String centreId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/farmers/$farmerId/queue'),
      headers: _headers,
    );
    final body = jsonDecode(res.body);
    final data = body['data'];
    return QueueStateModel(
      currentServingToken: data['currentServingToken'],
      userToken: data['userToken'],
      farmersAhead: data['farmersAhead'],
      estimatedWaitMinutes: data['estimatedWaitMinutes'],
      queueStatusEn: data['queueStatusEn'],
      queueStatusTa: data['queueStatusTa'],
      totalServedToday: data['totalServedToday'],
      queueSequence: (data['queueSequence'] as List)
          .map((item) => QueueItem(
                tokenNumber: item['tokenNumber'],
                farmerName: item['farmerName'],
                crop: item['crop'],
                isServing: item['isServing'],
                isPast: item['isPast'],
                isUser: item['isUser'],
              ))
          .toList(),
    );
  }

  @override
  Future<PaymentModel> getPaymentDetails(String farmerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/farmers/$farmerId/payments'),
      headers: _headers,
    );
    final body = jsonDecode(res.body);
    return PaymentModel.fromJson(body['data']);
  }

  @override
  Future<List<AppNotification>> getNotifications(String farmerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/farmers/$farmerId/notifications'),
      headers: _headers,
    );
    final body = jsonDecode(res.body);
    final list = body['data'] as List;
    return list.map((json) => AppNotification.fromJson(json)).toList();
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
    final res = await http.post(
      Uri.parse('$baseUrl/farmers/token/book'),
      headers: _headers,
      body: jsonEncode({
        'farmerId': farmerId,
        'centreId': centreId,
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'cropNameEn': cropNameEn,
        'cropNameTa': cropNameTa,
        'estimatedQuintals': estimatedQuintals,
        'estimatedBags': estimatedBags,
      }),
    );
    final body = jsonDecode(res.body);
    return TokenModel.fromJson(body['data']);
  }

  @override
  Future<void> submitGrievance({
    required String farmerId,
    required String category,
    required String description,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/grievances'),
      headers: _headers,
      body: jsonEncode({
        'farmerId': farmerId,
        'category': category,
        'description': description,
      }),
    );
  }

  // Officer Backend APIs
  Future<String?> officerNextQueueToken({String? centreId}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/officer/queue/call-next'),
        headers: _headers,
        body: jsonEncode({'centreId': centreId}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['currentServingToken'];
      }
    } catch (_) {}
    return null;
  }

  Future<bool> officerUpdateStage({required int stageIndex, String? remark}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/officer/procurement/update'),
        headers: _headers,
        body: jsonEncode({'stageIndex': stageIndex, 'remark': remark}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> officerSetCentreStatus(String status, {String? reason, String? centreId}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/officer/centre/status'),
        headers: _headers,
        body: jsonEncode({
          'status': status,
          'reason': reason,
          'centreId': centreId,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
