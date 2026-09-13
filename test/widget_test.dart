import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_procurement_app/main.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/services/voice_assistant_service.dart';
import 'package:farmer_procurement_app/core/services/location_service.dart';

void main() {
  testWidgets('Farmer Procurement App portal landing & navigation test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FarmerProcurementApp());
    await tester.pumpAndSettle();

    // Verify AppSelectionScreen loads with both Farmer and Officer access portals
    expect(find.textContaining('Farmer Procurement'), findsWidgets);
    expect(find.text('Farmer Application'), findsOneWidget);
    expect(find.text('Officer Application'), findsOneWidget);

    // Tap 'Farmer Application' to navigate to Main Nav Scaffold
    await tester.tap(find.text('Farmer Application'));
    await tester.pumpAndSettle();

    // Verify Farmer Home Screen
    expect(find.textContaining('Murugan Ramanathan'), findsWidgets);

    // Tap Language button
    final langBtn = find.byIcon(Icons.translate_rounded);
    expect(langBtn, findsOneWidget);
    await tester.tap(langBtn);
    await tester.pumpAndSettle();

    // Verify Tamil text
    expect(find.text('உழவர் கொள்முதல்'), findsWidgets);

    // Switch back to English
    await tester.tap(langBtn);
    await tester.pumpAndSettle();
  });

  test('ProcurementRepository state changes & voice assistant tests', () {
    final repo = ProcurementRepository();

    // Initial State
    expect(repo.isLoggedIn, true);
    expect(repo.activeToken != null, true);
    expect(repo.language, AppLanguage.english);

    // Voice Assistant Query Parsing Test (English)
    final resEn = VoiceAssistantService.processLiveQueueVoiceQuery(
      query: 'How many farmers are ahead of me?',
      queueState: repo.getQueueState(),
      activeToken: repo.activeToken,
      currentCenter: repo.currentCenter,
      isTamil: false,
    );
    expect(resEn.textEn, contains('farmers ahead of you'));

    // Voice Assistant Query Parsing Test (Tamil)
    final resTa = VoiceAssistantService.processLiveQueueVoiceQuery(
      query: 'எனக்கு முன்னாடி எத்தனை விவசாயிகள் இருக்கிறார்கள்?',
      queueState: repo.getQueueState(),
      activeToken: repo.activeToken,
      currentCenter: repo.currentCenter,
      isTamil: true,
    );
    expect(resTa.textTa, contains('விவசாயிகள் உள்ளனர்'));

    // Location Service Distance Test
    final dist = LocationService.calculateDistanceKm(10.7867, 79.1378, 10.8797, 79.1039);
    expect(dist > 0, true);

    // 8-Stage Controller Test
    for (final stage in ProcurementStageType.values) {
      repo.officerSetStage(stage);
      expect(repo.activeToken?.currentStage, stage);
    }
    expect(repo.payment.status.name, 'completed');
  });
}
