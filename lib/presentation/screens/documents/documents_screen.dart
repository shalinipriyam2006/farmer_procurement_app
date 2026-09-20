import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;
    final farmer = repo.currentFarmer;
    final token = repo.activeToken;
    final payment = repo.payment;

    final docs = [
      {
        'id': 'DOC-101',
        'titleEn': 'Digital Token Booking Receipt',
        'titleTa': 'டிஜிட்டல் டோக்கன் முன்பதிவு ரசீது',
        'type': 'TOKEN_PASS',
        'number': token?.tokenNumber ?? 'TK-104',
        'date': token?.bookingDate ?? 'Today',
        'icon': Icons.confirmation_number_rounded,
        'color': AppColors.primary,
      },
      {
        'id': 'DOC-102',
        'titleEn': 'Weighment & Quality Test Certificate',
        'titleTa': 'எடை மற்றும் தர பரிசோதனை சான்றிதழ்',
        'type': 'WEIGHMENT_CERTIFICATE',
        'number': '45 Bags / 30.0 Qtl (14.2% Moisture)',
        'date': 'Today 10:45 AM',
        'icon': Icons.scale_rounded,
        'color': AppColors.secondary,
      },
      {
        'id': 'DOC-103',
        'titleEn': 'Procurement Goods Acceptance Voucher',
        'titleTa': 'விளைபொருள் சரக்கு ரசீது',
        'type': 'GOODS_RECEIPT',
        'number': 'GR-TNCSC-90214',
        'date': 'Today 11:15 AM',
        'icon': Icons.inventory_2_rounded,
        'color': Colors.deepPurple,
      },
      {
        'id': 'DOC-104',
        'titleEn': 'Treasury DBT Payment Slip',
        'titleTa': 'அரசு கருவூல DBT செலுத்துகை ரசீது',
        'type': 'PAYMENT_SLIP',
        'number': payment.bankReferenceNumber,
        'date': 'Pending Credit',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF2E7D32),
      },
    ];

    final activeReceipt = repo.activeReceipt;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isTamil ? 'அதிகாரப்பூர்வ ஆவணங்கள் & ரசீதுகள்' : 'Official Documents & Digital Receipts'),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeReceipt != null) ...[
                Card(
                  elevation: 3,
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.green.shade600, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_rounded, color: Colors.green, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTamil ? 'டிஜிட்டல் கொள்முதல் ரசீது' : 'Digital Procurement Receipt',
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                  ),
                                  Text(
                                    'No: ${activeReceipt.receiptNumber}',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isTamil ? 'விவசாயி பெயா்:' : 'Farmer:', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            Text(activeReceipt.farmerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isTamil ? 'அளக்கப்பட்ட எடை:' : 'Measured Weight:', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            Text('${activeReceipt.weightQuintals} Qtl (${activeReceipt.bagCount} bags)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isTamil ? 'தர நிலை / ஈரப்பதம்:' : 'Grade / Moisture:', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            Text('${activeReceipt.qualityGrade} (${activeReceipt.moisturePercentage}%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isTamil ? 'நிகர செலுத்துகை தொகை:' : 'Net Payable Amount:', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            Text('₹${activeReceipt.netAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Digital Procurement Receipt ${activeReceipt.receiptNumber} generated successfully.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: Text(isTamil ? 'டிஜிட்டல் ரசீது பதிவிறக்கம்' : 'Download Digital Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...docs.map((doc) {
                final color = doc['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(doc['icon'] as IconData, color: color, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isTamil ? doc['titleTa'] as String : doc['titleEn'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${doc['number']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Issued: ${doc['date']} • ${farmer.name}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Viewing document ${doc['id']}...'),
                                      backgroundColor: AppColors.primaryDark,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                                label: Text(isTamil ? 'பார்க்க' : 'View Pass'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Downloading official PDF receipt for ${doc['id']}...'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: Text(isTamil ? 'பதிவிறக்கம்' : 'Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
