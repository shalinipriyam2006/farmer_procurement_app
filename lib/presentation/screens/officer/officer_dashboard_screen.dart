import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/models/procurement_stage.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  final TextEditingController _bagsCtrl = TextEditingController();
  final TextEditingController _moistureCtrl = TextEditingController();

  final List<Map<String, String>> _auditLogs = [
    {
      'action': 'CALL_NEXT_TOKEN',
      'details': 'Advanced current serving token to TK-101',
      'time': 'Just now',
    },
    {
      'action': 'QUALITY_CHECK',
      'details': 'Approved Grade A FAQ status (14.2% moisture)',
      'time': '10 mins ago',
    },
    {
      'action': 'WEIGHMENT',
      'details': 'Recorded 45 bags (29.7 Quintals)',
      'time': '25 mins ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    final repo = ProcurementRepository();
    _bagsCtrl.text = repo.payment.bagCount.toString();
    _moistureCtrl.text = repo.payment.moisturePercentage.toString();
  }

  @override
  void dispose() {
    _bagsCtrl.dispose();
    _moistureCtrl.dispose();
    super.dispose();
  }

  Future<void> _showClosureDialog(BuildContext context, ProcurementRepository repo) async {
    final reasonController = TextEditingController(text: 'Heavy rain & yard maintenance');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(repo.isTamil ? 'நிலையத்தை மூட முடிவு' : 'Close Procurement Centre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo.isTamil
                  ? 'விவசாயிகளுக்கான மூடல் காரணத்தை பதிவு செய்யவும்:'
                  : 'Enter closure reason to display to farmers:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: repo.isTamil ? 'காரணம்' : 'Closure Reason',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(repo.isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            child: Text(repo.isTamil ? 'உறுதி செய்க' : 'Confirm Closure'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await repo.officerSetCentreStatus('CLOSED', reason: result);
      _logAudit('CENTRE_STATUS', 'Closed centre: $result');
    }
  }

  void _logAudit(String action, String details) {
    setState(() {
      _auditLogs.insert(0, {
        'action': action,
        'details': details,
        'time': 'Just now',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        final activeToken = repo.activeToken;
        final currentStage = activeToken?.currentStage ?? ProcurementStageType.called;
        final currentStatus = repo.currentCenter.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2C3E50),
            foregroundColor: Colors.white,
            title: Text(AppTranslations.text('officer_dashboard', lang)),
            actions: [
              IconButton(
                tooltip: isTamil ? 'மொழி மாற்று' : 'Toggle Language',
                icon: const Icon(Icons.language),
                onPressed: () => repo.toggleLanguage(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Officer Profile & Centre Status Controls
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 26,
                            child: Icon(Icons.badge_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Procurement Officer: S. Ravi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Center: ${repo.currentCenter.nameEn}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTamil ? 'நிலைய நிலை: $currentStatus' : 'Centre Status: $currentStatus',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  repo.officerSetCentreStatus('OPEN');
                                  _logAudit('CENTRE_STATUS', 'Opened centre operations');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentStatus == 'OPEN' ? Colors.green : Colors.white24,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: Text(isTamil ? 'திறக்குக' : 'Open'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  repo.officerSetCentreStatus('PAUSED', reason: 'Operations Paused');
                                  _logAudit('CENTRE_STATUS', 'Paused centre queue');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentStatus == 'PAUSED' ? Colors.orange : Colors.white24,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: Text(isTamil ? 'நிறுத்து' : 'Pause'),
                              ),
                              ElevatedButton(
                                onPressed: () => _showClosureDialog(context, repo),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentStatus == 'CLOSED' ? Colors.red : Colors.white24,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: Text(isTamil ? 'மூடுக' : 'Close'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 1. Queue Control Box
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isTamil ? 'வரிசை நிர்வாகம்' : 'Queue Control & Management',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isTamil ? 'தற்போது இயங்கும் டோக்கன்' : 'Serving Token',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'TK-${repo.currentServingTokenNumber}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                repo.officerNextQueueToken();
                                _logAudit('CALL_NEXT_TOKEN', 'Called TK-${repo.currentServingTokenNumber}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Advanced queue to TK-${repo.currentServingTokenNumber}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fast_forward_rounded),
                              label: Text(isTamil ? 'அடுத்த டோக்கன்' : 'Call Next Token'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Lifecycle Stage Control
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alt_route_rounded, color: Color(0xFF0277BD), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTamil ? '8-நிலை நேரலை நிலை மாற்றம்' : 'Procurement Stage Controller',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  '${ProcurementStageType.values.indexOf(currentStage) + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isTamil ? 'தற்போதைய நிலை' : 'Current Active Stage',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      _stageName(currentStage, lang),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    ),
                                  ],
                                ),
                              ),
                              if (ProcurementStageType.values.indexOf(currentStage) < 7)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    repo.officerAdvanceToNextStage();
                                    final nextStage = ProcurementStageType.values[ProcurementStageType.values.indexOf(currentStage) + 1];
                                    _logAudit('UPDATE_STAGE', 'Advanced stage to ${_stageName(nextStage, lang)}');
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                  label: Text(isTamil ? 'அடுத்த நிலை' : 'Next Stage'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    minimumSize: Size.zero,
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

                // 3. Audit Trail Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_rounded, color: AppColors.primaryDark, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isTamil ? 'அலுவலர் தணிக்கை பதிவு (Audit Log)' : 'Officer Audit Log & Actions',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _auditLogs.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final log = _auditLogs[index];
                            return Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log['action']!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        log['details']!,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  log['time']!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                ),
                              ],
                            );
                          },
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

  String _stageName(ProcurementStageType stage, AppLanguage lang) {
    switch (stage) {
      case ProcurementStageType.tokenGenerated:
        return AppTranslations.text('stage_1', lang);
      case ProcurementStageType.waiting:
        return AppTranslations.text('stage_2', lang);
      case ProcurementStageType.called:
        return AppTranslations.text('stage_3', lang);
      case ProcurementStageType.weighing:
        return AppTranslations.text('stage_4', lang);
      case ProcurementStageType.qualityCheck:
        return AppTranslations.text('stage_5', lang);
      case ProcurementStageType.accepted:
        return AppTranslations.text('stage_6', lang);
      case ProcurementStageType.paymentProcessing:
        return AppTranslations.text('stage_7', lang);
      case ProcurementStageType.paymentCompleted:
        return AppTranslations.text('stage_8', lang);
    }
  }
}
