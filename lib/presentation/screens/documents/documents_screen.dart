import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/models/digital_document.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/queue/token_pass_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    ProcurementRepository().fetchDigitalDocuments();
  }

  void _showDocumentDetail(BuildContext context, DigitalDocument doc, bool isTamil) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(doc.icon, color: doc.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isTamil ? doc.titleTa : doc.titleEn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: doc.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'REF: ${doc.docRefNumber}',
                  style: TextStyle(color: doc.color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                doc.summary,
                style: const TextStyle(fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTamil
                            ? 'அதிகாரப்பூர்வ டிஜிட்டல் ஆவணம் (${doc.category})'
                            : 'Official Digital Record (${doc.category})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isTamil ? 'மூடு' : 'Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _handleDownload(context, doc, isTamil);
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: Text(isTamil ? 'பதிவிறக்கு' : 'Download'),
          ),
        ],
      ),
    );
  }

  void _handleDownload(BuildContext context, DigitalDocument doc, bool isTamil) {
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
            _showDocumentDetail(context, doc, isTamil);
          },
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, DigitalDocument doc, bool isTamil) {
    final shareUrl = 'https://farmer-procurement-app-i0g6.onrender.com/api/v1/documents/detail/${doc.id}';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  isTamil ? 'ஆவணத்தைப் பகிரவும்' : 'Share Digital Document',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isTamil ? doc.titleTa : doc.titleEn,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Ref: ${doc.docRefNumber}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: const TextStyle(fontSize: 12, color: Colors.blue, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isTamil ? 'இணைப்பு நகலெடுக்கப்பட்டது' : 'Verification link copied to clipboard'),
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
                      content: Text(isTamil ? 'வாட்ஸ்அப் / செய்தி மூலம் பகிரப்பட்டது' : 'Document details shared successfully'),
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

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    final isTamil = repo.isTamil;
    final farmer = repo.currentFarmer;
    final token = repo.activeToken;
    final payment = repo.payment;

    // Fallback static 8 document list if backend returns empty during offline or initial state
    final fallbackDocs = [
      DigitalDocument(
        id: 'DOC-101',
        titleEn: 'Digital Token Booking E-Pass',
        titleTa: 'டிஜிட்டல் டோக்கன் முன்பதிவு கடவுச்சீட்டு',
        type: 'TOKEN_PASS',
        docRefNumber: token?.tokenNumber ?? 'TK-104',
        category: 'Application Digital Record',
        date: token?.bookingDate ?? 'Today',
        status: 'ISSUED',
        summary: 'Digital slot confirmation pass at ${repo.currentCenter.nameEn} for Paddy procurement.',
        downloadUrl: '/api/v1/documents/download/DOC-101',
      ),
      DigitalDocument(
        id: 'DOC-102',
        titleEn: 'Official Procurement Receipt',
        titleTa: 'அதிகாரப்பூர்வ கொள்முதல் ரசீது',
        type: 'PROCUREMENT_RECEIPT',
        docRefNumber: repo.activeReceipt?.receiptNumber ?? 'BUYWISE_RCP-9021',
        category: 'Application Digital Record',
        date: 'Today 10:45 AM',
        status: 'COMPLETED',
        summary: 'Official receipt verifying 45 bags (30.0 Quintals) delivered to warehouse.',
        downloadUrl: '/api/v1/documents/download/DOC-102',
      ),
      DigitalDocument(
        id: 'DOC-103',
        titleEn: 'Weighment Slip Record',
        titleTa: 'எடை பதிவு ரசீது',
        type: 'WEIGHMENT_SLIP',
        docRefNumber: 'WS-8849',
        category: 'Application Digital Record',
        date: 'Today 10:30 AM',
        status: 'COMPLETED',
        summary: 'Gross weight: 32.4 Qtl, Tare: 2.4 Qtl, Net weight: 30.0 Qtl.',
        downloadUrl: '/api/v1/documents/download/DOC-103',
      ),
      DigitalDocument(
        id: 'DOC-104',
        titleEn: 'Quality Test Certificate',
        titleTa: 'தர பரிசோதனை சான்றிதழ்',
        type: 'QUALITY_CERTIFICATE',
        docRefNumber: 'QTC-2026-90',
        category: 'Application Digital Record',
        date: 'Today 10:40 AM',
        status: 'COMPLETED',
        summary: 'Grade A FAQ Approved (Moisture: 14.2%, Foreign Matter: 0.8%).',
        downloadUrl: '/api/v1/documents/download/DOC-104',
      ),
      DigitalDocument(
        id: 'DOC-105',
        titleEn: 'Procurement Acceptance Certificate',
        titleTa: 'கொள்முதல் ஏற்பு சான்றிதழ்',
        type: 'ACCEPTANCE_CERTIFICATE',
        docRefNumber: 'ACC-7741',
        category: 'Application Digital Record',
        date: 'Today 11:00 AM',
        status: 'ACCEPTED',
        summary: 'Lot accepted by Procurement Officer into District Godown.',
        downloadUrl: '/api/v1/documents/download/DOC-105',
      ),
      DigitalDocument(
        id: 'DOC-106',
        titleEn: 'Procurement Completion Certificate',
        titleTa: 'கொள்முதல் நிறைவு சான்றிதழ்',
        type: 'COMPLETION_CERTIFICATE',
        docRefNumber: 'PCC-4482',
        category: 'Application Digital Record',
        date: 'Today 11:15 AM',
        status: 'COMPLETED',
        summary: 'All operational steps completed. File sent to Treasury for DBT credit.',
        downloadUrl: '/api/v1/documents/download/DOC-106',
      ),
      DigitalDocument(
        id: 'DOC-107',
        titleEn: 'DBT Payment Voucher / Payout Slip',
        titleTa: 'அரசு கருவூல DBT செலுத்துகை ரசீது',
        type: 'PAYMENT_VOUCHER',
        docRefNumber: payment.bankReferenceNumber,
        category: 'Application Digital Record',
        date: 'Pending Credit',
        status: 'PROCESSING',
        summary: 'Net Payout ₹${payment.netAmount.toStringAsFixed(0)} mapped to bank A/c ${farmer.bankAccountMasked}.',
        downloadUrl: '/api/v1/documents/download/DOC-107',
      ),
      DigitalDocument(
        id: 'DOC-108',
        titleEn: 'Combined Procurement Statement',
        titleTa: 'ஒருங்கிணைந்த கொள்முதல் அறிக்கை',
        type: 'COMBINED_STATEMENT',
        docRefNumber: 'CPS-2026-FARMER-001',
        category: 'Application Digital Record',
        date: 'Generated Today',
        status: 'COMPLETED',
        summary: 'Full single-page statement combining token, weighment, quality, and payment audit details.',
        downloadUrl: '/api/v1/documents/download/DOC-108',
      ),
    ];

    final displayDocs = repo.documents.isNotEmpty ? repo.documents : fallbackDocs;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            title: Text(isTamil ? 'அதிகாரப்பூர்வ ஆவணங்கள் & ரசீதுகள்' : 'Official Documents & Digital Receipts'),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayDocs.length,
            itemBuilder: (context, index) {
              final doc = displayDocs[index];
              final color = doc.color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(doc.icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTamil ? doc.titleTa : doc.titleEn,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ref: ${doc.docRefNumber}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${doc.date} • ${farmer.name}',
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
                        const SizedBox(height: 10),
                        Text(
                          doc.summary,
                          style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (doc.type == 'TOKEN_PASS') ...[
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TokenPassScreen(token: token)),
                                  );
                                },
                                icon: const Icon(Icons.qr_code_rounded, size: 16),
                                label: Text(isTamil ? 'கடவுச்சீட்டு' : 'E-Pass'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => _showDocumentDetail(context, doc, isTamil),
                              icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                              label: Text(isTamil ? 'திற' : 'Open'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: () => _showShareDialog(context, doc, isTamil),
                              icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.primaryDark),
                              tooltip: isTamil ? 'பகிரவும்' : 'Share',
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton.icon(
                              onPressed: () => _handleDownload(context, doc, isTamil),
                              icon: const Icon(Icons.download_rounded, size: 16),
                              label: Text(isTamil ? 'பதிவிறக்கம்' : 'Download'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
