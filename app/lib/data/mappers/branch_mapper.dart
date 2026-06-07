import '../../domain/models/branch.dart';
import '../dto/branch_rest_dto.dart';

final class BranchMapper {
  const BranchMapper._();

  static Branch toDomain(BranchRestDto dto) => Branch(
    id: dto.id,
    name: dto.name,
    address: dto.address,
    isActive: dto.isActive,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}
