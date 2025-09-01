// // screens/main_navigation_screen.dart - FIXED VERSION

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import '../config/app_theme.dart';
// import '../providers/premium_provider.dart';
// import '../providers/ads_provider.dart';
// import '../widgets/ad_widgets.dart';
// import 'camera_screen.dart';
// import 'history_screen.dart';
// import 'home_screen.dart';
// import 'premium_screen.dart';
// import 'profile_screen.dart';

// class MainNavigationScreen extends ConsumerStatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   ConsumerState<MainNavigationScreen> createState() =>
//       _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
//   int _currentIndex = 0;
//   late PageController _pageController;

//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const HistoryScreen(),
//     const CameraScreen(),
//     const ProfileScreen(),
//     const PremiumScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() => _currentIndex = index);
//               // Trigger interstitial ad on page change
//               if (!isPremium && index != _currentIndex) {
//                 ref.read(adsProvider.notifier).onScreenTransition();
//               }
//             },
//             children: _screens,
//           ),

//           // Persistent banner ad for free users - FIXED
//           if (!isPremium)
//             Positioned(
//               // bottom: kBottomNavigationBarHeight + 8,
//               bottom: 5,
//               left: 0,
//               right: 0,
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: theme.shadowColor.withOpacity(0.1),
//                       blurRadius: 12,
//                       spreadRadius: 0,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: const AdBanner(
//                   placement: 'navigation_persistent',
//                   adSize: AdSize.banner, // Use standard banner size
//                   margin: EdgeInsets.zero, // Remove default margin
//                 ),
//               ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(isPremium, theme),
//       floatingActionButton: _buildFloatingActionButton(theme),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   Widget _buildBottomNavigationBar(bool isPremium, ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomAppBar(
//         height: 86, // Fixed height to prevent overflow
//         notchMargin: 6,
//         shape: const CircularNotchedRectangle(),
//         color: theme.colorScheme.surface,
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', theme),
//               _buildNavItem(
//                   1, Icons.history_outlined, Icons.history, 'History', theme),
//               const SizedBox(width: 40), // Space for FAB
//               _buildNavItem(
//                   3, Icons.person_outline, Icons.person, 'Profile', theme),
//               _buildPremiumNavItem(isPremium, theme),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon,
//       String label, ThemeData theme) {
//     final isSelected = _currentIndex == index;

//     return Expanded(
//       child: InkWell(
//         onTap: () => _navigateToPage(index),
//         borderRadius: BorderRadius.circular(8),
//         splashColor: theme.colorScheme.primary.withOpacity(0.1),
//         highlightColor: theme.colorScheme.primary.withOpacity(0.05),
//         child: Container(
//           height: 56, // Fixed height to prevent overflow
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? theme.colorScheme.primary.withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedScale(
//                 scale: isSelected ? 1.1 : 1.0,
//                 duration: const Duration(milliseconds: 200),
//                 child: Icon(
//                   isSelected ? filledIcon : outlinedIcon,
//                   color: isSelected
//                       ? theme.colorScheme.primary
//                       : theme.colorScheme.onSurfaceVariant,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Flexible(
//                 child: AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 200),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: isSelected
//                         ? theme.colorScheme.primary
//                         : theme.colorScheme.onSurfaceVariant,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                     height: 1.0,
//                   ),
//                   child: Text(
//                     label,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPremiumNavItem(bool isPremium, ThemeData theme) {
//     final isSelected = _currentIndex == 4;

//     return Expanded(
//       child: InkWell(
//         onTap: () => _navigateToPage(4),
//         borderRadius: BorderRadius.circular(8),
//         splashColor: AppTheme.premiumGold.withOpacity(0.1),
//         highlightColor: AppTheme.premiumGold.withOpacity(0.05),
//         child: Container(
//           height: 56,
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           decoration: BoxDecoration(
//             gradient: isPremium
//                 ? LinearGradient(
//                     colors: [
//                       AppTheme.premiumGold.withOpacity(0.8),
//                       AppTheme.premiumGold,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   )
//                 : (isSelected
//                     ? LinearGradient(
//                         colors: [
//                           AppTheme.premiumGold.withOpacity(0.1),
//                           AppTheme.premiumGold.withOpacity(0.05),
//                         ],
//                       )
//                     : null),
//             borderRadius: BorderRadius.circular(8),
//             border: isPremium
//                 ? null
//                 : Border.all(
//                     color: isSelected
//                         ? AppTheme.premiumGold.withOpacity(0.3)
//                         : Colors.transparent,
//                     width: 1,
//                   ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedScale(
//                 scale: isSelected ? 1.1 : 1.0,
//                 duration: const Duration(milliseconds: 200),
//                 child: Icon(
//                   isPremium
//                       ? Icons.diamond_rounded
//                       : Icons.workspace_premium_outlined,
//                   color: isPremium
//                       ? Colors.white
//                       : (isSelected
//                           ? AppTheme.premiumGold
//                           : theme.colorScheme.onSurfaceVariant),
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Flexible(
//                 child: AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 200),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: isPremium
//                         ? Colors.white
//                         : (isSelected
//                             ? AppTheme.premiumGold
//                             : theme.colorScheme.onSurfaceVariant),
//                     fontWeight: FontWeight.w600,
//                     height: 1.0,
//                   ),
//                   child: Text(
//                     isPremium ? 'Pro' : 'Premium',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton(ThemeData theme) {
//     return Container(
//       width: 56,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             theme.colorScheme.primary,
//             theme.colorScheme.secondary,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.4),
//             blurRadius: 12,
//             spreadRadius: 2,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: FloatingActionButton(
//         onPressed: () => _navigateToPage(2),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         child: const Icon(
//           Icons.camera_alt,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     ).animate().scale(delay: 300.ms);
//   }

//   void _navigateToPage(int index) {
//     if (_currentIndex == index) return;

//     setState(() => _currentIndex = index);
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/premium_provider.dart';
import '../providers/ads_provider.dart';
import '../widgets/ad_widgets.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart'; // Import SettingsScreen
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const CameraScreen(),
    const ProfileScreen(),
    const SettingsScreen(), // Replaced PremiumScreen with SettingsScreen
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).isPremium;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // Trigger interstitial ad on page change, except for CameraScreen
              if (!isPremium && index != _currentIndex && index != 2) {
                ref.read(adsProvider.notifier).onScreenTransition();
              }
            },
            children: _screens,
          ),
          // Persistent banner ad for free users, hidden on CameraScreen
          if (!isPremium && _currentIndex != 2)
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const AdBanner(
                  placement: 'navigation_persistent',
                  adSize: AdSize.banner,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isPremium, theme),
      floatingActionButton: _buildFloatingActionButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(bool isPremium, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 86,
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        color: theme.colorScheme.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', theme),
              _buildNavItem(
                  1, Icons.history_outlined, Icons.history, 'History', theme),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(
                  3, Icons.person_outline, Icons.person, 'Profile', theme),
              _buildSettingsNavItem(
                  theme), // Replaced PremiumNavItem with SettingsNavItem
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon,
      String label, ThemeData theme) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToPage(index),
        borderRadius: BorderRadius.circular(8),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsNavItem(ThemeData theme) {
    final isSelected = _currentIndex == 4;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToPage(4),
        borderRadius: BorderRadius.circular(8),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.settings_rounded : Icons.settings_outlined,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                  child: const Text(
                    'Settings',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToPage(2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 24,
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
