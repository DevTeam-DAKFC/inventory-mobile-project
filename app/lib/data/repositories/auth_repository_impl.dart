import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../core/storage/auth_token_storage.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/rest/rest_api_auth_data_source.dart';
import '../dto/auth_rest_dto.dart';
import '../mappers/auth_user_mapper.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this._dataSource,
    required this._tokenStorage,
    this._now = DateTime.now,
  });

  final RestApiAuthDataSource _dataSource;
  final AuthTokenStorage _tokenStorage;
  final DateTime Function() _now;

  @override
  Future<AppResult<AppUser>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuth(
      () => _dataSource.register(
        AuthRegisterRequestDto(name: name, email: email, password: password),
      ),
      failureMessage: 'Unexpected error during registration.',
    );
  }

  @override
  Future<AppResult<AppUser>> login({required String email, required String password}) async {
    return _runAuth(
      () => _dataSource.login(AuthLoginRequestDto(email: email, password: password)),
      failureMessage: 'Unexpected error during login.',
    );
  }

  @override
  Future<AppResult<AppUser>> currentUser() async {
    try {
      final dto = await _dataSource.me();
      return AppSuccess(AuthUserMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error fetching current user.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<void>> logout() async {
    try {
      await _dataSource.logout();
    } on AppException catch (e) {
      await _tokenStorage.clear();
      return AppFailure<void>(e);
    } catch (e, stack) {
      await _tokenStorage.clear();
      return AppFailure<void>(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error during logout.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
    await _tokenStorage.clear();
    return const AppSuccess<void>(null);
  }

  Future<AppResult<AppUser>> _runAuth(
    Future<AuthLoginResponseDto> Function() call, {
    required String failureMessage,
  }) async {
    try {
      final dto = await call();
      await _tokenStorage.saveToken(
        StoredAuthToken(
          accessToken: dto.accessToken,
          expiresAt: _now().toUtc().add(Duration(seconds: dto.expiresIn)),
        ),
      );
      return AppSuccess(AuthUserMapper.toDomain(dto.user));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: failureMessage,
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
