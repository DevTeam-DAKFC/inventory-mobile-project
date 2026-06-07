import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_branch_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _response(String path, dynamic data, {int statusCode = 200}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

DioException _badResponse(String path, int statusCode, dynamic data) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, dynamic> _branchJson({
  String id = 'branch-id',
  bool isActive = true,
}) => {
  'id': id,
  'name': 'Central Branch',
  'address': 'Main street',
  'isActive': isActive,
  'createdAt': '2026-06-05T20:00:00Z',
  'updatedAt': null,
};

void main() {
  late _MockDio dio;
  late RestApiBranchDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiBranchDataSource(dio);
  });

  group('getBranches', () {
    test('loads branches from direct list response', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenAnswer((_) async => _response('/branches', [_branchJson()]));

      final dto = await sut.getBranches();

      expect(dto, hasLength(1));
      expect(dto.single.name, 'Central Branch');
      verify(() => dio.get<dynamic>('/branches')).called(1);
    });

    test('maps backend failures', () async {
      when(() => dio.get<dynamic>('/branches')).thenThrow(
        _badResponse('/branches', 401, {
          'code': 'unauthorized',
          'message': 'Unauthorized.',
        }),
      );

      await expectLater(
        sut.getBranches(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });

    test('throws AppException when payload is not a list', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenAnswer((_) async => _response('/branches', {'items': []}));

      await expectLater(sut.getBranches(), throwsA(isA<AppException>()));
    });
  });
}
