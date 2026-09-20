import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';

class DigitalDocument {
  final String id;
  final String docRefNumber;
  final String titleEn;
  final String titleTa;
  final String type; // TOKEN_PASS, PROCUREMENT_RECEIPT, WEIGHMENT_SLIP, QUALITY_CERTIFICATE, ACCEPTANCE_CERTIFICATE, REJECTION_CERTIFICATE, COMPLETION_CERTIFICATE, PAYMENT_VOUCHER, COMBINED_STATEMENT
  final String category; // Application Digital Record
  final String date;
  final String status;
  final String? tokenId;
  final String summary;
  final String downloadUrl;

  DigitalDocument({
    required this.id,
    required this.docRefNumber,
    required this.titleEn,
    required this.titleTa,
    required this.type,
    required this.category,
    required this.date,
    required this.status,
    this.tokenId,
    required this.summary,
    required this.downloadUrl,
  });

  factory DigitalDocument.fromJson(Map<String, dynamic> json) {
    return DigitalDocument(
      id: json['id'] as String? ?? '',
      docRefNumber: json['docRefNumber'] as String? ?? 'BUYWISE-DOC-001',
      titleEn: json['titleEn'] as String? ?? 'Digital Procurement Document',
      titleTa: json['titleTa'] as String? ?? 'டிஜிட்டல் கொள்முதல் ஆவணம்',
      type: json['type'] as String? ?? 'PROCUREMENT_RECEIPT',
      category: json['category'] as String? ?? 'Application Digital Record',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'ISSUED',
      tokenId: json['tokenId'] as String?,
      summary: json['summary'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }

  String get fileName {
    final cleanRef = docRefNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    String prefix = 'BUYWISE_Document';
    final upperType = type.toUpperCase();
    if (upperType.contains('TOKEN')) {
      prefix = 'BUYWISE_Token';
    } else if (upperType.contains('RECEIPT') || upperType.contains('WEIGH')) {
      prefix = 'BUYWISE_Receipt';
    } else if (upperType.contains('QUALITY') || upperType.contains('ACCEPT') || upperType.contains('REJECT')) {
      prefix = 'BUYWISE_Quality';
    } else if (upperType.contains('PAYMENT') || upperType.contains('COMPLETION')) {
      prefix = 'BUYWISE_Payment';
    }
    return '${prefix}_$cleanRef.pdf';
  }

  IconData get icon {
    switch (type) {
      case 'TOKEN_PASS':
        return Icons.confirmation_number_rounded;
      case 'PROCUREMENT_RECEIPT':
        return Icons.receipt_long_rounded;
      case 'WEIGHMENT_SLIP':
        return Icons.scale_rounded;
      case 'QUALITY_CERTIFICATE':
        return Icons.verified_rounded;
      case 'ACCEPTANCE_CERTIFICATE':
        return Icons.task_alt_rounded;
      case 'REJECTION_CERTIFICATE':
        return Icons.cancel_rounded;
      case 'COMPLETION_CERTIFICATE':
        return Icons.workspace_premium_rounded;
      case 'PAYMENT_VOUCHER':
        return Icons.account_balance_rounded;
      case 'COMBINED_STATEMENT':
        return Icons.assignment_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'TOKEN_PASS':
        return AppColors.primary;
      case 'PROCUREMENT_RECEIPT':
        return AppColors.secondary;
      case 'WEIGHMENT_SLIP':
        return Colors.teal;
      case 'QUALITY_CERTIFICATE':
        return Colors.amber.shade800;
      case 'ACCEPTANCE_CERTIFICATE':
        return Colors.green.shade700;
      case 'REJECTION_CERTIFICATE':
        return Colors.red.shade700;
      case 'COMPLETION_CERTIFICATE':
        return Colors.indigo;
      case 'PAYMENT_VOUCHER':
        return const Color(0xFF2E7D32);
      case 'COMBINED_STATEMENT':
        return Colors.deepPurple;
      default:
        return AppColors.primaryDark;
    }
  }
}
