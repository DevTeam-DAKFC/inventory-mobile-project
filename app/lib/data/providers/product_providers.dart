import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/public_asset_url_resolver.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/product_image_picker.dart';
import '../datasources/rest/rest_api_product_data_source.dart';
import '../repositories/product_repository_impl.dart';
import '../services/image_picker_product_image_picker.dart';
import 'health_providers.dart';

final productDataSourceProvider = Provider<RestApiProductDataSource>(
  (ref) => RestApiProductDataSource(ref.watch(apiClientProvider).dio),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productDataSourceProvider)),
);

final productImagePickerProvider = Provider<ProductImagePicker>(
  (ref) => ImagePickerProductImagePicker(),
);

final publicAssetUrlResolverProvider = Provider<PublicAssetUrlResolver>(
  (ref) => PublicAssetUrlResolver(ref.watch(apiConfigProvider)),
);
