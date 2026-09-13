import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/centers/centers_list_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/documents/documents_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/grievance/grievance_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/payment/payment_details_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/recovery/missed_slot_screen.dart';
import 'package:farmer_procurement_app/presentation/widgets/accessible_action_card.dart';

class FarmerHomeScreen extends StatelessWidget {
  final Function(int) onTabSelect;

  const FarmerHomeScreen({super.key, required this.onTabSelect});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        final farmer = repo.currentFarmer;
        final center = repo.currentCenter;
        final token = repo.activeToken;
        final queue = repo.getQueueState();

        final centerName = isTamil ? center.nameTa : center.nameEn;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting & Farmer Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryDark,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppTranslations.text('welcome_farmer', lang)} ${farmer.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'ID: ${farmer.farmerIdNumber} • ${farmer.village}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Selected Centre & Schedule Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppTranslations.text('selected_centre', lang),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CentersListScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isTamil ? 'மாற்று' : 'Change',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        centerName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppTranslations.text('working_hours', lang)}: ${center.workingHours}',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Active Token & Live Queue Dashboard Hero Card
              if (token != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.secondary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.confirmation_number_rounded,
                                  color: AppColors.secondary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslations.text('active_token', lang),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    token.tokenNumber,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => onTabSelect(1), // Go to Token Tab
                            icon: const Icon(Icons.qr_code_rounded, size: 16),
                            label: Text(
                              isTamil ? 'பார்க்க' : 'View Pass',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 12),

                      // Metrics: Farmers Ahead & Est Waiting Time
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.people_alt_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          AppTranslations.text(
                                            'farmers_ahead',
                                            lang,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${queue.farmersAhead} ${isTamil ? "நபர்கள்" : "farmers"}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_rounded,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          AppTranslations.text(
                                            'est_waiting_time',
                                            lang,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '~${queue.estimatedWaitMinutes} ${isTamil ? "நிமிடம்" : "mins"}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Current Serving Token & Status banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${AppTranslations.text('serving_now', lang)}: ${queue.currentServingToken}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => onTabSelect(2), // Queue tab
                              child: Row(
                                children: [
                                  Text(
                                    isTamil ? 'நேரலை வரிசை' : 'Live Queue',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // No token booked banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 52,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppTranslations.text('no_active_token', lang),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => onTabSelect(1), // Go to Token booking
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          AppTranslations.text('book_token_now', lang),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick Actions Header
              Text(
                AppTranslations.text('quick_actions', lang),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Action Cards
              AccessibleActionCard(
                title: isTamil
                    ? 'டிஜிட்டல் டோக்கன் பதிவு'
                    : 'Book Digital Token',
                subtitle: isTamil
                    ? 'தேதி மற்றும் நேரத்தை தேர்வு செய்க'
                    : 'Select date, slot & crop bags',
                icon: Icons.confirmation_number_rounded,
                iconColor: AppColors.primary,
                onTap: () => onTabSelect(1),
              ),

              AccessibleActionCard(
                title: isTamil ? 'நேரலை வரிசை நிலை' : 'Live Yard Queue',
                subtitle:
                    '${queue.farmersAhead} ${isTamil ? "விவசாயிகள் முன்னால்" : "farmers ahead"} (~${queue.estimatedWaitMinutes} mins)',
                icon: Icons.groups_rounded,
                iconColor: AppColors.secondary,
                badgeText: queue.currentServingToken,
                onTap: () => onTabSelect(2),
              ),

              AccessibleActionCard(
                title: isTamil
                    ? '8-நிலை கொள்முதல் காலவரிசை'
                    : 'Procurement Timeline',
                subtitle: isTamil
                    ? 'எடை மற்றும் தர பரிசோதனை நிலை'
                    : 'Check weighment, quality & approval',
                icon: Icons.timeline_rounded,
                iconColor: const Color(0xFF0277BD),
                onTap: () => onTabSelect(3),
              ),

              AccessibleActionCard(
                title: AppTranslations.text('view_payment', lang),
                subtitle: isTamil
                    ? '₹69,150 அரசு கொள்முதல் வரவு ரசீது'
                    : '₹69,150 MSP payout slip & bank ref',
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentDetailsScreen(),
                    ),
                  );
                },
              ),

              AccessibleActionCard(
                title: AppTranslations.text('view_centres', lang),
                subtitle: isTamil
                    ? 'அருகிலுள்ள கொள்முதல் நிலையங்கள்'
                    : 'Operating hours & daily intake',
                icon: Icons.storefront_rounded,
                iconColor: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CentersListScreen(),
                    ),
                  );
                },
              ),

              AccessibleActionCard(
                title: isTamil ? 'அதிகாரப்பூர்வ ஆவணங்கள் & ரசீதுகள்' : 'Official Documents & Receipts',
                subtitle: isTamil ? 'டோக்கன், எடை மற்றும் வங்கி ரசீதுகள்' : 'Download token pass, weighment & DBT receipts',
                icon: Icons.folder_shared_rounded,
                iconColor: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DocumentsScreen(),
                    ),
                  );
                },
              ),

              AccessibleActionCard(
                title: isTamil ? 'குறைதீர் & உதவி மையம்' : 'Help & Grievances',
                subtitle: isTamil ? 'புகார் பதிவு மற்றும் நிலை கண்காணிப்பு' : 'Raise complaint ticket & track resolution',
                icon: Icons.support_agent_rounded,
                iconColor: Colors.orange.shade800,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GrievanceScreen(),
                    ),
                  );
                },
              ),

              AccessibleActionCard(
                title: isTamil ? 'தவறிய நேரம் சரிசெய்தல்' : 'Missed Slot Recovery',
                subtitle: isTamil ? 'தவறிய டோக்கன் நேரத்தை மீட்டெடுக்க' : 'Recover or re-book expired procurement slot',
                icon: Icons.restore_page_rounded,
                iconColor: AppColors.error,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MissedSlotScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Help & Support footer
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GrievanceScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppTranslations.text('help_support', lang),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
