import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';
import 'package:farmer_procurement_app/core/services/location_service.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

enum CentreFilterMode { smart, nearest, shortestQueue, lowestWait }

class CentersListScreen extends StatefulWidget {
  const CentersListScreen({super.key});

  @override
  State<CentersListScreen> createState() => _CentersListScreenState();
}

class _CentersListScreenState extends State<CentersListScreen> {
  bool _isMapView = false;
  CentreFilterMode _filterMode = CentreFilterMode.smart;
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
      });
    }
  }

  double _calculateScore(ProcurementCenter c) {
    if (c.status.toUpperCase() == 'CLOSED') {
      return -1000.0;
    }
    final dist = LocationService.calculateDistanceKm(
      _userLocation.latitude,
      _userLocation.longitude,
      c.latitude,
      c.longitude,
    );
    final statusBonus = c.status.toUpperCase() == 'OPEN' ? 100.0 : 0.0;
    return statusBonus - (dist * 2.0) - (c.activeTokensCount * 0.5) - (c.avgWaitMinutes * 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;
        var centers = List<ProcurementCenter>.from(repo.centers);
        final selectedId = repo.selectedCenterId;

        // Find top recommended centre id
        String topRecommendedId = '';
        if (centers.isNotEmpty) {
          final sortedForRec = List<ProcurementCenter>.from(centers)
            ..sort((a, b) => _calculateScore(b).compareTo(_calculateScore(a)));
          topRecommendedId = sortedForRec.first.id;
        }

        // Apply selected sorting mode
        switch (_filterMode) {
          case CentreFilterMode.smart:
            centers.sort((a, b) => _calculateScore(b).compareTo(_calculateScore(a)));
            break;
          case CentreFilterMode.nearest:
            centers = LocationService.sortCentresByNearest(
              centers,
              userLat: _userLocation.latitude,
              userLon: _userLocation.longitude,
            );
            break;
          case CentreFilterMode.shortestQueue:
            centers.sort((a, b) => a.activeTokensCount.compareTo(b.activeTokensCount));
            break;
          case CentreFilterMode.lowestWait:
            centers.sort((a, b) => a.avgWaitMinutes.compareTo(b.avgWaitMinutes));
            break;
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppColors.surfaceVariant,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            selected: _filterMode == CentreFilterMode.smart,
                            avatar: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.amber),
                            label: Text(
                              isTamil ? '⭐ AI பரிந்துரை' : '⭐ Recommended',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _filterMode == CentreFilterMode.smart ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setState(() => _filterMode = CentreFilterMode.smart),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            selected: _filterMode == CentreFilterMode.nearest,
                            avatar: const Icon(Icons.near_me_rounded, size: 16),
                            label: Text(
                              isTamil ? 'அருகில்' : 'Nearest GPS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _filterMode == CentreFilterMode.nearest ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setState(() => _filterMode = CentreFilterMode.nearest),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            selected: _filterMode == CentreFilterMode.shortestQueue,
                            avatar: const Icon(Icons.groups_rounded, size: 16),
                            label: Text(
                              isTamil ? 'குறைந்த வரிசை' : 'Shortest Queue',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _filterMode == CentreFilterMode.shortestQueue ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setState(() => _filterMode = CentreFilterMode.shortestQueue),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            selected: _filterMode == CentreFilterMode.lowestWait,
                            avatar: const Icon(Icons.timer_rounded, size: 16),
                            label: Text(
                              isTamil ? 'குறைந்த நேரம்' : 'Lowest Wait',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _filterMode == CentreFilterMode.lowestWait ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setState(() => _filterMode = CentreFilterMode.lowestWait),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _userLocation.isFallback ? Icons.location_off_rounded : Icons.my_location_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _userLocation.isFallback
                                ? (isTamil ? 'இருப்பிடம்: பொதுவான நிலை (GPS)' : 'Location: Default (GPS Offline)')
                                : (isTamil ? 'GPS செயல்படுகிறது (${_userLocation.latitude.toStringAsFixed(3)}, ${_userLocation.longitude.toStringAsFixed(3)})' : 'GPS Active (${_userLocation.latitude.toStringAsFixed(3)}, ${_userLocation.longitude.toStringAsFixed(3)})'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ),
                        if (_isLoadingGps)
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          InkWell(
                            onTap: _acquireGpsLocation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                isTamil ? 'GPS புதுப்பி' : 'Refresh GPS',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
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
                          final isRecommended = center.id == topRecommendedId;
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
                                color: isSelected
                                    ? AppColors.primary
                                    : (isRecommended ? Colors.amber.shade700 : AppColors.divider),
                                width: (isSelected || isRecommended) ? 2.5 : 1,
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
                                  if (isRecommended) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.amber.shade800),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.amber.shade900),
                                          const SizedBox(width: 4),
                                          Text(
                                            isTamil ? '⭐ பரிந்துரைக்கப்பட்ட மையம் (Best Match)' : '⭐ RECOMMENDED CENTRE (Best Match)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
