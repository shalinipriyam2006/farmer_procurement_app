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
  bool _isLoadingGps = true;
  UserLocationResult _userLocation = const UserLocationResult(
    latitude: LocationService.defaultLat,
    longitude: LocationService.defaultLon,
    status: LocationStatus.granted,
    isFallback: true,
  );

  @override
  void initState() {
    super.initState();
    _acquireGpsLocation();
  }

  Future<void> _acquireGpsLocation() async {
    setState(() => _isLoadingGps = true);
    final location = await LocationService.getCurrentDeviceLocation();
    if (mounted) {
      setState(() {
        _userLocation = location;
        _isLoadingGps = false;
        if (!location.isFallback) {
          _sortByNearest = true; // Auto-sort by nearest when real GPS is detected
        }
      });
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
        var centers = repo.centers;
        final selectedId = repo.selectedCenterId;

        if (_sortByNearest && !_userLocation.isFallback) {
          centers = LocationService.sortCentresByNearest(
            centers,
            userLat: _userLocation.latitude,
            userLon: _userLocation.longitude,
          );
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
              // GPS Status & Filter Control Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.surfaceVariant,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilterChip(
                            selected: _sortByNearest && !_userLocation.isFallback,
                            avatar: Icon(
                              _userLocation.isFallback
                                  ? Icons.location_off_rounded
                                  : Icons.my_location_rounded,
                              size: 18,
                              color: (_sortByNearest && !_userLocation.isFallback) ? Colors.white : AppColors.primary,
                            ),
                            label: Text(
                              _userLocation.isFallback
                                  ? (isTamil ? 'இருப்பிடம் பெறப்படவில்லை' : 'Location unavailable')
                                  : (isTamil ? 'அருகிலுள்ள மையங்கள் (GPS)' : 'Nearest Centres (Real GPS)'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: (_sortByNearest && !_userLocation.isFallback) ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            onSelected: (val) {
                              if (_userLocation.isFallback) {
                                _acquireGpsLocation();
                              } else {
                                setState(() {
                                  _sortByNearest = val;
                                });
                              }
                            },
                          ),
                        ),
                        if (_isLoadingGps)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            onPressed: _acquireGpsLocation,
                            tooltip: 'Refresh GPS',
                          ),
                        Text(
                          '${centers.length} ${isTamil ? "நிலையங்கள்" : "centres"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    if (_userLocation.isFallback) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_off_rounded, size: 18, color: Colors.orange.shade900),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTamil
                                    ? 'இருப்பிடம் பெறப்படவில்லை. உங்கள் அருகிலுள்ள கொள்முதல் நிலையங்களை கண்டறிய GPS அனுமதியை இயக்கவும்.'
                                    : 'Location unavailable. Enable location to find procurement centres near you.',
                                style: TextStyle(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: _acquireGpsLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isTamil ? 'மீண்டும் முயற்சிக்க' : 'Retry GPS',
                                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          
                          // Only compute and format distance if real GPS position is available
                          final String distanceLabel = _userLocation.isFallback
                              ? (isTamil ? 'இருப்பிடம் பெறப்படவில்லை' : 'Location unavailable')
                              : '${LocationService.calculateDistanceKm(_userLocation.latitude, _userLocation.longitude, center.latitude, center.longitude).toStringAsFixed(1)} km';

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
                                      ? AppColors.primary.withOpacity(0.12)
                                      : Colors.black.withOpacity(0.04),
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
                                                Icon(
                                                  _userLocation.isFallback ? Icons.location_off_rounded : Icons.near_me_rounded,
                                                  size: 14,
                                                  color: _userLocation.isFallback ? AppColors.textTertiary : AppColors.secondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$distanceLabel • ${center.district} (${center.taluk})',
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: _userLocation.isFallback ? AppColors.textTertiary : AppColors.textSecondary,
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
