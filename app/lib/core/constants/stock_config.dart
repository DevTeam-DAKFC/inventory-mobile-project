/// Temporary branch selection used until the Branches module exposes a real
/// selector/repository for the mobile app.
final class StockConfig {
  const StockConfig._();

  static const developmentBranchId = '10000000-0000-0000-0000-000000000001';
  static const developmentBranchName = 'Central Branch';

  static const defaultDevelopmentBranch = StockBranchOption(
    id: developmentBranchId,
    name: developmentBranchName,
  );

  /// Development seed branches used by Stock Overview until a Branch API or
  /// shared Branch selector is available in mobile.
  static const developmentBranches = <StockBranchOption>[
    defaultDevelopmentBranch,
    StockBranchOption(
      id: '10000000-0000-0000-0000-000000000002',
      name: 'Warehouse Branch',
    ),
  ];

  static StockBranchOption developmentBranchById(String branchId) {
    return developmentBranches.firstWhere(
      (branch) => branch.id == branchId,
      orElse: () => defaultDevelopmentBranch,
    );
  }
}

final class StockBranchOption {
  const StockBranchOption({required this.id, required this.name});

  final String id;
  final String name;
}
