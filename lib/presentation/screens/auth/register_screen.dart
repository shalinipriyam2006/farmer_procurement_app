import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/home/main_nav_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _farmerIdController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  late String _selectedCenterId;

  @override
  void initState() {
    super.initState();
    final repo = ProcurementRepository();
    _selectedCenterId = repo.centers[0].id;
    // Pre-fill reasonable defaults to minimize typing for testing
    _districtController.text = 'Thanjavur';
    _villageController.text = 'Thiruvaiyaru';
    _farmerIdController.text =
        'TN-KISAN-${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _farmerIdController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      final repo = ProcurementRepository();
      repo.registerFarmer(
        name: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        farmerIdNumber: _farmerIdController.text.trim(),
        village: _villageController.text.trim(),
        district: _districtController.text.trim(),
        preferredCentreId: _selectedCenterId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            repo.isTamil
                ? 'விவசாயி பதிவு வெற்றிகரமாக முடிந்தது!'
                : 'Registration successful!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScaffold()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.text('farmer_registration', lang)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isTamil
                        ? 'அரசு நேரடி கொள்முதல் பதிவு'
                        : 'Government Farmer Procurement KYC',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTamil ? 'உங்கள் விவரங்களை உள்ளிட்டு பதிவு செய்யுங்கள்' : 'Enter your basic agricultural credentials to proceed',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('full_name', lang),
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? (isTamil ? 'பெயர் தேவை' : 'Name is required')
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Mobile
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('enter_mobile', lang),
                      prefixIcon: const Icon(Icons.phone_rounded),
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.length < 10)
                        ? (isTamil
                              ? '10 இலக்க எண் தேவை'
                              : 'Enter 10-digit number')
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Farmer ID
                  TextFormField(
                    controller: _farmerIdController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('farmer_id', lang),
                      prefixIcon: const Icon(Icons.badge_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Village
                  TextFormField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('village', lang),
                      prefixIcon: const Icon(Icons.home_work_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // District
                  TextFormField(
                    controller: _districtController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('district', lang),
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferred Procurement Centre
                  DropdownButtonFormField<String>(
                    value: _selectedCenterId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppTranslations.text('pref_centre', lang),
                      prefixIcon: const Icon(Icons.storefront_rounded),
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
                  const SizedBox(height: 28),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitRegistration,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(AppTranslations.text('register_now', lang)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
