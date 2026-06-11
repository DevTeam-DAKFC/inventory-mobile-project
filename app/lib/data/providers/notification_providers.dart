import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/notification_token_repository.dart';
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
