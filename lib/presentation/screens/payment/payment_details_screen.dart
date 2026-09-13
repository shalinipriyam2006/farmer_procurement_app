import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/models/payment_model.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        final payment = repo.payment;
        final isPaid = payment.status == PaymentStatus.completed;

        final statusColor = isPaid ? AppColors.success : AppColors.secondary;
        final statusText = isPaid
            ? AppTranslations.text('status_paid', lang)
            : AppTranslations.text('status_pending', lang);

        return Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.text('payment_summary', lang)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Net Payout Highlight Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: statusColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              color: statusColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppTranslations.text('net_amount', lang),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${payment.netAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Token ${payment.tokenNumber} • ${isTamil ? payment.cropNameTa : payment.cropNameEn}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // MSP & Weighment Breakdown Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calculate_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isTamil
                                  ? 'விளைபொருள் மற்றும் விலை கணக்கீடு'
                                  : 'Procurement & MSP Breakdown',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildRow(
                          AppTranslations.text('procured_quantity', lang),
                          '${payment.bagCount} bags (${payment.quantityQuintals} Qtl)',
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          isTamil ? 'அங்கீகரிக்கப்பட்ட தரம்' : 'Quality Grade',
                          payment.qualityGrade,
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          isTamil ? 'ஈரப்பத அளவு' : 'Moisture %',
                          '${payment.moisturePercentage}% (Govt Limit: 17%)',
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          AppTranslations.text('msp_rate', lang),
                          '₹${payment.mspRatePerQuintal.toStringAsFixed(0)} / Qtl',
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          AppTranslations.text('total_amount', lang),
                          '₹${payment.grossAmount.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          AppTranslations.text('deductions', lang),
                          '- ₹${payment.deductions.toStringAsFixed(2)}',
                          textColor: AppColors.error,
                        ),
                        const Divider(height: 26, thickness: 1.5),
                        _buildRow(
                          AppTranslations.text('net_amount', lang),
                          '₹${payment.netAmount.toStringAsFixed(2)}',
                          isBold: true,
                          valueSize: 20,
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bank & Reference Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isTamil
                                  ? 'வங்கி பரிவர்த்தனை விவரம்'
                                  : 'Bank Disbursement Details',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildRow(
                          AppTranslations.text('bank_account', lang),
                          payment.maskedBankAccount,
                          icon: Icons.credit_card_rounded,
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          'IFSC Code',
                          payment.ifscCode,
                          icon: Icons.pin_drop_rounded,
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          AppTranslations.text('bank_ref', lang),
                          payment.bankReferenceNumber,
                          icon: Icons.tag_rounded,
                        ),
                        const Divider(height: 22),
                        _buildRow(
                          AppTranslations.text('payment_date', lang),
                          payment.paymentDate != null
                              ? '${payment.paymentDate!.day}-${payment.paymentDate!.month}-${payment.paymentDate!.year}'
                              : (isTamil
                                    ? 'செயலாக்கத்தில்...'
                                    : 'Under Process...'),
                          icon: Icons.calendar_today_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    double valueSize = 14.5,
    Color? textColor,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
