// di/injection.dart - CORRIGÉ

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pariba/data/repositories/subscription_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../core/security/token_manager.dart';
import '../core/services/group_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_messaging_service.dart';
import '../core/services/notification_service.dart';
import '../presentation/blocs/notification/notification_bloc.dart';
import '../core/services/payment_service.dart';
import '../core/services/preferences_service.dart'; // 👈 AJOUTER CET IMPORT
// Data
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/group_remote_datasource.dart';
import '../data/datasources/remote/membership_remote_datasource.dart';
import '../data/datasources/remote/invitation_remote_datasource.dart';
import '../data/datasources/remote/payment_remote_datasource.dart';
import '../data/datasources/remote/tour_remote_datasource.dart';
import '../data/datasources/remote/notification_remote_datasource.dart';
import '../data/datasources/remote/person_remote_datasource.dart';
import '../data/datasources/remote/dashboard_remote_datasource.dart';
import '../data/datasources/remote/advertisement_remote_datasource.dart';
import '../data/datasources/remote/contribution_remote_datasource.dart';
import '../data/datasources/remote/join_request_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/group_repository_impl.dart';
import '../data/repositories/contribution_repository_impl.dart';
import '../data/repositories/join_request_repository_impl.dart';
import '../domain/repositories/subscription_repository.dart';
import '../data/datasources/remote/subscription_remote_datasource.dart';
// Domain
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/repositories/contribution_repository.dart';
import '../domain/repositories/join_request_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/group/create_group_usecase.dart';
import '../domain/usecases/group/get_groups_usecase.dart';
import '../domain/usecases/notification/register_fcm_token_usecase.dart';

// Presentation - BLoCs
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/group/group_bloc.dart';
import '../presentation/blocs/membership/membership_bloc.dart';
import '../presentation/blocs/payment/payment_bloc.dart';
import '../presentation/blocs/tour/tour_bloc.dart';
import '../presentation/blocs/contribution/contribution_bloc.dart';
import '../presentation/blocs/join_request/join_request_bloc.dart';
import '../presentation/blocs/preferences/preferences_bloc.dart'; // 👈 AJOUTER L'IMPORT DU BLOC
// Services
import '../core/services/deep_link_service.dart';

final sl = GetIt.instance;

/// Initialize Dependency Injection
Future<void> initializeDependencies() async {
  print('🔄 Initialisation des dépendances...');

  // ============ Core ============

  // External - DOIT ÊTRE EN PREMIER
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  print('✅ SharedPreferences enregistré');

  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());

  // Services
  sl.registerLazySingleton(() => AuthService());
  print('✅ AuthService enregistré');

  sl.registerLazySingleton(() => Dio());

  // Security
  sl.registerLazySingleton(() => TokenManager(sl()));
  sl.registerLazySingleton(() => PaymentService());
  print('✅ PaymentService enregistré');

  // GroupService dépend de AuthService
  sl.registerLazySingleton(() => GroupService(authService: sl()));
  print('✅ GroupService enregistré');

  // Preferences Service - NOUVEAU
  sl.registerLazySingleton(() => PreferencesService(sl<SharedPreferences>()));
  print('✅ PreferencesService enregistré');

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));

  // Notifications
  sl.registerLazySingleton(() => FirebaseMessagingService());

  // NotificationService nécessite NotificationRemoteDataSource
  // On va le déclarer après les data sources

  // Deep Linking
  sl.registerLazySingleton(() => DeepLinkService());

  // ============ Data ============

  // DataSources
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSource(sl()),
  );

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
  sl.registerLazySingleton<TourRemoteDataSource>(
    () => TourRemoteDataSourceImpl(sl()),
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
  sl.registerLazySingleton<AdvertisementRemoteDataSource>(
    () => AdvertisementRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ContributionRemoteDataSource>(
    () => ContributionRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<JoinRequestRemoteDataSource>(
    () => JoinRequestRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenManager: sl()),
  );
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      remoteDataSource: sl(),
      invitationDataSource: sl(),
      tokenManager: sl(),
    ),
  );
  sl.registerLazySingleton<ContributionRepository>(
    () => ContributionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<JoinRequestRepository>(
    () => JoinRequestRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<SubscriptionRemoteDataSource>()),
  );

  // ============ Domain ============

  // UseCases - Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // UseCases - Group
  sl.registerLazySingleton(() => GetGroupsUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));

  // UseCases - Notification
  sl.registerLazySingleton(() => RegisterFcmTokenUseCase(sl()));

  // ============ Services dépendants ============

  // NotificationService nécessite NotificationRemoteDataSource
  sl.registerLazySingleton(
    () => NotificationService(sl(), notificationDataSource: sl()),
  );
  print('✅ NotificationService enregistré');

  // ============ Presentation ============

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
      authService: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => GroupBloc(
      getGroupsUseCase: sl(),
      createGroupUseCase: sl(),
      groupRepository: sl(),
    ),
  );

  sl.registerFactory(() => MembershipBloc(membershipDataSource: sl()));
  sl.registerFactory(() => NotificationBloc(notificationDataSource: sl()));
  sl.registerFactory(
    () => PaymentBloc(paymentService: sl(), paymentRemoteDataSource: sl()),
  );
  sl.registerFactory(() => TourBloc(tourRemoteDataSource: sl()));
  sl.registerFactory(() => ContributionBloc(contributionRepository: sl()));
  sl.registerFactory(() => JoinRequestBloc(sl()));

  // 👇 NOUVEAU - PreferencesBloc
  sl.registerFactory(() => PreferencesBloc(preferencesService: sl()));
  print('✅ PreferencesBloc enregistré');

  print('✅ Toutes les dépendances initialisées');
}
