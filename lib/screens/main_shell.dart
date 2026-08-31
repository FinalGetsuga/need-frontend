import 'package:flutter/material.dart';
import 'package:need_mobile_app/providers/auth_provider.dart';
import 'package:need_mobile_app/providers/booking_provider.dart';
import 'package:need_mobile_app/providers/business_provider.dart';
import 'package:need_mobile_app/providers/employee_provider.dart';
import 'package:need_mobile_app/providers/user_provider.dart';
import 'package:need_mobile_app/screens/business/business_list_screen.dart';
import 'package:need_mobile_app/screens/profile_screen.dart';
import 'package:need_mobile_app/utils/app_colors.dart';
import 'package:provider/provider.dart';

import 'booking/bookings_tab_screen.dart';
import 'home/home_screen.dart';

class MainShell extends StatefulWidget{
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool? _wasSignedIn;
  AuthProvider? _authProvider;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  late final List<Widget> _tabs = [
    HomeScreen(
        onExplorePressed: () => _goToTab(1),
        onViewBookingsPressed: () => _goToTab(2),
    ),
    const BusinessListScreen(),
    const BookingsTabScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authProvider = context.read<AuthProvider>();
      _wasSignedIn = _authProvider!.isSignedIn;
      _authProvider!.addListener(_onAuthChanged);
      if (_wasSignedIn == true) _loadUserScopedData();
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final isSignedIn = _authProvider!.isSignedIn;
    if (isSignedIn == _wasSignedIn) return;
    _wasSignedIn = isSignedIn;

    if (isSignedIn) {
      _loadUserScopedData();
    } else {
      _clearUserScopedData();
    }
  }

  void _loadUserScopedData() {
    context.read<UserProvider>().loadCurrentUser();
    context.read<BusinessProvider>().loadMyBusiness();
    context.read<BookingProvider>().loadMyBookings();
    context.read<BookingProvider>().loadNextUpcomingBooking();
    context.read<EmployeeProvider>().loadMyEmployment();
  }

  void _clearUserScopedData() {
    context.read<UserProvider>().clear();
    context.read<BusinessProvider>().clearMineBusiness();
    context.read<BookingProvider>().clearUserBookings();
    context.read<EmployeeProvider>().clearMyEmployment();
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
      ),
    );
  }
}