import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});

  @override
  State<GrievanceScreen> createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Quality & Moisture Test';
  bool _isSubmitting = false;

  final List<String> _categoriesEn = [
    'Quality & Moisture Test',
    'Weighbridge Discrepancy',
    'Token & Slot Delay',
    'Payment & Payout Status',
    'Centre Facilities & Assistance',
    'Other Issue'
  ];

  final List<Map<String, dynamic>> _mockGrievances = [
    {
      'id': 'GRV-8021',
      'category': 'Quality & Moisture Test',
      'description': 'Moisture tester reading variance noted at Bay 2.',
      'status': 'IN PROGRESS',
      'date': 'Yesterday 04:30 PM',
      'remarks': 'Quality inspector dispatched to inspect bay calibrator.'
    },
    {
      'id': 'GRV-7910',
      'category': 'Payment & Payout Status',
      'description': 'Request for direct DBT reference update.',
      'status': 'RESOLVED',
      'date': '10 Sep 2026',
      'remarks': 'PFMS Treasury reference updated successfully.'
    }
  ];

  void _submitComplaint() {
    if (_descriptionController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _mockGrievances.insert(0, {
          'id': 'GRV-${DateTime.now().millisecondsSinceEpoch % 10000}',
          'category': _selectedCategory,
          'description': _descriptionController.text.trim(),
          'status': 'SUBMITTED',
          'date': 'Just now',
          'remarks': 'Ticket submitted to procurement grievance officer.',
        });
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grievance ticket submitted successfully! Ticket ID generated.'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTamil ? 'குறைதீர் & உதவி மையம்' : 'Help & Grievance Redressal'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create Complaint Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.report_problem_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          isTamil ? 'புதிய புகார் பதிவு செய்க' : 'Raise a Grievance Ticket',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isTamil ? 'புகார் வகை' : 'Category of Complaint',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: _categoriesEn.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isTamil ? 'விவரம்' : 'Description of Issue',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: isTamil
                            ? 'உங்கள் புகாரை விரிவாக எழுதவும்...'
                            : 'Enter clear details about your issue...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitComplaint,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(isTamil ? 'புகார் சமர்ப்பி' : 'Submit Grievance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Track Tickets
            Text(
              isTamil ? 'எனது புகார்களின் நிலை' : 'Track Your Complaints',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockGrievances.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final g = _mockGrievances[index];
                Color statusColor = AppColors.info;
                if (g['status'] == 'RESOLVED') statusColor = AppColors.success;
                if (g['status'] == 'SUBMITTED') statusColor = AppColors.secondary;

                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              g['id'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                g['status'],
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          g['category'],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(g['description']),
                        const SizedBox(height: 8),
                        const Divider(),
                        Text(
                          '${isTamil ? "பதிலளிப்பு" : "Remarks"}: ${g['remarks']}',
                          style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
