import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/services/voice_assistant_service.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isListening = false;

  void _processVoiceQuery(ProcurementRepository repo, String inputQuery) {
    if (inputQuery.trim().isEmpty) return;

    final response = VoiceAssistantService.processLiveQueueVoiceQuery(
      query: inputQuery,
      queueState: repo.getQueueState(),
      activeToken: repo.activeToken,
      currentCenter: repo.currentCenter,
      isTamil: repo.isTamil,
    );

    setState(() {
      _isListening = false;
    });

    _showVoiceResponseDialog(context, repo, inputQuery, response);
  }

  void _showVoiceResponseDialog(
    BuildContext context,
    ProcurementRepository repo,
    String userQuery,
    VoiceQueryResponse response,
  ) {
    final isTamil = repo.isTamil;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over_rounded, color: AppColors.primaryDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTamil ? 'குரல் உதவி பதில்' : 'Live Tracking Voice Assistant',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '"$userQuery"',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTamil ? response.textTa : response.textEn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: Text(isTamil ? 'சரி' : 'Got it'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openVoiceQueryModal(BuildContext context, ProcurementRepository repo) {
    final isTamil = repo.isTamil;

    final sampleQueries = isTamil
        ? [
            'எனக்கு முன்னாடி எத்தனை விவசாயிகள் இருக்கிறார்கள்?',
            'என் காத்திருப்பு நேரம் எவ்வளவு?',
            'என் டோக்கன் எண் என்ன?',
            'எனது கொள்முதல் மையம் எங்கே உள்ளது?',
          ]
        : [
            'How many farmers are ahead of me?',
            'What is my estimated waiting time?',
            'What is my token number?',
            'Where is my procurement centre?',
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, color: AppColors.secondary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTamil ? 'குரல் மூலம் கேளுங்கள் (Live Queue Voice)' : 'Voice Assistance (Live Queue)',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isTamil ? 'தமிழ் மற்றும் ஆங்கிலம் ஆதரிக்கப்படுகிறது' : 'Supports Tamil & English queries',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mic Simulation Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() => _isListening = true);
                        final nav = Navigator.of(context);
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (!mounted) return;
                          setModalState(() => _isListening = false);
                          nav.pop();
                          _processVoiceQuery(
                            repo,
                            isTamil
                                ? 'எனக்கு முன்னாடி எத்தனை விவசாயிகள் இருக்கிறார்கள்?'
                                : 'How many farmers are ahead of me?',
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _isListening ? AppColors.error : AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? AppColors.error : AppColors.secondary).withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening
                        ? (isTamil ? 'கேட்கிறது... பேசவும்...' : 'Listening... Speak now...')
                        : (isTamil ? 'மைக் பொத்தானை அழுத்தவும் அல்லது கீழே தேர்ந்தெடுக்கவும்' : 'Tap mic to speak or select a quick question below'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  Text(
                    isTamil ? 'மாதிரி கேள்விகள்' : 'Sample Questions',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 10),

                  ...sampleQueries.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _processVoiceQuery(repo, q);
                        },
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          q,
                          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),
                  // Text input fallback
                  TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: isTamil ? 'அல்லது கேள்வியை தட்டச்சு செய்ய' : 'Or type your question...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: () {
                          final text = _queryController.text;
                          _queryController.clear();
                          Navigator.pop(context);
                          _processVoiceQuery(repo, text);
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        final queue = repo.getQueueState();
        final isUserServing = (queue.currentServingToken == queue.userToken);
        final isNext = (queue.farmersAhead == 1);
        final isAutoSimulating = repo.isAutoSimulatingQueue;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openVoiceQueryModal(context, repo),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.mic_rounded),
            label: Text(
              isTamil ? 'குரல் உதவி' : 'Voice Assistant',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Real-Time Queue Control Panel
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTamil ? 'நேரலை வரிசை இயக்கம்' : 'Real-Time Live Queue Sync Engine',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                repo.officerNextQueueToken();
                              },
                              icon: const Icon(
                                Icons.fast_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                isTamil
                                    ? 'அடுத்த டோக்கனை அழை'
                                    : 'Call Next Token',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                repo.toggleAutoQueueSimulation();
                              },
                              icon: Icon(
                                isAutoSimulating
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                size: 18,
                                color: isAutoSimulating
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                              label: Text(
                                isAutoSimulating
                                    ? (isTamil ? 'நிறுத்து' : 'Pause Auto')
                                    : (isTamil
                                          ? 'தானியங்கி இயக்கம்'
                                          : 'Auto Ticker'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isAutoSimulating
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isAutoSimulating
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Voice Assistant Quick Banner Inside Live Queue
                InkWell(
                  onTap: () => _openVoiceQueryModal(context, repo),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil ? 'குரல் மூலம் வரிசை நிலை அறிந்துகொள்ள' : 'Ask Voice Assistant about your queue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                isTamil ? 'மைக் பொத்தானை அழுத்தவும்...' : 'Tap here or mic button to ask questions...',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Urgent Call Alert Banner
                if (isUserServing) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil ? 'உடனடி அழைப்பு!' : 'YOUR TURN NOW!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppTranslations.text('your_turn_now', lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ] else if (isNext) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.warning, width: 1.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: AppColors.warning,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppTranslations.text('your_turn_approaching', lang),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Current Token Being Served Display Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 26,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppTranslations.text('serving_now', lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        queue.currentServingToken,
                        style: const TextStyle(
                          fontSize: 68,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${isTamil ? "கொள்முதல் கூடம்" : "Weighing Scale Bay"} #02',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Queue Metrics Card: Your Token, Farmers Ahead, Est Wait
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              label: isTamil ? 'உங்கள் டோக்கன்' : 'Your Token',
                              value: queue.userToken,
                              color: AppColors.primaryDark,
                              icon: Icons.confirmation_number_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _buildMetricTile(
                              label: AppTranslations.text('farmers_ahead', lang),
                              value: '${queue.farmersAhead}',
                              color: AppColors.secondary,
                              icon: Icons.people_alt_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _buildMetricTile(
                              label: isTamil ? 'காத்திருப்பு' : 'Est Wait',
                              value: '~${queue.estimatedWaitMinutes}m',
                              color: AppColors.info,
                              icon: Icons.timer_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTamil ? queue.queueStatusTa : queue.queueStatusEn,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${queue.totalServedToday} ${isTamil ? "முடித்தவை" : "completed"}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Live Yard Queue Sequence List
                Text(
                  isTamil
                      ? 'யார்டு வரிசைப் பட்டியல்'
                      : 'Live Yard Token Sequence',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: queue.queueSequence.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = queue.queueSequence[index];

                    Color bgColor;
                    BorderSide borderSide;
                    Widget trailingWidget;

                    if (item.isServing) {
                      bgColor = AppColors.primaryContainer.withValues(alpha: 0.6);
                      borderSide = const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      );
                      trailingWidget = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isTamil ? 'தற்போது' : 'SERVING NOW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else if (item.isUser) {
                      bgColor = AppColors.secondaryContainer.withValues(
                        alpha: 0.5,
                      );
                      borderSide = const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      );
                      trailingWidget = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isTamil ? 'நீங்கள்' : 'YOU',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else if (item.isPast) {
                      bgColor = AppColors.surfaceVariant.withValues(alpha: 0.5);
                      borderSide = BorderSide(color: Colors.grey.shade300);
                      trailingWidget = const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 22,
                      );
                    } else {
                      bgColor = Colors.white;
                      borderSide = const BorderSide(color: AppColors.divider);
                      trailingWidget = Text(
                        isTamil ? 'காத்திருப்பு' : 'Waiting',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTertiary,
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.fromBorderSide(borderSide),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: item.isServing
                                ? AppColors.primary
                                : (item.isUser
                                      ? AppColors.secondary
                                      : Colors.grey.shade200),
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: (item.isServing || item.isUser)
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.tokenNumber,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: item.isPast
                                        ? AppColors.textTertiary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${item.farmerName} • ${item.crop}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailingWidget,
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
