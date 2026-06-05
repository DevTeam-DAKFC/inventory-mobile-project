import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/constants/api_config.dart';
import 'package:inventory_mobile/core/network/public_asset_url_resolver.dart';

void main() {
  const resolver = PublicAssetUrlResolver(
    ApiConfig(baseUrl: 'http://10.0.2.2:5225'),
  );

  test('resolves a backend-relative image path', () {
    expect(
      resolver.resolve('/uploads/products/product-1.jpg'),
      'http://10.0.2.2:5225/uploads/products/product-1.jpg',
    );
  });

  test('preserves absolute external URLs', () {
    const external = 'https://cdn.example.com/product.jpg';

    expect(resolver.resolve(external), external);
  });

  test('returns null for null imageUrl', () {
    expect(resolver.resolve(null), isNull);
  });

  test('avoids duplicate slashes', () {
    const trailingSlashResolver = PublicAssetUrlResolver(
      ApiConfig(baseUrl: 'http://localhost:5225/'),
    );

    expect(
      trailingSlashResolver.resolve('/uploads/product.jpg'),
      'http://localhost:5225/uploads/product.jpg',
    );
  });
}
