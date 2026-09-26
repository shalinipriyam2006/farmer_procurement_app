import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/config/app_config.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/models/farmer_profile.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/core/models/procurement_receipt.dart';
import 'package:farmer_procurement_app/core/models/app_notification.dart';
import 'package:farmer_procurement_app/core/models/digital_document.dart';
import 'package:farmer_procurement_app/data/mock_data.dart';
import 'package:farmer_procurement_app/data/providers/api_procurement_provider.dart';

class ProcurementRepository extends ChangeNotifier {
  static final ProcurementRepository _instance =
      ProcurementRepository._internal();
  factory ProcurementRepository() => _instance;

  ProcurementRepository._internal() {
    _initDefaults();
  }

  // API Provider Instance
  final ApiProcurementProvider _apiProvider = ApiProcurementProvider();

  // State Variables
  AppLanguage _language = AppLanguage.english;
  bool _isLoggedIn = true;
  bool _isOfficerMode = false;
  bool _isAutoSimulatingQueue = false;
  Timer? _queueSimulationTimer;
  Timer? _backgroundSyncTimer;

  // Network & Sync State
  bool _isOffline = false;
  DateTime? _lastSyncTime;
  String? _syncError;

  late FarmerProfile _currentFarmer;
  late List<ProcurementCenter> _centers;
  late String _selectedCenterId;
  TokenModel? _activeToken;
  late PaymentModel _payment;
  late List<AppNotification> _notifications;
  List<ProcurementReceipt> _receipts = [];
  List<DigitalDocument> _documents = [];
  Map<String, dynamic> _officerFeedbackData = {'data': [], 'summary': {}};
  int _currentServingTokenNumber = 101;

  void _initDefaults() {
    _currentFarmer = MockData.demoFarmer;
    _centers = List.from(MockData.centers);
    _selectedCenterId = MockData.centers[0].id;
    _activeToken = MockData.initialToken;
    _payment = MockData.initialPayment;
    _notifications = List.from(MockData.initialNotifications);
    _receipts = [];
    _documents = [];

    // Initial sync attempt with API provider & start background polling
    syncWithBackend();
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('Test')) return;
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      syncWithBackend();
    });
  }

  void stopBackgroundPolling() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
  }

  late List<Map<String, dynamic>> _procurementRates = [
    {
      'cropEn': 'Paddy (Grade A)',
      'cropTa': 'நெல் (கிரேடு ஏ)',
      'variety': 'Grade A (Common Fair Average Quality)',
      'ratePerQuintal': 2320.0,
      'unit': 'Quintal',
      'source': 'e-NAM Benchmark / Local Administrative Board',
    },
    {
      'cropEn': 'Paddy (Common)',
      'cropTa': 'நெல் (சாதாரண தரம்)',
      'variety': 'Common Grade FAQ',
      'ratePerQuintal': 2300.0,
      'unit': 'Quintal',
      'source': 'e-NAM Benchmark / Local Administrative Board',
    },
  ];

  List<Map<String, dynamic>> get procurementRates => List.unmodifiable(_procurementRates);
  List<ProcurementReceipt> get receipts => List.unmodifiable(_receipts);
  List<DigitalDocument> get documents => List.unmodifiable(_documents);
  Map<String, dynamic> get officerFeedbackData => _officerFeedbackData;
  ProcurementReceipt? get activeReceipt => _receipts.isNotEmpty ? _receipts.first : null;

  Future<void> fetchProcurementRates() async {
    try {
      final rates = await _apiProvider.getProcurementRates();
      if (rates.isNotEmpty) {
        _procurementRates = rates;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> syncWithBackend() async {
    try {
      final fetchedCentres = await _apiProvider.getCentres();
      if (fetchedCentres.isNotEmpty) {
        _centers = fetchedCentres;
        _isOffline = false;
        _lastSyncTime = DateTime.now();
        _syncError = null;
      }
      final activeTok = await _apiProvider.getActiveToken(_currentFarmer.id);
      if (activeTok != null) {
        _activeToken = activeTok;
        if (activeTok.stageTimestamps.isNotEmpty) {
          _stageTimestamps.addAll(activeTok.stageTimestamps);
        }
      }
      final notifs = await _apiProvider.getNotifications(_currentFarmer.id);
      if (notifs.isNotEmpty) {
        _notifications = notifs;
      }
      await fetchProcurementRates();
      await refreshQueueFromBackend();
      await refreshReceiptsFromBackend();
      await fetchDigitalDocuments();
      notifyListeners();
    } catch (e) {
      _isOffline = true;
      _syncError = 'Unable to connect to live backend ($e)';
      notifyListeners();
    }
  }

  Future<void> fetchDigitalDocuments() async {
    try {
      final docsJson = await _apiProvider.getDigitalDocuments(_currentFarmer.id);
      if (docsJson.isNotEmpty) {
        _documents = docsJson.map((j) => DigitalDocument.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> rescheduleToken(String newDate, String newSlot) async {
    final res = await _apiProvider.rescheduleToken(
      farmerId: _currentFarmer.id,
      newBookingDate: newDate,
      newTimeSlot: newSlot,
    );
    if (res['success'] == true) {
      if (_activeToken != null) {
        _activeToken = _activeToken!.copyWith(
          bookingDate: newDate,
          timeSlot: newSlot,
          currentStage: ProcurementStageType.tokenGenerated,
        );
      }
      await syncWithBackend();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> submitFeedback({
    required int rating,
    required String category,
    required String remarks,
  }) async {
    final res = await _apiProvider.submitFarmerFeedback(
      farmerId: _currentFarmer.id,
      rating: rating,
      category: category,
      remarks: remarks,
    );
    if (res['success'] == true) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchOfficerFeedback() async {
    try {
      final res = await _apiProvider.getOfficerFeedback();
      if (res['success'] == true) {
        _officerFeedbackData = res;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshReceiptsFromBackend() async {
    try {
      final rawReceipts = await _apiProvider.getFarmerReceipts(_currentFarmer.id);
      if (rawReceipts.isNotEmpty) {
        _receipts = rawReceipts.map((r) => ProcurementReceipt.fromJson(r)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshQueueFromBackend() async {
    try {
      final queueState = await _apiProvider.getQueueState(
        _currentFarmer.id,
        _selectedCenterId,
      );
      final currentServingNum =
          int.tryParse(queueState.currentServingToken.replaceAll(RegExp(r'[^0-9]'), '')) ??
              _currentServingTokenNumber;

      _currentServingTokenNumber = currentServingNum;
      _isOffline = false;
      _lastSyncTime = DateTime.now();
      _syncError = null;
      notifyListeners();
    } catch (e) {
      _isOffline = true;
      _syncError = 'Backend unavailable: $e';
      notifyListeners();
    }
  }

  // Hardware Simulator Actions (Development Only)
  Future<Map<String, dynamic>> runSimulatorScale({double weightKg = 50.25, int bagCount = 45}) async {
    final res = await _apiProvider.runSimulatorScale(
      weightKg: weightKg,
      bagCount: bagCount,
      farmerId: _currentFarmer.id,
    );

    final tokenJson = res['result']?['token'];
    if (tokenJson != null && tokenJson is Map<String, dynamic>) {
      _activeToken = TokenModel.fromJson(tokenJson);
    } else if (_activeToken != null) {
      final wQuintals = (weightKg * bagCount) / 100.0;
      _activeToken = _activeToken!.copyWith(
        currentStage: ProcurementStageType.qualityCheck,
        recordedWeightKg: weightKg,
        recordedQuintals: wQuintals,
        recordedBags: bagCount,
        estimatedQuintals: wQuintals,
        estimatedBags: bagCount,
      );
    }

    await syncWithBackend();
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> runSimulatorQuality({double moisturePercentage = 14.2}) async {
    final res = await _apiProvider.runSimulatorQuality(
      moisturePercentage: moisturePercentage,
      farmerId: _currentFarmer.id,
    );

    final tokenJson = res['result']?['token'];
    if (tokenJson != null && tokenJson is Map<String, dynamic>) {
      _activeToken = TokenModel.fromJson(tokenJson);
    } else if (_activeToken != null) {
      _activeToken = _activeToken!.copyWith(
        currentStage: ProcurementStageType.paymentCompleted,
        qualityStatus: moisturePercentage <= 17.0 ? 'ACCEPTED' : 'REJECTED',
        qualityGrade: 'Grade A FAQ Standard',
        moisturePercentage: moisturePercentage,
      );
    }

    await syncWithBackend();
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> runSimulatorAutoFlow({double customWeightKg = 50.25, double customMoisture = 14.2}) async {
    // 1. Step 1: Execute Weighing Event (Stage 3)
    await runSimulatorScale(weightKg: customWeightKg, bagCount: 45);
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Step 2: Execute Quality Sensor Event (Stage 4)
    await runSimulatorQuality(moisturePercentage: customMoisture);
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Step 3: Complete remaining pipeline via backend (Accepted -> Payment, Stages 5..7)
    final res = await _apiProvider.runSimulatorAutoFlow(
      customWeightKg: customWeightKg,
      customMoisture: customMoisture,
      farmerId: _currentFarmer.id,
    );

    final tokenJson = res['result']?['accepted']?['token'] ?? res['result']?['token'];
    if (tokenJson != null && tokenJson is Map<String, dynamic>) {
      _activeToken = TokenModel.fromJson(tokenJson);
    } else if (_activeToken != null) {
      final wQuintals = (customWeightKg * 45) / 100.0;
      _activeToken = _activeToken!.copyWith(
        currentStage: ProcurementStageType.paymentCompleted,
        recordedWeightKg: customWeightKg,
        recordedQuintals: wQuintals,
        recordedBags: 45,
        estimatedQuintals: wQuintals,
        estimatedBags: 45,
        qualityStatus: 'ACCEPTED',
        qualityGrade: 'Grade A FAQ Standard',
        moisturePercentage: customMoisture,
      );
    }

    await syncWithBackend();
    notifyListeners();
    return res;
  }

  // Getters
  AppLanguage get language => _language;
  bool get isTamil => _language == AppLanguage.tamil;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOfficerMode => _isOfficerMode;
  bool get isAutoSimulatingQueue => _isAutoSimulatingQueue;
  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  FarmerProfile get currentFarmer => _currentFarmer;
  List<ProcurementCenter> get centers => _centers;
  String get selectedCenterId => _selectedCenterId;
  String get apiBaseUrl => AppConfig.apiBaseUrl;

  ProcurementCenter get currentCenter => _centers.firstWhere(
        (c) => c.id == _selectedCenterId,
        orElse: () => _centers[0],
      );
  TokenModel? get activeToken => _activeToken;
  PaymentModel get payment => _payment;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
  int get currentServingTokenNumber => _currentServingTokenNumber;

  // Language Actions
  void toggleLanguage() {
    _language = _language == AppLanguage.english
        ? AppLanguage.tamil
        : AppLanguage.english;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }

  // Auth Actions
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    return await _apiProvider.sendOtp(mobileNumber);
  }

  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    final result = await _apiProvider.verifyOtp(mobileNumber, otp);
    if (result['success'] == true) {
      _isLoggedIn = true;
      await syncWithBackend();
      notifyListeners();
    }
    return result;
  }

  Future<void> login(String mobile) async {
    _isLoggedIn = true;
    await _apiProvider.loginFarmer(mobile);
    await syncWithBackend();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _stopAutoQueueSimulation();
    notifyListeners();
  }

  void registerFarmer({
    required String name,
    required String mobileNumber,
    required String farmerIdNumber,
    required String village,
    required String district,
    required String preferredCentreId,
  }) {
    _currentFarmer = FarmerProfile(
      id: 'FARMER-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: name,
      mobileNumber: mobileNumber,
      farmerIdNumber: farmerIdNumber,
      village: village,
      district: district,
      preferredCentreId: preferredCentreId,
      bankAccountMasked: '•••• •••• 5543',
      ifscCode: 'SBIN0008899',
      landHoldingAcres: 4.0,
    );
    _selectedCenterId = preferredCentreId;
    _isLoggedIn = true;
    syncWithBackend();
    notifyListeners();
  }

  void toggleOfficerMode() {
    _isOfficerMode = !_isOfficerMode;
    notifyListeners();
  }

  void setSelectedCenter(String centerId) {
    _selectedCenterId = centerId;
    syncWithBackend();
    notifyListeners();
  }

  // Token Booking
  Future<void> bookNewToken({
    required String centreId,
    required String dateStr,
    required String timeSlot,
    required String cropNameEn,
    required String cropNameTa,
    required double quintals,
    required int bags,
  }) async {
    final center = _centers.firstWhere(
      (c) => c.id == centreId,
      orElse: () => _centers[0],
    );
    final newTokenNumber = 'TK-${_currentServingTokenNumber + 5}';

    _activeToken = TokenModel(
      id: 'TOKEN-${DateTime.now().millisecondsSinceEpoch}',
      tokenNumber: newTokenNumber,
      farmerId: _currentFarmer.id,
      farmerName: _currentFarmer.name,
      centreId: center.id,
      centreNameEn: center.nameEn,
      centreNameTa: center.nameTa,
      bookingDate: dateStr,
      timeSlot: timeSlot,
      cropNameEn: cropNameEn,
      cropNameTa: cropNameTa,
      estimatedQuintals: quintals,
      estimatedBags: bags,
      queuePosition: 5,
      currentStage: ProcurementStageType.tokenGenerated,
      createdAt: DateTime.now(),
    );

    _payment = PaymentModel(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch % 100000}',
      tokenNumber: newTokenNumber,
      cropNameEn: cropNameEn,
      cropNameTa: cropNameTa,
      quantityQuintals: quintals,
      bagCount: bags,
      mspRatePerQuintal: 2320.0,
      deductions: 450.0,
      netAmount: (quintals * 2320.0) - 450.0,
      status: PaymentStatus.processing,
      bankReferenceNumber: 'PFMS-PENDING',
      maskedBankAccount: _currentFarmer.bankAccountMasked,
      ifscCode: _currentFarmer.ifscCode,
    );

    _addNotification(
      titleEn: 'Digital Token Generated: $newTokenNumber',
      titleTa: 'டோக்கன் பெறப்பட்டது: $newTokenNumber',
      messageEn:
          'Your slot at ${center.nameEn} on $dateStr ($timeSlot) is confirmed.',
      messageTa:
          '${center.nameTa}-ல் $dateStr ($timeSlot) முன்பதிவு உறுதியானது.',
      icon: Icons.confirmation_number_rounded,
      color: const Color(0xFF1B5E20),
    );

    try {
      await _apiProvider.bookToken(
        farmerId: _currentFarmer.id,
        centreId: centreId,
        bookingDate: dateStr,
        timeSlot: timeSlot,
        cropNameEn: cropNameEn,
        cropNameTa: cropNameTa,
        estimatedQuintals: quintals,
        estimatedBags: bags,
      );
    } catch (_) {}

    notifyListeners();
  }

  // Queue State Calculation
  QueueStateModel getQueueState() {
    final centre = currentCenter;
    final servingNum = centre.currentServingToken > 0 ? centre.currentServingToken : _currentServingTokenNumber;
    final userTokenStr = _activeToken?.tokenNumber ?? 'TK-104';
    final userTokenNum =
        int.tryParse(userTokenStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 104;
    final farmersAhead = (userTokenNum - servingNum).clamp(
      0,
      99,
    );
    final avgWait = centre.avgWaitMinutes > 0 ? centre.avgWaitMinutes : 12.0;
    final estWaitMinutes = (farmersAhead * avgWait).round();

    String statusEn = 'Moving Smoothly (~${avgWait.round()} mins/farmer)';
    String statusTa = 'சீரான வேகம் (~${avgWait.round()} நிமிடம்/விவசாயி)';

    if (centre.status == 'CLOSED') {
      statusEn = centre.statusReason != null && centre.statusReason!.isNotEmpty
          ? 'CENTRE CLOSED: ${centre.statusReason}'
          : 'Procurement Centre Currently Closed';
      statusTa = centre.statusReason != null && centre.statusReason!.isNotEmpty
          ? 'நிலையம் மூடப்பட்டுள்ளது: ${centre.statusReason}'
          : 'கொள்முதல் நிலையம் தற்போது மூடப்பட்டுள்ளது';
    } else if (farmersAhead == 0) {
      statusEn = 'YOUR TURN NOW! Proceed to Bay #02';
      statusTa = 'உங்கள் முறை வந்துவிட்டது! எடை பகுதி #02-க்கு செல்லவும்';
    } else if (farmersAhead == 1) {
      statusEn = 'Next in Line - Please standby near gate';
      statusTa = 'அடுத்த முறை உங்களுடையது - வாயில் அருகே இருக்கவும்';
    }

    List<QueueItem> sequence = [];
    for (
      int i = servingNum - 2;
      i <= servingNum + 5;
      i++
    ) {
      if (i <= 0) continue;
      final tk = 'TK-$i';
      final isServing = (i == servingNum);
      final isPast = (i < servingNum);
      final isUser = (tk == userTokenStr);

      sequence.add(
        QueueItem(
          tokenNumber: tk,
          farmerName: isUser ? _currentFarmer.name : 'Farmer $i',
          crop: 'Paddy',
          isServing: isServing,
          isPast: isPast,
          isUser: isUser,
        ),
      );
    }

    return QueueStateModel(
      currentServingToken: 'TK-$servingNum',
      userToken: userTokenStr,
      farmersAhead: farmersAhead,
      estimatedWaitMinutes: estWaitMinutes,
      queueStatusEn: statusEn,
      queueStatusTa: statusTa,
      totalServedToday: math.max(0, servingNum - 80),
      queueSequence: sequence,
    );
  }

  // Real-Time Queue Simulation Engine
  void toggleAutoQueueSimulation() {
    _isAutoSimulatingQueue = !_isAutoSimulatingQueue;
    if (_isAutoSimulatingQueue) {
      _startAutoQueueSimulation();
    } else {
      _stopAutoQueueSimulation();
    }
    notifyListeners();
  }

  void _startAutoQueueSimulation() {
    _queueSimulationTimer?.cancel();
    _queueSimulationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      officerNextQueueToken();
      final userTokenStr = _activeToken?.tokenNumber ?? 'TK-104';
      final userTokenNum =
          int.tryParse(userTokenStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 104;
      if (_currentServingTokenNumber >= userTokenNum) {
        _stopAutoQueueSimulation();
      }
    });
  }

  void _stopAutoQueueSimulation() {
    _isAutoSimulatingQueue = false;
    _queueSimulationTimer?.cancel();
    _queueSimulationTimer = null;
  }

  // Stage Progress Info
  final Map<ProcurementStageType, DateTime> _stageTimestamps = {};
  final Map<ProcurementStageType, String> _stageRemarks = {};

  List<StageProgressInfo> getStageProgressList() {
    final currentStage =
        _activeToken?.currentStage ?? ProcurementStageType.called;
    final stages = ProcurementStageType.values;
    final currentIndex = stages.indexOf(currentStage);

    final tok = _activeToken;

    final String weighingDescEn = tok?.recordedWeightKg != null
        ? 'Recorded Weight: ${tok!.recordedWeightKg} kg'
        : (tok != null && tok.estimatedQuintals > 0
            ? 'Recorded Weight: ${(tok.estimatedQuintals * 100).toStringAsFixed(2)} kg (${tok.estimatedQuintals} Qtl, ${tok.estimatedBags} bags)'
            : 'Electronic weighment completed. Gross and tare recorded.');

    final String weighingDescTa = tok?.recordedWeightKg != null
        ? 'பதிவு செய்யப்பட்ட எடை: ${tok!.recordedWeightKg} கிலோ'
        : (tok != null && tok.estimatedQuintals > 0
            ? 'பதிவு செய்யப்பட்ட எடை: ${(tok.estimatedQuintals * 100).toStringAsFixed(2)} கிலோ (${tok.estimatedQuintals} க்விண்டால், ${tok.estimatedBags} மூட்டைகள்)'
            : 'எலக்ட்ரானிக் எடை சரிபார்க்கப்பட்டது. மூட்டை எடை பதிவு செய்யப்பட்டது.');

    final String weighingRemark = tok?.recordedWeightKg != null
        ? 'Recorded Weight: ${tok!.recordedWeightKg} kg'
        : (tok != null && tok.estimatedQuintals > 0
            ? 'Recorded Weight: ${(tok.estimatedQuintals * 100).toStringAsFixed(2)} kg'
            : 'Scale Verified: 45 Bags / 29.7 Qtl');

    final String qualStatus = tok?.qualityStatus ?? 'Accepted';
    final String qualGrade = tok?.qualityGrade ?? 'Grade A FAQ';
    final double qualMoisture = tok?.moisturePercentage ?? 14.2;

    final String qualityDescEn = 'Quality Result: $qualStatus ($qualGrade, Moisture: $qualMoisture%)';
    final String qualityDescTa = 'தர முடிவு: ${qualStatus == "ACCEPTED" ? "ஏற்றுக்கொள்ளப்பட்டது" : qualStatus} ($qualGrade, ஈரப்பதம்: $qualMoisture%)';
    final String qualityRemark = 'Quality Result: $qualStatus ($qualGrade)';

    final stageMeta = {
      ProcurementStageType.tokenGenerated: {
        'en': 'Token issued via mobile portal. Scheduled slot allotted.',
        'ta': 'போர்டல் மூலம் டோக்கன் பெறப்பட்டது. நேரம் ஒதுக்கப்பட்டது.',
        'key': 'stage_1',
        'icon': Icons.confirmation_number_rounded,
        'defaultRemark': 'Token Verified',
      },
      ProcurementStageType.waiting: {
        'en': 'Farmer vehicle arrived at yard. Awaiting gate clearance.',
        'ta': 'வாகனம் யார்டை வந்தடைந்தது. நுழைவு அனுமதிக்கு காத்திருக்கிறது.',
        'key': 'stage_2',
        'icon': Icons.local_shipping_rounded,
        'defaultRemark': 'Gate Clearance Approved',
      },
      ProcurementStageType.called: {
        'en': 'Token announced. Farmer guided to Weighbridge Bay 2.',
        'ta': 'டோக்கன் அழைக்கப்பட்டது. எடை போடும் இடத்திற்கு செல்லவும்.',
        'key': 'stage_3',
        'icon': Icons.campaign_rounded,
        'defaultRemark': 'Called to Weighbridge Bay 2',
      },
      ProcurementStageType.weighing: {
        'en': weighingDescEn,
        'ta': weighingDescTa,
        'key': 'stage_4',
        'icon': Icons.scale_rounded,
        'defaultRemark': weighingRemark,
      },
      ProcurementStageType.qualityCheck: {
        'en': qualityDescEn,
        'ta': qualityDescTa,
        'key': 'stage_5',
        'icon': Icons.verified_rounded,
        'defaultRemark': qualityRemark,
      },
      ProcurementStageType.accepted: {
        'en':
            'Procurement lot accepted into warehouse. Goods receipt generated.',
        'ta': 'சரக்கு கிடங்கில் ஏற்றுக்கொள்ளப்பட்டது. ரசீது உருவாக்கப்பட்டது.',
        'key': 'stage_6',
        'icon': Icons.warehouse_rounded,
        'defaultRemark': 'Warehouse Receipt #GR-9021 Issued',
      },
      ProcurementStageType.paymentProcessing: {
        'en':
            'Bill forwarded to Treasury PFMS / Direct Benefit Transfer (DBT).',
        'ta': 'நேரடி பண பரிமாற்றத்திற்கு (DBT) அரசு கருவூலத்திற்கு அனுப்பப்பட்டது.',
        'key': 'stage_7',
        'icon': Icons.account_balance_rounded,
        'defaultRemark': 'Bill Sent to Treasury PFMS',
      },
      ProcurementStageType.paymentCompleted: {
        'en':
            '₹${_payment.netAmount.toStringAsFixed(0)} successfully credited to bank account.',
        'ta':
            '₹${_payment.netAmount.toStringAsFixed(0)} வங்கி கணக்கில் வரவு வைக்கப்பட்டது.',
        'key': 'stage_8',
        'icon': Icons.task_alt_rounded,
        'defaultRemark': 'DBT Transferred to Bank Account',
      },
    };

    return stages.map((s) {
      final index = stages.indexOf(s);
      final isCompleted =
          index < currentIndex ||
          (index == currentIndex &&
              currentStage == ProcurementStageType.paymentCompleted);
      final isCurrent =
          index == currentIndex &&
          currentStage != ProcurementStageType.paymentCompleted;
      final meta = stageMeta[s]!;

      DateTime? timestamp = _stageTimestamps[s];
      if (timestamp == null) {
        if (isCompleted || isCurrent) {
          timestamp = DateTime.now();
          _stageTimestamps[s] = timestamp;
        }
      }

      final remark =
          _stageRemarks[s] ??
          (isCompleted || isCurrent ? meta['defaultRemark'] as String : null);

      return StageProgressInfo(
        stage: s,
        titleKey: meta['key'] as String,
        descriptionEn: meta['en'] as String,
        descriptionTa: meta['ta'] as String,
        icon: meta['icon'] as IconData,
        isCurrent: isCurrent,
        isCompleted: isCompleted,
        completedTime: timestamp,
        officerRemark: remark,
      );
    }).toList();
  }

  // Officer Controls (Calls backend API & local state)
  Future<void> officerNextQueueToken() async {
    try {
      final newServingStr = await _apiProvider.officerNextQueueToken(centreId: _selectedCenterId);
      if (newServingStr != null) {
        final parsed = int.tryParse(newServingStr.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null) {
          _currentServingTokenNumber = parsed;
        }
      } else {
        _currentServingTokenNumber++;
      }
    } catch (_) {
      _currentServingTokenNumber++;
    }

    final userTokenStr = _activeToken?.tokenNumber ?? 'TK-104';
    final userTokenNum =
        int.tryParse(userTokenStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 104;

    if (_currentServingTokenNumber == userTokenNum) {
      officerSetStage(
        ProcurementStageType.called,
        remark: 'Token called automatically by queue system',
      );
    } else if (userTokenNum - _currentServingTokenNumber == 1) {
      _addNotification(
        titleEn: 'Your Turn is Approaching!',
        titleTa: 'உங்கள் முறை விரைவில் வரவுள்ளது!',
        messageEn: 'You are next in queue. Please be ready near the gate.',
        messageTa: 'அடுத்த முறை உங்களுடையது. வாயில் அருகே தயாராக இருக்கவும்.',
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFFF57C00),
      );
    }

    final idx = _centers.indexWhere((c) => c.id == _selectedCenterId);
    if (idx != -1) {
      _centers[idx] = ProcurementCenter(
        id: _centers[idx].id,
        nameEn: _centers[idx].nameEn,
        nameTa: _centers[idx].nameTa,
        district: _centers[idx].district,
        taluk: _centers[idx].taluk,
        locationAddress: _centers[idx].locationAddress,
        latitude: _centers[idx].latitude,
        longitude: _centers[idx].longitude,
        workingHours: _centers[idx].workingHours,
        contactPhone: _centers[idx].contactPhone,
        status: _centers[idx].status,
        statusReason: _centers[idx].statusReason,
        dailyCapacityBags: _centers[idx].dailyCapacityBags,
        activeTokensCount: math.max(0, _centers[idx].activeTokensCount - 1),
        currentServingToken: _currentServingTokenNumber,
        avgWaitMinutes: _centers[idx].avgWaitMinutes,
      );
    }

    notifyListeners();
  }

  Future<void> officerSetCentreStatus(String status, {String? reason}) async {
    final idx = _centers.indexWhere((c) => c.id == _selectedCenterId);
    if (idx != -1) {
      _centers[idx] = ProcurementCenter(
        id: _centers[idx].id,
        nameEn: _centers[idx].nameEn,
        nameTa: _centers[idx].nameTa,
        district: _centers[idx].district,
        taluk: _centers[idx].taluk,
        locationAddress: _centers[idx].locationAddress,
        latitude: _centers[idx].latitude,
        longitude: _centers[idx].longitude,
        workingHours: _centers[idx].workingHours,
        contactPhone: _centers[idx].contactPhone,
        status: status,
        statusReason: reason,
        dailyCapacityBags: _centers[idx].dailyCapacityBags,
        activeTokensCount: _centers[idx].activeTokensCount,
        currentServingToken: _centers[idx].currentServingToken,
        avgWaitMinutes: _centers[idx].avgWaitMinutes,
      );
    }

    try {
      await _apiProvider.officerSetCentreStatus(status, reason: reason, centreId: _selectedCenterId);
    } catch (_) {}

    if (status == 'CLOSED') {
      final reasonMsg = reason != null && reason.isNotEmpty ? ' Reason: $reason' : '';
      final reasonMsgTa = reason != null && reason.isNotEmpty ? ' காரணம்: $reason' : '';
      _addNotification(
        titleEn: 'Your Procurement Centre is Currently Closed',
        titleTa: 'உங்கள் கொள்முதல் மையம் தற்போது மூடப்பட்டுள்ளது',
        messageEn: 'Administrative officers have marked this centre CLOSED.$reasonMsg',
        messageTa: 'அதிகாரிகள் இந்த மையத்தை மூடியுள்ளனர்.$reasonMsgTa',
        icon: Icons.error_outline_rounded,
        color: Colors.red,
      );
    }

    notifyListeners();
  }

  void officerSetServingToken(int tokenNum) {
    _currentServingTokenNumber = tokenNum;
    notifyListeners();
  }

  void officerAdvanceToNextStage({String? remark}) {
    if (_activeToken == null) return;
    final stages = ProcurementStageType.values;
    final currIndex = stages.indexOf(_activeToken!.currentStage);
    if (currIndex < stages.length - 1) {
      officerSetStage(stages[currIndex + 1], remark: remark);
    }
  }

  Future<void> officerSetStage(ProcurementStageType stage, {String? remark}) async {
    if (_activeToken == null) return;
    _activeToken = _activeToken!.copyWith(currentStage: stage);
    _stageTimestamps[stage] ??= DateTime.now();
    if (remark != null && remark.isNotEmpty) {
      _stageRemarks[stage] = remark;
    }

    final stages = ProcurementStageType.values;
    final targetIdx = stages.indexOf(stage);
    for (int i = 0; i <= targetIdx; i++) {
      final s = stages[i];
      if (!_stageTimestamps.containsKey(s)) {
        _stageTimestamps[s] = DateTime.now();
      }
    }

    if (stage == ProcurementStageType.paymentCompleted) {
      _payment = _payment.copyWith(
        status: PaymentStatus.completed,
        paymentDate: DateTime.now(),
        bankReferenceNumber:
            'DBT-TN-${DateTime.now().millisecondsSinceEpoch % 10000000}',
      );
    } else if (stage == ProcurementStageType.paymentProcessing) {
      _payment = _payment.copyWith(status: PaymentStatus.processing);
    }

    try {
      await _apiProvider.officerUpdateStage(stageIndex: targetIdx, remark: remark);
    } catch (_) {}

    notifyListeners();
  }

  void officerUpdateWeighment({
    required double quintals,
    required int bags,
    required double moisture,
    required String grade,
  }) {
    final netAmt =
        (quintals * _payment.mspRatePerQuintal) - _payment.deductions;
    _payment = _payment.copyWith(
      quantityQuintals: quintals,
      bagCount: bags,
      moisturePercentage: moisture,
      qualityGrade: grade,
      netAmount: netAmt,
    );
    if (_activeToken != null) {
      _activeToken = _activeToken!.copyWith(
        estimatedQuintals: quintals,
        estimatedBags: bags,
      );
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    _notifications = _notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void _addNotification({
    required String titleEn,
    required String titleTa,
    required String messageEn,
    required String messageTa,
    required IconData icon,
    required Color color,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        titleEn: titleEn,
        titleTa: titleTa,
        messageEn: messageEn,
        messageTa: messageTa,
        timestamp: DateTime.now(),
        icon: icon,
        color: color,
        isRead: false,
      ),
    );
  }

  @override
  void dispose() {
    _queueSimulationTimer?.cancel();
    super.dispose();
  }
}
