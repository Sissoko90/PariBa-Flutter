import '../entities/contribution.dart';

/// Contribution Repository Contract
abstract class ContributionRepository {
  /// Get contributions for a group
  Future<List<Contribution>> getContributionsByGroup(String groupId);

  /// Get contributions for a tour
  Future<List<Contribution>> getContributionsByTour(String tourId);

  /// Get contributions for a member
  Future<List<Contribution>> getContributionsByMember(String memberId);

  /// Get contribution by ID
  Future<Contribution> getContributionById(String contributionId);

  /// Get pending contributions
  Future<List<Contribution>> getPendingContributions(String groupId);
}
