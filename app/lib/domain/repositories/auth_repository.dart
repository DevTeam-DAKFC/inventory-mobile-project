import '../../core/result/app_result.dart';
import '../models/app_user.dart';

/// Contract for authenticating a user against the inventory backend.
///
/// Implementations live in `data/repositories/` and must convert raw
/// infrastructure failures into [AppResult] failures using the shared
/// `AppException` taxonomy. Implementations are also responsible for
/// persisting the access token via the shared token storage so that the
/// REST layer can attach it to subsequent requests.
abstract class AuthRepository {
  Future<AppResult<AppUser>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppResult<AppUser>> login({
    required String email,
    required String password,
  });

  Future<AppResult<AppUser>> currentUser();

  Future<AppResult<void>> logout();
}
