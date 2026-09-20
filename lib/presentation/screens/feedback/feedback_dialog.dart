import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class FarmerFeedbackDialog extends StatefulWidget {
  const FarmerFeedbackDialog({super.key});

  @override
  State<FarmerFeedbackDialog> createState() => _FarmerFeedbackDialogState();
}

class _FarmerFeedbackDialogState extends State<FarmerFeedbackDialog> {
  int _selectedRating = 5;
  String _selectedCategory = 'OVERALL_SERVICE';
  final TextEditingController _remarksController = TextEditingController();
  bool _isSubmitting = false;

  final Map<String, String> _categoriesEn = {
    'OVERALL_SERVICE': 'Overall Procurement Experience',
    'WEIGHMENT_ACCURACY': 'Scale & Weighment Accuracy',
    'QUALITY_CHECK': 'Quality Testing Transparency',
    'STAFF_BEHAVIOR': 'Officer & Staff Assistance',
    'PAYMENT_SPEED': 'DBT Payment Processing Speed',
  };

  final Map<String, String> _categoriesTa = {
    'OVERALL_SERVICE': 'ஒட்டுமொத்த சேவை திருப்தி',
    'WEIGHMENT_ACCURACY': 'எடை போடும் துல்லியம்',
    'QUALITY_CHECK': 'தர பரிசோதனை வெளிப்படைத்தன்மை',
    'STAFF_BEHAVIOR': 'அதிகாரிகள் மற்றும் ஊழியர்களின் அணுகுமுறை',
    'PAYMENT_SPEED': 'பணப் பரிமாற்ற வேகம்',
  };

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback(ProcurementRepository repo) async {
    setState(() => _isSubmitting = true);
    final success = await repo.submitFeedback(
      rating: _selectedRating,
      category: _selectedCategory,
      remarks: _remarksController.text.trim(),
    );
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context, success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (repo.isTamil ? 'உங்கள் கருத்து வெற்றிகரமாக பதிவு செய்யப்பட்டது! நன்றி.' : 'Thank you! Your feedback has been submitted successfully.')
                : (repo.isTamil ? 'கருத்து பதிவு செய்ய முடியவில்லை.' : 'Failed to submit feedback.'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.rate_review_rounded, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isTamil ? 'விவசாயி கருத்து & மதிப்பீடு' : 'Farmer Feedback & Rating',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTamil
                  ? 'கொள்முதல் சேவை பற்றிய உங்கள் அனுபவத்தை மதிப்பீடு செய்யவும்:'
                  : 'Rate your procurement experience at the centre:',
              style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 14),

            // 5 Star Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  iconSize: 32,
                  icon: Icon(
                    starNum <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: starNum <= _selectedRating ? Colors.amber : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    setState(() => _selectedRating = starNum);
                  },
                );
              }),
            ),
            const SizedBox(height: 12),

            // Category Selector Dropdown
            Text(
              isTamil ? 'பிரிவு / கருத்து வகை:' : 'Category:',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categoriesEn.keys.map((catKey) {
                return DropdownMenuItem(
                  value: catKey,
                  child: Text(
                    isTamil ? _categoriesTa[catKey]! : _categoriesEn[catKey]!,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 14),

            // Remarks Text Box
            Text(
              isTamil ? 'கூடுதல் கருத்துக்கள் (விருப்பத்தேர்வு):' : 'Additional Remarks (Optional):',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isTamil ? 'உங்கள் கருத்துகளை இங்கே தட்டச்சு செய்க...' : 'Type your experience or suggestion here...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(isTamil ? 'ரத்து' : 'Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSubmitting ? null : () => _submitFeedback(repo),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isTamil ? 'சமர்ப்பி' : 'Submit Feedback'),
        ),
      ],
    );
  }
}
