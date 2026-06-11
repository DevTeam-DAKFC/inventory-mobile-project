import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/notification_registration_storage.dart';
import '../../domain/repositories/notification_token_repository.dart';
import '../../navigation/app_router.dart';
import '../../navigation/routes.dart';
import '../../notifications/firebase_messaging_gateway.dart';
import '../../notifications/local_notification_service.dart';
import '../../notifications/notification_reception_coordinator.dart';
import '../../notifications/notification_session_coordinator.dart';
import '../../notifications/push_notification_service.dart';
import '../datasources/rest/rest_api_notification_token_data_source.dart';
import '../repositories/notification_token_repository_impl.dart';
import 'auth_providers.dart';

final notificationTokenDataSourceProvider =
    Provider<RestApiNotificationTokenDataSource>(
      (ref) => RestApiNotificationTokenDataSource(
        ref.watch(authenticatedDioProvider),
      ),
    );

final notificationTokenRepositoryProvider =
    Provider<NotificationTokenRepository>(
      (ref) => NotificationTokenRepositoryImpl(
        ref.watch(notificationTokenDataSourceProvider),
      ),
    );

final firebaseMessagingGatewayProvider = Provider<FirebaseMessagingGateway>(
  (ref) => DefaultFirebaseMessagingGateway(),
);

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => DefaultLocalNotificationService(),
);

final notificationReceptionCoordinatorProvider =
    Provider<NotificationReceptionCoordinator>((ref) {
      final coordinator = NotificationReceptionCoordinator(
        ref.watch(firebaseMessagingGatewayProvider),
        ref.watch(localNotificationServiceProvider),
        () => ref.read(appRouterProvider).go(AppRoutes.alerts),
      );
      ref.onDispose(coordinator.dispose);
      return coordinator;
    });

final notificationReceptionBootstrapProvider = Provider<void>((ref) {
  unawaited(ref.watch(notificationReceptionCoordinatorProvider).initialize());
});

final notificationRegistrationStorageProvider =
    Provider<NotificationRegistrationStorage>(
      (ref) => SecureNotificationRegistrationStorage(),
    );

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    ref.watch(firebaseMessagingGatewayProvider),
    ref.watch(notificationTokenRepositoryProvider),
    ref.watch(notificationRegistrationStorageProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final notificationSessionCoordinatorProvider =
    Provider<NotificationSessionCoordinator>(
      (ref) => DefaultNotificationSessionCoordinator(
        () => ref.read(pushNotificationServiceProvider),
      ),
    );
