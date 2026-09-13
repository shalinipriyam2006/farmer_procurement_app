import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/token/book_token_screen.dart';

class MissedSlotScreen extends StatelessWidget {
  const MissedSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;
    final center = repo.currentCenter;
    final centerName = isTamil ? center.nameTa : center.nameEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTamil ? 'தவறிய நேரம் சரிசெய்தல்' : 'Missed Slot Recovery'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.shade300, width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_busy_rounded, color: AppColors.error, size: 64),
                  const SizedBox(height: 14),
                  Text(
                    isTamil ? 'தவறிய கொள்முதல் நேரம்' : 'Missed Procurement Slot',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil
                        ? 'உங்கள் டோக்கன் நேரம் கடந்துவிட்டது. கவலைப்பட வேண்டாம், புதிய நேரத்திற்கு கோரிக்கை விடுக்கலாம்.'
                        : 'Your allocated time slot has expired. You can request a replacement slot without losing your verification status.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Options
            Text(
              isTamil ? 'அடுத்த நடவடிக்கை' : 'Choose Recovery Action',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Option 1: Request New Slot
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
                ),
                title: Text(
                  isTamil ? 'புதிய நேரம் கோருக' : 'Request New Slot',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isTamil ? 'அடுத்த கிடைக்கும் நேரத்திற்கு புதிய டோக்கன் பெறவும்' : 'Book the next available slot for this week',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const BookTokenScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Option 2: View Available Slots
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_available_rounded, color: AppColors.secondary),
                ),
                title: Text(
                  isTamil ? 'கிடைக்கும் நேரங்கள் பார்க்க' : 'View Available Centre Slots',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$centerName • ${center.workingHours}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Checking live slot capacity at $centerName...'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Option 3: Contact Centre Officer
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded, color: Colors.blue),
                ),
                title: Text(
                  isTamil ? 'மைய அதிகாரியை தொடர்பு கொள்ள' : 'Contact Centre Helpline',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(center.contactPhone),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling Centre Helpline: ${center.contactPhone}'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
