import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/widgets/language_toggle_button.dart';
import 'package:farmer_procurement_app/presentation/screens/notifications/notifications_sheet.dart';
import 'package:farmer_procurement_app/presentation/screens/home/farmer_home_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/token/book_token_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/queue/live_queue_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/status/procurement_status_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/profile/profile_screen.dart';
import 'package:farmer_procurement_app/presentation/screens/officer/officer_dashboard_screen.dart';

class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({super.key});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final unreadCount = repo.unreadNotificationCount;

        final List<Widget> screens = [
          FarmerHomeScreen(onTabSelect: _onTabSelected),
          const BookTokenScreen(),
          const LiveQueueScreen(),
          const ProcurementStatusScreen(),
          const ProfileScreen(),
        ];

        final List<String> screenTitles = [
          AppTranslations.text('app_title', lang),
          AppTranslations.text('book_digital_token', lang),
          AppTranslations.text('live_queue_system', lang),
          AppTranslations.text('procurement_status', lang),
          AppTranslations.text('profile', lang),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(screenTitles[_currentIndex]),
            actions: [
              // Language Switcher Button
              const LanguageToggleButton(isLight: true),
              const SizedBox(width: 4),

              // Officer Portal Shortcut
              IconButton(
                icon: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Officer Portal',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OfficerDashboardScreen(),
                    ),
                  );
                },
              ),

              // Notification Bell with Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _showNotificationsSheet,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primaryContainer,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(
                    Icons.home_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: AppTranslations.text('home', lang),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.confirmation_number_outlined),
                  selectedIcon: const Icon(
                    Icons.confirmation_number_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: AppTranslations.text('token', lang),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.groups_outlined),
                  selectedIcon: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: AppTranslations.text('queue', lang),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.timeline_rounded),
                  selectedIcon: const Icon(
                    Icons.timeline_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: AppTranslations.text('status', lang),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: AppTranslations.text('profile', lang),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
