import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/remote/contribution_remote_datasource.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final ContributionRemoteDataSource remoteDataSource;

  ContributionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Contribution>> getContributionsByGroup(String groupId) async {
    try {
      final models = await remoteDataSource.getContributionsByGroup(groupId);
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des contributions: $e');
    }
  }

  @override
  Future<List<Contribution>> getContributionsByTour(String tourId) async {
    try {
      final models = await remoteDataSource.getContributionsByTour(tourId);
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des contributions: $e');
    }
  }

  @override
  Future<List<Contribution>> getContributionsByMember(String memberId) async {
    try {
      final models = await remoteDataSource.getContributionsByMember(memberId);
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des contributions: $e');
    }
  }

  @override
  Future<Contribution> getContributionById(String contributionId) async {
    try {
      final model = await remoteDataSource.getContributionById(contributionId);
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la contribution: $e');
    }
  }

  @override
  Future<List<Contribution>> getPendingContributions(String groupId) async {
    try {
      final models = await remoteDataSource.getPendingContributions(groupId);
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des contributions: $e');
    }
  }

  Contribution _modelToEntity(dynamic model) {
    return Contribution(
      id: model.id,
      createdAt: model.createdAt,
      tourId: model.tourId,
      tourIndex: model.tourIndex,
      amountDue: model.amountDue,
      status: model.status,
      dueDate: model.dueDate,
      penaltyApplied: model.penaltyApplied,
      memberName: model.memberName,
      memberPersonId: model.memberPersonId,
    );
  }
}
