import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tontine_group.dart';
import '../../repositories/group_repository.dart';

/// Get Groups UseCase
class GetGroupsUseCase {
  final GroupRepository repository;

  GetGroupsUseCase(this.repository);

  Future<Either<Failure, List<TontineGroup>>> call() async {
    return await repository.getGroups();
  }
}
