import '../models/worker_models.dart';
import '../screens/worker/voice_registration_screen.dart';
import '../screens/worker/profile_confirm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/language/language_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';

import '../screens/home/customer_home_screen.dart';
import '../screens/home/worker_dashboard_screen.dart';

import '../screens/worker/portfolio_screen.dart';

import '../screens/search/worker_search_screen.dart';
import '../screens/search/worker_details_screen.dart';

import '../screens/shared/set_location_screen.dart';

import '../screens/booking/create_booking_screen.dart';
import '../screens/booking/my_bookings_screen.dart';

import '../screens/notifications/notifications_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class HomeRouterScreen extends ConsumerWidget {
  const HomeRouterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (user.userType) {
      case 'worker':
        return const WorkerDashboardScreen();
      case 'admin':
        return const AdminDashboardScreen();
      default:
        return const CustomerHomeScreen();
    }
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return OtpScreen(
          phone: extra['phone'],
          mockOtp: extra['mockOtp'],
        );
      },
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeRouterScreen(),
    ),

    GoRoute(
      path: '/worker/voice-registration',
      builder: (context, state) =>
          const VoiceRegistrationScreen(),
    ),

    GoRoute(
      path: '/worker/confirm-profile',
      builder: (context, state) => ProfileConfirmScreen(
        extracted: state.extra as ExtractedProfile,
      ),
    ),

    GoRoute(
      path: '/worker/portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),

    GoRoute(
      path: '/customer/search',
      builder: (context, state) => const WorkerSearchScreen(),
    ),

    GoRoute(
      path: '/set-location',
      builder: (context, state) => SetLocationScreen(
        redirectTo: state.uri.queryParameters['redirect'] ?? '/home',
      ),
    ),

    GoRoute(
      path: '/booking/create/:workerId',
      builder: (context, state) => CreateBookingScreen(
        workerId: int.parse(state.pathParameters['workerId']!),
      ),
    ),

    GoRoute(
      path: '/customer/bookings',
      builder: (context, state) =>
          const MyBookingsScreen(isWorker: false),
    ),

    GoRoute(
      path: '/worker/bookings',
      builder: (context, state) =>
          const MyBookingsScreen(isWorker: true),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
          const NotificationsScreen(),
    ),

    GoRoute(
      path: '/worker/:id',
      builder: (context, state) => WorkerDetailsScreen(
        workerId: state.pathParameters['id']!,
      ),
    ),
  ],
);