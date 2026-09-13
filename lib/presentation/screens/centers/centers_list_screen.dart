import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/services/location_service.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class CentersListScreen extends StatefulWidget {
  const CentersListScreen({super.key});

  @override
  State<CentersListScreen> createState() => _CentersListScreenState();
}

class _CentersListScreenState extends State<CentersListScreen> {
  bool _isMapView = false;
  bool _sortByNearest = false;

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        var centers = repo.centers;
        final selectedId = repo.selectedCenterId;

        if (_sortByNearest) {
          centers = LocationService.sortCentresByNearest(centers);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.text('procurement_centres', lang)),
            actions: [
              IconButton(
                tooltip: isTamil ? 'பார்வை மாற்று (Map/List)' : 'Toggle Map View',
                icon: Icon(_isMapView ? Icons.list_alt_rounded : Icons.map_rounded),
                onPressed: () {
                  setState(() => _isMapView = !_isMapView);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // GPS & Filter Control Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surfaceVariant,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _sortByNearest,
                      avatar: Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: _sortByNearest ? Colors.white : AppColors.primary,
                      ),
                      label: Text(
                        isTamil ? 'அருகிலுள்ள மையங்கள்' : 'Nearest Centres (GPS)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _sortByNearest ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selectedColor: AppColors.primary,
                      onSelected: (val) {
                        setState(() {
                          _sortByNearest = val;
                        });
                        if (val) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isTamil
                                    ? 'GPS தூரம் அடிப்படையில் வரிசைப்படுத்தப்பட்டது'
                                    : 'Centres sorted by nearest GPS location',
                              ),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${centers.length} ${isTamil ? "நிலையங்கள்" : "centres"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isMapView
                    ? _buildMapViewPlaceholder(isTamil, centers)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: centers.length,
                        itemBuilder: (context, index) {
                          final center = centers[index];
                          final isSelected = center.id == selectedId;
                          final name = isTamil ? center.nameTa : center.nameEn;
                          final dist = LocationService.calculateDistanceKm(
                            10.7867,
                            79.1378,
                            center.latitude,
                            center.longitude,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryContainer
                                              : AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          Icons.storefront_rounded,
                                          color: isSelected
                                              ? AppColors.primaryDark
                                              : AppColors.textSecondary,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.near_me_rounded,
                                                  size: 14,
                                                  color: AppColors.secondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${dist.toStringAsFixed(1)} km • ${center.district} (${center.taluk})',
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isTamil ? 'தேர்வு' : 'SELECTED',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    center.locationAddress,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppTranslations.text('working_hours', lang),
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                center.workingHours,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 36,
                                          color: AppColors.divider,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isTamil ? 'வரிசை / நிலை' : 'Queue / Status',
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${center.activeTokensCount} ${isTamil ? "டோக்கன்" : "tokens"} • ${center.status}',
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isTamil
                                                      ? '${center.nameTa}-க்கு வழிசெலுத்தல் துவங்குகிறது (${center.latitude}, ${center.longitude})'
                                                      : 'Opening directions to ${center.nameEn}...',
                                                ),
                                                backgroundColor: AppColors.secondary,
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.directions_rounded, size: 18),
                                          label: Text(isTamil ? 'வழிசெலுத்தல்' : 'Get Directions'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      if (!isSelected) ...[
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              repo.setSelectedCenter(center.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    isTamil
                                                        ? '$name தேர்ந்தெடுக்கப்பட்டது'
                                                        : '$name selected as active centre',
                                                  ),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                            label: Text(
                                              isTamil ? 'தேர்ந்தெடு' : 'Select',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapViewPlaceholder(bool isTamil, List<dynamic> centers) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            isTamil ? 'வரைபடக் காட்சி (GIS Procurement Map)' : 'GIS Procurement Map View',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            isTamil
                ? 'அனைத்து ${centers.length} கொள்முதல் நிலையங்களின் GPS வரைபட புள்ளிகள் காட்சிப்படுத்தப்பட்டுள்ளன.'
                : 'Displaying exact GPS coordinates for all ${centers.length} official procurement centres.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isMapView = false),
            icon: const Icon(Icons.list_rounded),
            label: Text(isTamil ? 'பட்டியலுக்கு திரும்பு' : 'Switch to List View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
