import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_theme.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/auth/app_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmerProcurementApp());
}

class FarmerProcurementApp extends StatelessWidget {
  const FarmerProcurementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return MaterialApp(
          title: 'Farmer Procurement Management Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AppSelectionScreen(),
        );
      },
    );
  }
}
