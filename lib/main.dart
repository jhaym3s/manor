import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/blocs/auth/auth_bloc.dart';
import 'package:manor/core/bloc/app_bloc_observer.dart';
import 'package:manor/core/di/injection.dart';
import 'package:manor/core/router/app_router.dart';
import 'package:manor/core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  Bloc.observer = AppBlocObserver();

  if (kDebugMode) {
    debugPrint('DI ready — Firebase and Bloc wired up.');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EstateApp());
}

class EstateApp extends StatefulWidget {
  const EstateApp({super.key});

  @override
  State<EstateApp> createState() => _EstateAppState();
}

class _EstateAppState extends State<EstateApp> {
  // Created once and reused — GoRouter (and the stream subscription its
  // refreshListenable holds) must not be rebuilt on every widget rebuild.
  late final GoRouter _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      // Must run immediately, not lazily on first context.read<AuthBloc>() —
      // the router reads the bloc directly via getIt and the splash screen
      // never touches it via context, so lazy creation would never fire
      // AuthCheckRequested and the app would sit on the splash loader forever.
      lazy: false,
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'Manor Estates',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
