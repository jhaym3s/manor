// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart' as messaging;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:get_it/get_it.dart' as GI;
import 'package:injectable/injectable.dart' as inject;
import 'package:manor/core/di/firebase_module.dart' as module;

extension GetItInjectableX on GI.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  GI.GetIt init({
    String? environment,
    inject.EnvironmentFilter? environmentFilter,
  }) {
    final gh = inject.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<auth.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<cloud.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<storage.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<messaging.FirebaseMessaging>(
      () => firebaseModule.firebaseMessaging,
    );
    return this;
  }
}

class _$FirebaseModule extends module.FirebaseModule {}
