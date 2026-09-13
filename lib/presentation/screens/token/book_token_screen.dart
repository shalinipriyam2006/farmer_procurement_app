import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/widgets/token_ticket_card.dart';

class BookTokenScreen extends StatefulWidget {
  const BookTokenScreen({super.key});

  @override
  State<BookTokenScreen> createState() => _BookTokenScreenState();
}

class _BookTokenScreenState extends State<BookTokenScreen> {
  late String _selectedCenterId;
  late String _selectedDate;
  late String _selectedSlot;
  late String _selectedCrop;
  final TextEditingController _bagsController = TextEditingController(
    text: '45',
  );
  final TextEditingController _quintalsController = TextEditingController(
    text: '30.0',
  );

  final List<String> _dates = [
    'Today (இன்று)',
    'Tomorrow (நாளை)',
    '15-Sep-2026',
    '16-Sep-2026',
  ];

  final List<String> _slots = [
    '08:30 AM - 10:00 AM',
    '10:30 AM - 12:00 PM',
    '01:00 PM - 02:30 PM',
    '03:00 PM - 04:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    final repo = ProcurementRepository();
    _selectedCenterId = repo.selectedCenterId;
    _selectedDate = _dates[0];
    _selectedSlot = _slots[1];
    _selectedCrop = 'Paddy (Grade A)';
  }

  @override
  void dispose() {
    _bagsController.dispose();
    _quintalsController.dispose();
    super.dispose();
  }

  void _onBagsChanged(String val) {
    final bags = int.tryParse(val) ?? 0;
    // Standard 65kg / bag ~ 0.65 quintals
    final qtl = (bags * 0.666).toStringAsFixed(1);
    _quintalsController.text = qtl;
  }

  void _generateToken() {
    final repo = ProcurementRepository();
    final bags = int.tryParse(_bagsController.text.trim()) ?? 0;
    final quintals = double.tryParse(_quintalsController.text.trim()) ?? 0.0;

    if (bags <= 0 || quintals <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            repo.isTamil
                ? 'சரியான மூட்டைகள் எண்ணிக்கையை உள்ளிடவும்'
                : 'Please enter a valid bag count and quantity',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    repo.bookNewToken(
      centreId: _selectedCenterId,
      dateStr: _selectedDate,
      timeSlot: _selectedSlot,
      cropNameEn: _selectedCrop,
      cropNameTa: _selectedCrop == 'Paddy (Grade A)'
          ? 'நெல் (கிரேடு ஏ)'
          : (_selectedCrop == 'Paddy (Common)'
                ? 'நெல் (சாதாரண)'
                : 'மக்காச்சோளம்'),
      quintals: quintals,
      bags: bags,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          repo.isTamil
              ? 'டோக்கன் வெற்றிகரமாக உருவாக்கப்பட்டது!'
              : 'Token generated successfully!',
        ),
        backgroundColor: AppColors.success,
      ),
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
        final activeToken = repo.activeToken;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // If there's an active token, show the ticket pass
              if (activeToken != null) ...[
                Text(
                  AppTranslations.text('active_token', lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TokenTicketCard(token: activeToken, language: lang),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    isTamil
                        ? 'வேறு தேதி/நேரத்திற்கு புதிய டோக்கன் பதிவு செய்ய கீழே நிரப்பவும்'
                        : 'Book a new token slot below',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Generation Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppTranslations.text('book_digital_token', lang),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTamil
                          ? 'வரிசையில் காத்திருப்பதை தவிர்க்க முன்கூட்டியே டோக்கன் பெறவும்'
                          : 'Avoid waiting in queues by pre-booking your arrival slot',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Step 1: Centre Selection
                    Text(
                      AppTranslations.text('step_centre', lang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCenterId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      items: repo.centers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            isTamil ? c.nameTa : c.nameEn,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCenterId = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    // Step 2: Date Selection
                    Text(
                      AppTranslations.text('step_date', lang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dates.map((d) {
                        final isSelected = _selectedDate == d;
                        return ChoiceChip(
                          label: Text(d),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDate = d);
                          },
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Step 3: Time Slot Selection
                    Text(
                      AppTranslations.text('step_slot', lang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _slots.map((s) {
                        final isSelected = _selectedSlot == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSlot = s);
                          },
                          selectedColor: AppColors.secondaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Step 4: Crop & Quantity
                    Text(
                      AppTranslations.text('step_crop', lang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCrop,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.eco_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'Paddy (Grade A)',
                                child: Text(
                                  isTamil
                                      ? 'நெல் (கிரேடு ஏ)'
                                      : 'Paddy (Grade A)',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Paddy (Common)',
                                child: Text(
                                  isTamil ? 'நெல் (சாதாரண)' : 'Paddy (Common)',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Maize',
                                child: Text(isTamil ? 'மக்காச்சோளம்' : 'Maize'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedCrop = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _bagsController,
                            keyboardType: TextInputType.number,
                            onChanged: _onBagsChanged,
                            decoration: InputDecoration(
                              labelText: isTamil ? 'மூட்டை' : 'Bags',
                              suffixText: 'bags',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _generateToken,
                      icon: const Icon(Icons.confirmation_number_rounded),
                      label: Text(
                        AppTranslations.text('generate_token_btn', lang),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
