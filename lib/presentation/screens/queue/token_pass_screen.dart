import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/models/token_model.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class TokenPassScreen extends StatelessWidget {
  final TokenModel? token;

  const TokenPassScreen({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;
    final activeToken = token ?? repo.activeToken;
    final farmer = repo.currentFarmer;

    final tokenNo = activeToken?.tokenNumber ?? 'TK-104';
    final centreName = activeToken != null
        ? (isTamil ? activeToken.centreNameTa : activeToken.centreNameEn)
        : repo.currentCenter.nameEn;
    final bookingDate = activeToken?.bookingDate ?? 'Today';
    final timeSlot = activeToken?.timeSlot ?? '09:00 AM - 11:00 AM';
    final cropName = activeToken != null
        ? (isTamil ? activeToken.cropNameTa : activeToken.cropNameEn)
        : 'Paddy (Grade A)';
    final quintals = activeToken?.estimatedQuintals ?? 30.0;
    final bags = activeToken?.estimatedBags ?? 45;
    final verifyCode = 'VERIFY-TK-${tokenNo.replaceAll('TK-', '')}-2026';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(isTamil ? 'அதிகாரப்பூர்வ டோக்கன் கடவுச்சீட்டு (E-Pass)' : 'Official E-Pass / Token Pass'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                isTamil ? 'TNCSC கொள்முதல் டோக்கன்' : 'TNCSC Procurement E-Pass',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Token Number Display
                    Text(
                      tokenNo,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      isTamil ? 'வரிசை எண் / டோக்கன் கடவுச்சீட்டு' : 'Queue Serial & Entry Pass',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Details Grid
                    _buildDetailRow(isTamil ? 'விவசாயி பெயர்:' : 'Farmer Name:', farmer.name),
                    _buildDetailRow(isTamil ? 'விவசாயி அடையாள எண்:' : 'Farmer Reg ID:', farmer.farmerIdNumber),
                    _buildDetailRow(isTamil ? 'கொள்முதல் மையம்:' : 'Procurement Centre:', centreName),
                    _buildDetailRow(isTamil ? 'முன்பதிவு தேதி:' : 'Slot Date:', bookingDate),
                    _buildDetailRow(isTamil ? 'நேரம்:' : 'Time Slot:', timeSlot),
                    _buildDetailRow(isTamil ? 'பயிர் விவரம்:' : 'Crop Category:', cropName),
                    _buildDetailRow(isTamil ? 'மதிப்பிடப்பட்ட அளவு:' : 'Quantity:', '$quintals Qtl ($bags bags)'),
                    _buildDetailRow(isTamil ? 'சரிபார்ப்பு குறியீடு:' : 'Security Ref:', verifyCode),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // QR Code Simulation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.blueGrey.shade800),
                          const SizedBox(height: 6),
                          Text(
                            verifyCode,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTamil ? 'மைய வாயிலில் இந்த QR குறியீட்டை காண்பிக்கவும்' : 'Scan this QR code at centre entrance gate',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTamil
                                  ? 'குறிப்பு: இது ஒரு செயலி டிஜிட்டல் ஆவணமாகும் (Application Digital Record).'
                                  : 'Notice: Official Application Digital Record issued for direct procurement.',
                              style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isTamil
                                ? 'ஆவணம் வெற்றிகரமாக பதிவிறக்கப்பட்டது.'
                                : 'Document downloaded successfully.',
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: isTamil ? 'திற' : 'Open',
                            textColor: Colors.white,
                            onPressed: () {
                              _showPassDetailSheet(context, tokenNo, verifyCode, isTamil);
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: Text(isTamil ? 'பதிவிறக்கம்' : 'Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSharePassSheet(context, tokenNo, verifyCode, isTamil);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: Text(isTamil ? 'பகிர்' : 'Share Pass'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPassDetailSheet(BuildContext context, String tokenNo, String verifyCode, bool isTamil) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.primaryDark, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTamil ? 'டிஜிட்டல் டோக்கன் கடவுச்சீட்டு விவரங்கள்' : 'Digital Token Pass Details',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isTamil ? 'டோக்கன் எண்:' : 'Token Number:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(tokenNo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(isTamil ? 'சரிபார்ப்பு குறிப்பு:' : 'Security Ref:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(verifyCode, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade300)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTamil ? 'அதிகாரப்பூர்வ செயலி டிஜிட்டல் சான்றிதழ் (Application Digital Record)' : 'Official Application Digital Record',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(isTamil ? 'மூடு' : 'Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSharePassSheet(BuildContext context, String tokenNo, String verifyCode, bool isTamil) {
    final shareUrl = 'https://farmer-procurement-app-i0g6.onrender.com/api/v1/documents/detail/$tokenNo';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share_rounded, color: AppColors.primaryDark),
                const SizedBox(width: 10),
                Text(
                  isTamil ? 'டோக்கன் கடவுச்சீட்டைப் பகிரவும்' : 'Share E-Pass Record',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isTamil ? 'டோக்கன்: $tokenNo | குறிப்பு: $verifyCode' : 'Token: $tokenNo | Ref: $verifyCode',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(shareUrl, style: const TextStyle(fontSize: 12, color: Colors.blue, overflow: TextOverflow.ellipsis)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isTamil ? 'இணைப்பு நகலெடுக்கப்பட்டது' : 'Pass verification link copied to clipboard'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isTamil ? 'வாட்ஸ்அப் / செய்தி மூலம் பகிரப்பட்டது' : 'Token pass shared successfully'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: Text(isTamil ? 'வாட்ஸ்அப் / பிற பயன்பாடுகளில் பகிரவும்' : 'Share via WhatsApp / Messaging'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
