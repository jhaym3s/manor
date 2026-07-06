import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../screens/auth/not_registered_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/phone_entry_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/security/security_home_screen.dart';
import '../../screens/security/verify_visitor_screen.dart';
import '../../screens/security/visitor_log_screen.dart';
import '../../screens/splash_screen.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

GoRouter buildAppRouter() {
  final authBloc = getIt<AuthBloc>();

  String homeRouteFor(AuthState state) {
    return state.user?.role == 'security' ? '/security' : '/home';
  }

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final phase = authState.phase;
      final loc = state.matchedLocation;

      // Routes reachable before/without a completed sign-in. `redirect` re-runs
      // on every navigation (not just once after login), so "authenticated"
      // must only redirect *away from these*, never away from in-app routes
      // like /security/verify — otherwise every push just bounces back home.
      const preAuthRoutes = {
        '/',
        '/welcome',
        '/phone',
        '/otp',
        '/not-registered',
      };

      switch (phase) {
        case AuthPhase.initial:
        case AuthPhase.submitting:
          return null;
        case AuthPhase.unauthenticated:
          return loc == '/welcome' || loc == '/phone' ? null : '/welcome';
        case AuthPhase.codeSent:
          return loc == '/otp' ? null : '/otp';
        case AuthPhase.notRegistered:
          return loc == '/not-registered' ? null : '/not-registered';
        case AuthPhase.authenticated:
          return preAuthRoutes.contains(loc) ? homeRouteFor(authState) : null;
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecurityHomeScreen(),
      ),
      GoRoute(
        path: '/security/verify',
        builder: (context, state) => const VerifyVisitorScreen(),
      ),
      GoRoute(
        path: '/security/log',
        builder: (context, state) => const VisitorLogScreen(),
      ),
    ],
  );
}
