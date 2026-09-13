import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/models/farmer_profile.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/core/models/app_notification.dart';

class MockData {
  static final FarmerProfile demoFarmer = FarmerProfile(
    id: 'FARMER-001',
    name: 'Murugan Ramanathan',
    mobileNumber: '9876543210',
    farmerIdNumber: 'TN-KISAN-84920',
    village: 'Thiruvaiyaru',
    district: 'Thanjavur',
    preferredCentreId: 'CENTRE-01',
    bankAccountMasked: '•••• •••• 7821',
    ifscCode: 'SBIN0001234',
    landHoldingAcres: 3.5,
  );

  static final List<ProcurementCenter> centers = [
    const ProcurementCenter(
      id: 'CENTRE-01',
      nameEn: 'Thanjavur Direct Purchase Centre',
      nameTa: 'தஞ்சாவூர் நேரடி நெல் கொள்முதல் நிலையம்',
      district: 'Thanjavur',
      locationAddress:
          'Market Committee Road, Thiruvaiyaru, Thanjavur - 613204',
      workingHours: '08:30 AM - 05:30 PM',
      contactPhone: '+91 4362 278100',
      dailyCapacityBags: 1200,
      activeTokensCount: 38,
      currentServingToken: 101,
      avgWaitMinutes: 12.0,
    ),
    const ProcurementCenter(
      id: 'CENTRE-02',
      nameEn: 'Tiruvarur Agricultural Marketing Committee',
      nameTa: 'திருவாரூர் வேளாண் விற்பனை குழு மையம்',
      district: 'Tiruvarur',
      locationAddress: 'Kudavasal Main Road, Tiruvarur - 610001',
      workingHours: '09:00 AM - 05:00 PM',
      contactPhone: '+91 4366 220199',
      dailyCapacityBags: 1000,
      activeTokensCount: 42,
      currentServingToken: 88,
      avgWaitMinutes: 15.0,
    ),
    const ProcurementCenter(
      id: 'CENTRE-03',
      nameEn: 'Tiruchirappalli Regulated Market',
      nameTa: 'திருச்சிராப்பள்ளி ஒழுங்குமுறை விற்பனைக்கூடம்',
      district: 'Tiruchirappalli',
      locationAddress: 'Manachanallur Road, Trichy - 620005',
      workingHours: '08:30 AM - 05:30 PM',
      contactPhone: '+91 431 2410882',
      dailyCapacityBags: 1500,
      activeTokensCount: 29,
      currentServingToken: 54,
      avgWaitMinutes: 10.0,
    ),
    const ProcurementCenter(
      id: 'CENTRE-04',
      nameEn: 'Madurai Vadipatti DPC',
      nameTa: 'மதுரை வாடிப்பட்டி நேரடி கொள்முதல் மையம்',
      district: 'Madurai',
      locationAddress: 'Bypass Road, Vadipatti, Madurai - 625218',
      workingHours: '09:00 AM - 05:00 PM',
      contactPhone: '+91 452 2541200',
      dailyCapacityBags: 800,
      activeTokensCount: 22,
      currentServingToken: 31,
      avgWaitMinutes: 14.0,
    ),
  ];

  static TokenModel get initialToken => TokenModel(
    id: 'TOKEN-2026-104',
    tokenNumber: 'TK-104',
    farmerId: demoFarmer.id,
    farmerName: demoFarmer.name,
    centreId: centers[0].id,
    centreNameEn: centers[0].nameEn,
    centreNameTa: centers[0].nameTa,
    bookingDate: 'Today (இன்று)',
    timeSlot: '10:30 AM - 12:00 PM',
    cropNameEn: 'Paddy (Grade A)',
    cropNameTa: 'நெல் (கிரேடு ஏ)',
    estimatedQuintals: 30.0,
    estimatedBags: 45,
    queuePosition: 4,
    currentStage: ProcurementStageType.called,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  static PaymentModel get initialPayment => PaymentModel(
    id: 'PAY-TN-2026-9932',
    tokenNumber: 'TK-104',
    cropNameEn: 'Paddy (Grade A)',
    cropNameTa: 'நெல் (கிரேடு ஏ)',
    quantityQuintals: 30.0,
    bagCount: 45,
    mspRatePerQuintal: 2320.0, // Indian MSP rate
    deductions: 450.0, // Handling & 0.5% moisture variance
    netAmount: (30.0 * 2320.0) - 450.0, // 69,150
    status: PaymentStatus.processing,
    paymentDate: null,
    bankReferenceNumber: 'PFMS-TN-8492049281',
    maskedBankAccount: '•••• •••• 7821',
    ifscCode: 'SBIN0001234',
    qualityGrade: 'Grade A (Common Fair Average Quality)',
    moisturePercentage: 14.2,
  );

  static List<AppNotification> get initialNotifications => [
    AppNotification(
      id: 'NOTIF-1',
      titleEn: 'Digital Token Generated',
      titleTa: 'டிஜிட்டல் டோக்கன் உருவாக்கப்பட்டது',
      messageEn:
          'Token TK-104 has been issued for Thanjavur DPC. Slot: 10:30 AM.',
      messageTa: 'தஞ்சாவூர் மையத்திற்கு டோக்கன் TK-104 வழங்கப்பட்டுள்ளது. நேரம்: 10:30 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.confirmation_number_rounded,
      color: const Color(0xFF1B5E20),
      isRead: true,
    ),
    AppNotification(
      id: 'NOTIF-2',
      titleEn: 'Your Turn is Approaching',
      titleTa: 'உங்கள் முறை நெருங்குகிறது',
      messageEn:
          'Token TK-102 is currently being served. Please remain near gate.',
      messageTa: 'டோக்கன் TK-102 தற்போது நடைபெறுகிறது. வாயில் அருகே தயார் நிலையில் இருக்கவும்.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      icon: Icons.notifications_active_rounded,
      color: const Color(0xFFE65100),
      isRead: false,
    ),
    AppNotification(
      id: 'NOTIF-3',
      titleEn: 'Called for Entry & Weighing',
      titleTa: 'நுழைவு மற்றும் எடை போட அழைக்கப்பட்டது',
      messageEn:
          'Token TK-104 has been called by the Procurement Officer to Bay 2.',
      messageTa: 'டோக்கன் TK-104 கொள்முதல் அதிகாரியால் எடை போடும் பகுதி 2-க்கு அழைக்கப்பட்டது.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      icon: Icons.scale_rounded,
      color: const Color(0xFF2E7D32),
      isRead: false,
    ),
  ];
}
