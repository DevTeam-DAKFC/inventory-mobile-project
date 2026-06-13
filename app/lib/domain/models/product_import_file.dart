/// CSV file selected by the user for backend-side product import.
final class ProductImportFile {
  const ProductImportFile({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}
