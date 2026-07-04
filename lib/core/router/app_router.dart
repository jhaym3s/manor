import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../screens/auth/not_registered_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/phone_entry_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/splash_screen.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

GoRouter buildAppRouter() {
  final authBloc = getIt<AuthBloc>();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final phase = authBloc.state.phase;
      final loc = state.matchedLocation;
      const authRoutes = {'/welcome', '/phone', '/otp'};

      switch (phase) {
        case AuthPhase.initial:
        case AuthPhase.submitting:
          return null;
        case AuthPhase.unauthenticated:
          return authRoutes.contains(loc) ? null : '/welcome';
        case AuthPhase.codeSent:
          return loc == '/otp' ? null : '/otp';
        case AuthPhase.notRegistered:
          return loc == '/not-registered' ? null : '/not-registered';
        case AuthPhase.authenticated:
          return loc == '/home' ? null : '/home';
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/not-registered',
        builder: (context, state) => const NotRegisteredScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
    ],
  );
}
