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

class VoiceAssistantService {
  static VoiceQueryResponse processLiveQueueVoiceQuery({
    required String query,
    required QueueStateModel queueState,
    required TokenModel? activeToken,
    required ProcurementCenter currentCenter,
    required bool isTamil,
  }) {
    final lower = query.toLowerCase();

    // 1. "How many farmers are ahead of me?" / "எனக்கு முன்னாடி எத்தனை"
    if (lower.contains('ahead') ||
        lower.contains('how many') ||
        lower.contains('முன்னாடி') ||
        lower.contains('எத்தனை')) {
      final ahead = queueState.farmersAhead;
      final mins = queueState.estimatedWaitMinutes;

      return VoiceQueryResponse(
        intent: 'farmers_ahead',
        textEn: 'You have $ahead farmers ahead of you. Your estimated waiting time is $mins minutes.',
        textTa: 'உங்களுக்கு முன்னால் $ahead விவசாயிகள் உள்ளனர். உங்கள் மதிப்பிடப்பட்ட காத்திருப்பு நேரம் $mins நிமிடங்கள்.',
      );
    }

    // 2. "What is my token number?" / "என்னுடைய டோக்கன் எண்"
    if (lower.contains('token') ||
        lower.contains('number') ||
        lower.contains('டோக்கன்')) {
      final tokenNum = activeToken?.tokenNumber ?? queueState.userToken;

      return VoiceQueryResponse(
        intent: 'token_number',
        textEn: 'Your active digital procurement token number is $tokenNum.',
        textTa: 'உங்கள் டிஜிட்டல் கொள்முதல் டோக்கன் எண் $tokenNum ஆகும்.',
      );
    }

    // 3. "How much time is remaining?" / "எவ்வளவு நேரம்" / "காத்திருப்பு"
    if (lower.contains('time') ||
        lower.contains('remaining') ||
        lower.contains('wait') ||
        lower.contains('நேரம்')) {
      final mins = queueState.estimatedWaitMinutes;

      return VoiceQueryResponse(
        intent: 'time_remaining',
        textEn: 'Estimated waiting time remaining is approximately $mins minutes.',
        textTa: 'உங்கள் தோராயமான காத்திருப்பு நேரம் $mins நிமிடங்கள் ஆகும்.',
      );
    }

    // 4. "Where is my procurement centre?" / "மையம் எங்கே" / "கொள்முதல் நிலையம்"
    if (lower.contains('centre') ||
        lower.contains('center') ||
        lower.contains('where') ||
        lower.contains('மையம்') ||
        lower.contains('இடம்')) {
      final centreName = isTamil ? currentCenter.nameTa : currentCenter.nameEn;
      final address = currentCenter.locationAddress;

      return VoiceQueryResponse(
        intent: 'centre_location',
        textEn: 'Your assigned procurement centre is $centreName located at $address.',
        textTa: 'உங்கள் கொள்முதல் மையம் $centreName, முகவரி: $address.',
      );
    }

    // 5. "Has my procurement started?" / "துவங்கியதா" / "சமர்ப்பணம்"
    if (lower.contains('started') ||
        lower.contains('turn') ||
        lower.contains('முறை') ||
        lower.contains('ஆரம்பம்')) {
      final isTurn = queueState.farmersAhead == 0;
      if (isTurn) {
        return const VoiceQueryResponse(
          intent: 'status_check',
          textEn: 'Yes! It is your turn now. Please proceed immediately to Bay 2.',
          textTa: 'ஆம்! உங்கள் முறை வந்துவிட்டது. எடை மேடை 2-க்கு உடனடியாக செல்லவும்.',
        );
      } else {
        return VoiceQueryResponse(
          intent: 'status_check',
          textEn: 'Not yet. Currently token ${queueState.currentServingToken} is being served. You are #${queueState.farmersAhead} in line.',
          textTa: 'இன்னும் இல்லை. தற்போது டோக்கன் ${queueState.currentServingToken} நடைபெறுகிறது. நீங்கள் வரிசையில் #${queueState.farmersAhead} ஆக உள்ளீர்கள்.',
        );
      }
    }

    // Default Fallback
    final ahead = queueState.farmersAhead;
    final mins = queueState.estimatedWaitMinutes;
    final tokenNum = activeToken?.tokenNumber ?? queueState.userToken;

    return VoiceQueryResponse(
      intent: 'general_status',
      textEn: 'Token $tokenNum: $ahead farmers ahead. Estimated wait $mins minutes.',
      textTa: 'டோக்கன் $tokenNum: $ahead நபர்கள் முன்னால் உள்ளனர். காத்திருப்பு $mins நிமிடம்.',
    );
  }
}
