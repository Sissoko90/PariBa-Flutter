import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../core/security/token_manager.dart';

// Data
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/group_remote_datasource.dart';
import '../data/datasources/remote/membership_remote_datasource.dart';
import '../data/datasources/remote/invitation_remote_datasource.dart';
import '../data/datasources/remote/payment_remote_datasource.dart';
import '../data/datasources/remote/notification_remote_datasource.dart';
import '../data/datasources/remote/person_remote_datasource.dart';
import '../data/datasources/remote/dashboard_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/group_repository_impl.dart';

// Domain
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/group/create_group_usecase.dart';
import '../domain/usecases/group/get_groups_usecase.dart';

// Presentation
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/group/group_bloc.dart';
import '../presentation/blocs/membership/membership_bloc.dart';

final sl = GetIt.instance;

/// Initialize Dependency Injection
Future<void> initializeDependencies() async {
  // ============ Core ============
  
  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  
  // Security
  sl.registerLazySingleton(() => TokenManager(sl()));
  
  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));

  // ============ Data ============
  
  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MembershipRemoteDataSource>(
    () => MembershipRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InvitationRemoteDataSource>(
    () => InvitationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PersonRemoteDataSource>(
    () => PersonRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenManager: sl(),
    ),
  );
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      remoteDataSource: sl(),
      invitationDataSource: sl(),
      tokenManager: sl(),
    ),
  );

  // ============ Domain ============
  
  // UseCases - Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  
  // UseCases - Group
  sl.registerLazySingleton(() => GetGroupsUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));

  // ============ Presentation ============
  
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
      tokenManager: sl(),
    ),
  );
  
  sl.registerFactory(
    () => GroupBloc(
      getGroupsUseCase: sl(),
      createGroupUseCase: sl(),
      groupRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => MembershipBloc(
      membershipDataSource: sl(),
    ),
  );
}
