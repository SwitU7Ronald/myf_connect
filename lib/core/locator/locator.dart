import 'package:get_it/get_it.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/camps/data/repositories/camps_repository.dart';
import 'package:myf_connect/features/myfs/data/repositories/myfs_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myf_connect/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:myf_connect/features/camps/presentation/bloc/camps_bloc.dart';
import 'package:myf_connect/features/myfs/presentation/bloc/myfs_bloc.dart';

import 'package:myf_connect/features/events/presentation/cubit/events_cubit.dart';
import 'package:myf_connect/features/events/presentation/cubit/rating_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_camps_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_myfs_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_events_cubit.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/services/permission_service.dart';
import 'package:myf_connect/core/services/logger_service.dart';

final sl = GetIt.instance;

void init() {
  // ── Global Services ──────────────────────────────────────────────
  sl.registerLazySingleton<PermissionService>(() => PermissionServiceImpl());
  sl.registerLazySingleton<LoggerService>(() => LoggerServiceImpl());

  // ── Firebase & External ──────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ── Repositories (interface type → concrete impl) ─────────────────
  // Registering against the abstract interface type satisfies DIP:
  // all consumers depend on the interface, not the concrete class.
  sl.registerLazySingleton(() => UserRepository(firestore: sl()));
  sl.registerLazySingleton(
    () => AuthRepository(firebaseAuth: sl(), userRepository: sl()),
  );
  sl.registerLazySingleton<CampsRepository>(
    () => CampsRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MyfsRepository>(
    () => MyfsRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => EventRepository(firestore: sl()));
  sl.registerLazySingleton(() => AdminRepository(firestore: sl()));

  // ── Blocs & Cubits ───────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(authRepository: sl(), userRepository: sl()),
  );
  sl.registerFactory(
    () => CampsBloc(
      campsRepository: sl(),
      userRepository: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => MyfsBloc(
      myfsRepository: sl(),
      userRepository: sl(),
      authRepository: sl(),
    ),
  );

  // ── Shared Events & Rating Cubits (parameterised via GetIt params) ─
  // param1 = parentId (String), param2 = isCamp (bool)
  sl.registerFactoryParam<EventsCubit, String, bool>(
    (parentId, isCamp) => EventsCubit(
      eventRepository: sl(),
      parentId: parentId,
      isCamp: isCamp,
    ),
  );
  sl.registerFactoryParam<RatingCubit, String, bool>(
    (parentId, isCamp) => RatingCubit(
      eventRepository: sl(),
      parentId: parentId,
      isCamp: isCamp,
    ),
  );

  sl.registerFactory(() => ProfileCubit(campsRepository: sl(), myfsRepository: sl()));

  sl.registerFactory(() => AdminCampsCubit(adminRepository: sl()));
  sl.registerFactory(() => AdminMyfsCubit(adminRepository: sl()));
  sl.registerFactory(() => AdminUsersCubit(adminRepository: sl()));
  sl.registerFactory(() => AdminEventsCubit(adminRepository: sl()));
}
