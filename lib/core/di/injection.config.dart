// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:manor/blocs/access_codes/access_codes_bloc.dart' as _i638;
import 'package:manor/blocs/auth/auth_bloc.dart' as _i942;
import 'package:manor/blocs/dues/dues_bloc.dart' as _i363;
import 'package:manor/blocs/visitor_log/visitor_log_bloc.dart' as _i456;
import 'package:manor/core/di/firebase_module.dart' as _i941;
import 'package:manor/data/repositories/access_code_repository.dart' as _i1009;
import 'package:manor/data/repositories/auth_repository.dart' as _i249;
import 'package:manor/data/repositories/due_repository.dart' as _i174;
import 'package:manor/data/repositories/visitor_log_repository.dart' as _i470;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => firebaseModule.firebaseMessaging,
    );
    gh.lazySingleton<_i249.AuthRepository>(
      () => _i249.AuthRepository(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i1009.AccessCodeRepository>(
      () => _i1009.AccessCodeRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i174.DueRepository>(
      () => _i174.DueRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i470.VisitorLogRepository>(
      () => _i470.VisitorLogRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i942.AuthBloc>(
      () => _i942.AuthBloc(gh<_i249.AuthRepository>()),
    );
    gh.factory<_i363.DuesBloc>(() => _i363.DuesBloc(gh<_i174.DueRepository>()));
    gh.factory<_i638.AccessCodesBloc>(
      () => _i638.AccessCodesBloc(gh<_i1009.AccessCodeRepository>()),
    );
    gh.factory<_i456.VisitorLogBloc>(
      () => _i456.VisitorLogBloc(gh<_i470.VisitorLogRepository>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i941.FirebaseModule {}
