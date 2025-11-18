import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/contribution.dart';

/// Contribution Repository Contract
abstract class ContributionRepository {
  /// Get contributions for a group
  Future<Either<Failure, List<Contribution>>> getContributionsByGroup(
    String groupId,
  );

  /// Get contributions for a member
  Future<Either<Failure, List<Contribution>>> getContributionsByMember(
    String groupId,
    String personId,
  );

  /// Get contribution by ID
  Future<Either<Failure, Contribution>> getContributionById(
    String contributionId,
  );

  /// Get pending contributions
  Future<Either<Failure, List<Contribution>>> getPendingContributions(
    String groupId,
  );

  /// Pay contribution
  Future<Either<Failure, void>> payContribution({
    required String contributionId,
    required String paymentType,
    required double amount,
  });
}
