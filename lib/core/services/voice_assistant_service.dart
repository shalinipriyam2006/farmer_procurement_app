import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:farmer_procurement_app/core/models/queue_model.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';

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

    // 3. PAYMENT STATUS
    if (lower.contains('payment') ||
        lower.contains('bank') ||
        lower.contains('payout') ||
        lower.contains('money') ||
        lower.contains('account') ||
        lower.contains('dbt') ||
        lower.contains('பணம்') ||
        lower.contains('வங்கி') ||
        lower.contains('கணக்கு')) {
      return const VoiceQueryResponse(
        intent: 'PAYMENT_STATUS',
        textEn: 'Payment Status: ₹46,400 initiated via Direct Benefit Transfer to bank account ending •••• 7821.',
        textTa: 'பணப்பரிமாற்ற நிலை: Direct Benefit Transfer மூலம் •••• 7821 வங்கிக் கணக்கிற்கு ₹46,400 அனுப்பப்பட்டுள்ளது.',
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

    // 6. WORKING HOURS
    if (lower.contains('hours') ||
        lower.contains('open') ||
        lower.contains('close') ||
        lower.contains('timing') ||
        lower.contains('schedule') ||
        lower.contains('வேலை நேரம்') ||
        lower.contains('திறக்கும்') ||
        lower.contains('மூடும்')) {
      final hours = currentCenter.workingHours;
      return VoiceQueryResponse(
        intent: 'WORKING_HOURS',
        textEn: 'Procurement centre working hours are $hours, Monday through Saturday.',
        textTa: 'கொள்முதல் மையத்தின் வேலை நேரம்: $hours (திங்கள் முதல் சனி வரை).',
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
