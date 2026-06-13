import '../errors/app_exception.dart';

/// Controlled result type returned by repositories and use cases.
///
/// Either carries a successful value of [T] or an [AppException] describing
/// a domain or infrastructure failure that the upper layers can render.
sealed class AppResult<T> {
  const AppResult();

  bool get isSuccess => this is AppSuccess<T>;

  bool get isFailure => this is AppFailure<T>;

  T? get dataOrNull => switch (this) {
    AppSuccess<T>(:final data) => data,
    AppFailure<T>() => null,
  };

  AppException? get exceptionOrNull => switch (this) {
    AppSuccess<T>() => null,
    AppFailure<T>(:final exception) => exception,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) => switch (this) {
    AppSuccess<T>(:final data) => success(data),
    AppFailure<T>(:final exception) => failure(exception),
  };
}

final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);

  final T data;
}

final class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.exception);

  final AppException exception;
}
