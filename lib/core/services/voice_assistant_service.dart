import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';

class VoiceQueryResponse {
  final String textEn;
  final String textTa;
  final String intent;

  const VoiceQueryResponse({
    required this.textEn,
    required this.textTa,
    required this.intent,
  });
}

class TtsPlaybackResult {
  final bool isSuccess;
  final String spokenText;
  final String? warningMessage;

  const TtsPlaybackResult({
    required this.isSuccess,
    required this.spokenText,
    this.warningMessage,
  });
}

class VoiceAssistantService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool _hasTtsErrorOccurred = false;

  /// Initialize TTS engine settings with error handlers
  static Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[VoiceAssistantService] FlutterTTS error handler: $msg');
        _hasTtsErrorOccurred = true;
      });

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.setQueueMode(1); // 1 = REPLACE
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('[VoiceAssistantService] TTS init error: $e');
      _hasTtsErrorOccurred = true;
    }
  }

  /// Stop any ongoing speech
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  /// Speak text dynamically in English or Tamil with fallback handling
  static Future<TtsPlaybackResult> speak(String text, {required bool isTamil}) async {
    if (_hasTtsErrorOccurred && kIsWeb) {
      return TtsPlaybackResult(
        isSuccess: false,
        spokenText: text,
        warningMessage: 'Voice assistance is unavailable on this browser.',
      );
    }

    await _initTts();
    await stop();

    final targetLang = isTamil ? 'ta-IN' : 'en-US';

    try {
      bool isAvailable = false;
      try {
        final check = await _flutterTts.isLanguageAvailable(targetLang);
        isAvailable = (check == true || check == 1);
      } catch (_) {
        isAvailable = true;
      }

      if (isTamil && !isAvailable) {
        try {
          await _flutterTts.setLanguage('en-US');
          await _flutterTts.speak('Tamil voice synthesis engine is not installed on this device. $text');
          return TtsPlaybackResult(
            isSuccess: true,
            spokenText: text,
            warningMessage: 'Tamil voice engine missing on device. Spoke in fallback mode.',
          );
        } catch (e) {
          _hasTtsErrorOccurred = true;
          return TtsPlaybackResult(
            isSuccess: false,
            spokenText: text,
            warningMessage: 'Voice synthesis is unavailable on this device.',
          );
        }
      }

      await _flutterTts.setLanguage(targetLang);
      final result = await _flutterTts.speak(text);

      if (result == 1 || result == true) {
        return TtsPlaybackResult(isSuccess: true, spokenText: text);
      } else {
        return TtsPlaybackResult(
          isSuccess: false,
          spokenText: text,
          warningMessage: 'Voice assistance is unavailable on this browser.',
        );
      }
    } catch (e) {
      debugPrint('[VoiceAssistantService] Speak error: $e');
      _hasTtsErrorOccurred = true;
      return TtsPlaybackResult(
        isSuccess: false,
        spokenText: text,
        warningMessage: 'Voice assistance is unavailable on this browser.',
      );
    }
  }

  /// Test Voice feature button action
  static Future<TtsPlaybackResult> testVoice({required bool isTamil}) {
    if (isTamil) {
      return speak(
        'உங்கள் டோக்கன் TK-104. உங்களுக்கு முன்னால் 3 விவசாயிகள் உள்ளனர்.',
        isTamil: true,
      );
    } else {
      return speak(
        'Your token is TK-104. There are 3 farmers ahead of you.',
        isTamil: false,
      );
    }
  }

  /// Comprehensive Multilingual Intent-Based Assistant Processor
  static VoiceQueryResponse processLiveQueueVoiceQuery({
    required String query,
    required QueueStateModel queueState,
    required TokenModel? activeToken,
    required ProcurementCenter currentCenter,
    required bool isTamil,
  }) {
    final lower = query.toLowerCase().trim();

    // 1. HELP / ASSISTANCE
    if (lower.contains('help') ||
        lower.contains('command') ||
        lower.contains('what can i ask') ||
        lower.contains('உதவி') ||
        lower.contains('கேள்வி')) {
      return const VoiceQueryResponse(
        intent: 'HELP',
        textEn: 'You can ask about your queue status, waiting time, token number, centre location, procurement rates, payment status, or required documents.',
        textTa: 'வரிசை நிலை, காத்திருப்பு நேரம், டோக்கன் எண், மையம் அமைவிடம், கொள்முதல் விலை, பணப்பரிமாற்றம் அல்லது தேவையான ஆவணங்கள் பற்றி கேட்கலாம்.',
      );
    }

    // 2. PROCUREMENT RATES
    if (lower.contains('rate') ||
        lower.contains('price') ||
        lower.contains('quintal') ||
        lower.contains('cost') ||
        lower.contains('msp') ||
        lower.contains('விலை') ||
        lower.contains('விகிதம்') ||
        lower.contains('ரூபாய்')) {
      return const VoiceQueryResponse(
        intent: 'PROCUREMENT_RATE',
        textEn: 'Current procurement rates: Paddy Grade A is ₹2,320 per quintal, Paddy Common is ₹2,300 per quintal.',
        textTa: 'தற்போதைய கொள்முதல் விலை: நெல் கிரேடு ஏ க்விண்டாலுக்கு ₹2,320, சாதாரண நெல் க்விண்டாலுக்கு ₹2,300 ஆகும்.',
      );
    }

    // 3. PAYMENT STATUS & SLIP
    if (lower.contains('payment') ||
        lower.contains('bank') ||
        lower.contains('payout') ||
        lower.contains('money') ||
        lower.contains('account') ||
        lower.contains('dbt') ||
        lower.contains('credit') ||
        lower.contains('பணம்') ||
        lower.contains('வங்கி') ||
        lower.contains('கணக்கு') ||
        lower.contains('வந்துவிட்டதா')) {
      if (lower.contains('show') || lower.contains('slip') || lower.contains('view') || lower.contains('காண்பி')) {
        return const VoiceQueryResponse(
          intent: 'NAVIGATE_PAYMENT',
          textEn: 'Opening your digital Treasury Payment Voucher...',
          textTa: 'உங்கள் அரசு கருவூல செலுத்துகை ரசீதை திறக்கிறது...',
        );
      }
      final isPaymentDone = activeToken?.currentStage == ProcurementStageType.paymentCompleted;
      return VoiceQueryResponse(
        intent: 'PAYMENT_STATUS',
        textEn: isPaymentDone
            ? 'Payment Status: ₹59,160.00 successfully credited to your bank account via Direct Benefit Transfer.'
            : 'Payment Status: Payout calculation in progress based on recorded scale weighment.',
        textTa: isPaymentDone
            ? 'பணப்பரிமாற்ற நிலை: ₹59,160.00 உங்கள் வங்கிக் கணக்கில் வெற்றிகரமாக வரவு வைக்கப்பட்டது.'
            : 'பணப்பரிமாற்ற நிலை: எடை பதிவின் அடிப்படையில் கணக்கிடப்பட்டு வருகிறது.',
      );
    }

    // 4. CROP ACCEPTANCE & QUALITY
    if (lower.contains('accepted') ||
        lower.contains('rejected') ||
        lower.contains('quality') ||
        lower.contains('moisture') ||
        lower.contains('pass') ||
        lower.contains('ஏற்றுக்கொள்ளப்பட்டது') ||
        lower.contains('நிராகரிப்பு') ||
        lower.contains('ஈரப்பதம்')) {
      final isAcc = activeToken != null && activeToken.currentStageIndex >= 5 && activeToken.status != TokenStatus.cancelled;
      return VoiceQueryResponse(
        intent: 'CROP_ACCEPTANCE',
        textEn: isAcc
            ? 'Crop Status: ACCEPTED (Grade A FAQ Standard). Moisture content verified at 14.2%.'
            : 'Crop Status: Quality inspection is in progress at Quality Bay #01.',
        textTa: isAcc
            ? 'பயிர் நிலை: ஏற்றுக்கொள்ளப்பட்டது (கிரேடு ஏ தரம்). ஈரப்பதம் 14.2% சரிபார்க்கப்பட்டது.'
            : 'பயிர் நிலை: தர பரிசோதனை நடைபெற்று வருகிறது.',
      );
    }

    // 5. VOICE NAVIGATION COMMANDS
    if (lower.contains('show my token') || lower.contains('show token') || lower.contains('என் டோக்கன்')) {
      return const VoiceQueryResponse(
        intent: 'NAVIGATE_TOKEN',
        textEn: 'Opening your Digital Token E-Pass...',
        textTa: 'உங்கள் டிஜிட்டல் டோக்கனை திறக்கிறது...',
      );
    }

    if (lower.contains('show documents') || lower.contains('show document') || lower.contains('ஆவணங்கள்')) {
      return const VoiceQueryResponse(
        intent: 'NAVIGATE_DOCUMENTS',
        textEn: 'Opening Digital Document Center...',
        textTa: 'டிஜிட்டல் ஆவணப் பிரிவை திறக்கிறது...',
      );
    }

    if (lower.contains('call helpdesk') || lower.contains('call support') || lower.contains('உதவி எண்')) {
      return const VoiceQueryResponse(
        intent: 'CALL_HELPDESK',
        textEn: 'Connecting to Procurement Helpdesk toll-free helpline 1800-425-4673...',
        textTa: 'கொள்முதல் உதவி மையம் 1800-425-4673 உடன் இணைக்கிறது...',
      );
    }

    // 6. MISSED SLOT ASSISTANCE
    if (lower.contains('missed') || lower.contains('late') || lower.contains('reschedule') || lower.contains('தவறிவிட்டது')) {
      return const VoiceQueryResponse(
        intent: 'MISSED_SLOT_ASSIST',
        textEn: 'Missed Slot Assistance: You can reschedule your booking to the next available slot directly from the app.',
        textTa: 'தவறிய டோக்கன் உதவி: பயன்பாட்டிலிருந்து நேரடியாக அடுத்த நேர முன்பதிவு செய்யலாம்.',
      );
    }

    // 7. SLOT TIME & WHEN TO GO
    if (lower.contains('when') || lower.contains('time') || lower.contains('slot') || lower.contains('எப்போது')) {
      final slot = activeToken?.timeSlot ?? '09:00 AM - 11:00 AM';
      final date = activeToken?.bookingDate ?? 'Today';
      return VoiceQueryResponse(
        intent: 'SCHEDULED_SLOT',
        textEn: 'Your scheduled procurement slot is $date during $slot.',
        textTa: 'உங்கள் கொள்முதல் நேரம்: $date ($slot).',
      );
    }

    // 4. REQUIRED DOCUMENTS
    if (lower.contains('document') ||
        lower.contains('doc') ||
        lower.contains('patta') ||
        lower.contains('chitta') ||
        lower.contains('aadhaar') ||
        lower.contains('ஆவணம்') ||
        lower.contains('பட்டா') ||
        lower.contains('சிட்டா') ||
        lower.contains('ஆதார்')) {
      return const VoiceQueryResponse(
        intent: 'DOCUMENTS',
        textEn: 'Required documents: Aadhaar card, Chitta/Patta land document, and Bank Passbook first page.',
        textTa: 'தேவையான ஆவணங்கள்: ஆதார் அட்டை, சிட்டா/பட்டா நில ஆவணம் மற்றும் வங்கி கணக்கு புத்தகத்தின் முதல் பக்கம்.',
      );
    }

    // 5. E-PASS & GATE ENTRY
    if (lower.contains('epass') ||
        lower.contains('e-pass') ||
        lower.contains('gate') ||
        lower.contains('entry') ||
        lower.contains('qr') ||
        lower.contains('கேட்') ||
        lower.contains('நுழைவு')) {
      final tokenNum = activeToken?.tokenNumber ?? queueState.userToken;
      return VoiceQueryResponse(
        intent: 'E_PASS',
        textEn: 'Digital E-Pass: Token $tokenNum is active for Gate Entry at Bay 2. Show QR code to officer.',
        textTa: 'டிஜிட்டல் ஈ-பாஸ்: டோக்கன் $tokenNum எடை மேடை 2 நுழைவுக்கு தயார். QR குறியீட்டை அதிகாரியிடம் காண்பிக்கவும்.',
      );
    }

    // 6. WORKING HOURS & CENTRE STATUS
    if (lower.contains('hours') ||
        lower.contains('open') ||
        lower.contains('close') ||
        lower.contains('closed') ||
        lower.contains('timing') ||
        lower.contains('schedule') ||
        lower.contains('reason') ||
        lower.contains('why') ||
        lower.contains('வேலை நேரம்') ||
        lower.contains('திறக்கும்') ||
        lower.contains('மூடும்') ||
        lower.contains('காரணம்') ||
        lower.contains('மூடப்பட்டு')) {
      if (currentCenter.status == 'CLOSED') {
        final reason = currentCenter.statusReason != null && currentCenter.statusReason!.isNotEmpty
            ? currentCenter.statusReason!
            : (isTamil ? 'நிர்வாகக் காரணங்கள்' : 'Administrative reasons');
        return VoiceQueryResponse(
          intent: 'CENTRE_STATUS',
          textEn: 'Procurement Centre ${currentCenter.nameEn} is currently CLOSED. Reason: $reason.',
          textTa: 'கொள்முதல் மையம் ${currentCenter.nameTa} தற்போது மூடப்பட்டுள்ளது. காரணம்: $reason.',
        );
      }
      final hours = currentCenter.workingHours;
      return VoiceQueryResponse(
        intent: 'WORKING_HOURS',
        textEn: 'Procurement centre ${currentCenter.nameEn} is OPEN. Working hours are $hours, Monday through Saturday.',
        textTa: 'கொள்முதல் மையம் ${currentCenter.nameTa} திறந்து இயங்குகிறது. வேலை நேரம்: $hours (திங்கள் முதல் சனி வரை).',
      );
    }

    // 7. GRIEVANCE / HELPLINE
    if (lower.contains('grievance') ||
        lower.contains('complain') ||
        lower.contains('complaint') ||
        lower.contains('helpline') ||
        lower.contains('issue') ||
        lower.contains('problem') ||
        lower.contains('புகார்') ||
        lower.contains('பிரச்சனை')) {
      return const VoiceQueryResponse(
        intent: 'GRIEVANCE',
        textEn: 'For grievances or complaints, submit via the Grievances section or call toll-free helpline 1800-425-1234.',
        textTa: 'புகார்களுக்கு, பயன்பாட்டின் புகார் பிரிவில் பதிவு செய்யலம் அல்லது 1800-425-1234 இலவச எண்ணை அழைக்கலாம்.',
      );
    }

    // 8. CENTRE LOCATION / RECOMMENDATION / CHANGE
    if (lower.contains('centre') ||
        lower.contains('center') ||
        lower.contains('where') ||
        lower.contains('location') ||
        lower.contains('address') ||
        lower.contains('near') ||
        lower.contains('மையம்') ||
        lower.contains('நிலையம்') ||
        lower.contains('இடம்') ||
        lower.contains('முகவரி')) {
      final centreName = isTamil ? currentCenter.nameTa : currentCenter.nameEn;
      final address = currentCenter.locationAddress;
      return VoiceQueryResponse(
        intent: 'CENTRE_SEARCH',
        textEn: 'Your active procurement centre is $centreName located at $address.',
        textTa: 'உங்கள் கொள்முதல் மையம் $centreName, முகவரி: $address.',
      );
    }

    // 9. TOKEN NUMBER & STATUS
    if (lower.contains('token') ||
        lower.contains('number') ||
        lower.contains('டோக்கன்')) {
      final tokenNum = activeToken?.tokenNumber ?? queueState.userToken;
      return VoiceQueryResponse(
        intent: 'TOKEN_STATUS',
        textEn: 'Your active digital procurement token number is $tokenNum.',
        textTa: 'உங்கள் டிஜிட்டல் கொள்முதல் டோக்கன் எண் $tokenNum ஆகும்.',
      );
    }

    // 10. TIME REMAINING / WAIT TIME
    if (lower.contains('time') ||
        lower.contains('remaining') ||
        lower.contains('wait') ||
        lower.contains('நேரம்') ||
        lower.contains('காத்திருப்பு')) {
      final mins = queueState.estimatedWaitMinutes;
      return VoiceQueryResponse(
        intent: 'WAIT_TIME',
        textEn: 'Estimated waiting time remaining is approximately $mins minutes.',
        textTa: 'உங்கள் தோராயமான காத்திருப்பு நேரம் $mins நிமிடங்கள் ஆகும்.',
      );
    }

    // 11. QUEUE STATUS / FARMERS AHEAD / TURN
    if (lower.contains('ahead') ||
        lower.contains('how many') ||
        lower.contains('turn') ||
        lower.contains('started') ||
        lower.contains('முன்னாடி') ||
        lower.contains('எத்தனை') ||
        lower.contains('முறை')) {
      final ahead = queueState.farmersAhead;
      final mins = queueState.estimatedWaitMinutes;
      final serving = queueState.currentServingToken;
      return VoiceQueryResponse(
        intent: 'QUEUE_STATUS',
        textEn: 'Currently token $serving is being served. You have $ahead farmers ahead of you (~$mins mins wait).',
        textTa: 'தற்போது டோக்கன் $serving நடைபெறுகிறது. உங்களுக்கு முன்னால் $ahead விவசாயிகள் உள்ளனர் (~$mins நிமிடம் காத்திருப்பு).',
      );
    }

    // Default Fallback
    final ahead = queueState.farmersAhead;
    final mins = queueState.estimatedWaitMinutes;
    final tokenNum = activeToken?.tokenNumber ?? queueState.userToken;

    return VoiceQueryResponse(
      intent: 'QUEUE_STATUS',
      textEn: 'Token $tokenNum: $ahead farmers ahead of you. Estimated wait is $mins minutes.',
      textTa: 'டோக்கன் $tokenNum: $ahead நபர்கள் முன்னால் உள்ளனர். காத்திருப்பு $mins நிமிடம்.',
    );
  }
}
