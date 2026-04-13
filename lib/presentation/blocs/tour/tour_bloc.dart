import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/tour_remote_datasource.dart';
import '../../../data/models/tour_model.dart';
import 'tour_event.dart';
import 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final TourRemoteDataSource tourRemoteDataSource;

  TourBloc({required this.tourRemoteDataSource}) : super(TourInitial()) {
    on<LoadNextTourEvent>(_onLoadNextTour);
    on<LoadCurrentTourEvent>(_onLoadCurrentTour);
    on<LoadGroupToursEvent>(_onLoadGroupTours);
    on<GenerateToursEvent>(_onGenerateTours);
  }

  Future<void> _onLoadNextTour(
    LoadNextTourEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final tourData = await tourRemoteDataSource.getNextTour(event.groupId);
      final tour = TourModel.fromJson(tourData);
      emit(TourLoaded(tour));
    } catch (e) {
      final errorMessage = _getUserFriendlyMessage(e);
      if (errorMessage.contains('Aucun prochain tour')) {
        emit(TourEmpty(errorMessage));
      } else {
        emit(TourError(errorMessage));
      }
    }
  }

  Future<void> _onLoadCurrentTour(
    LoadCurrentTourEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final tourData = await tourRemoteDataSource.getCurrentTour(event.groupId);
      final tour = TourModel.fromJson(tourData);
      emit(TourLoaded(tour));
    } catch (e) {
      final errorMessage = _getUserFriendlyMessage(e);
      if (errorMessage.contains('Aucun tour en cours')) {
        emit(TourEmpty(errorMessage));
      } else {
        emit(TourError(errorMessage));
      }
    }
  }

  Future<void> _onLoadGroupTours(
    LoadGroupToursEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final toursData = await tourRemoteDataSource.getToursByGroup(
        event.groupId,
      );
      final tours = toursData.map((data) => TourModel.fromJson(data)).toList();
      emit(ToursLoaded(tours));
    } catch (e) {
      final errorMessage = _getUserFriendlyMessage(e);
      emit(TourError(errorMessage));
    }
  }

  Future<void> _onGenerateTours(
    GenerateToursEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      print(
        '🔵 TourBloc - Génération des tours pour le groupe: ${event.groupId}',
      );
      final toursData = await tourRemoteDataSource.generateTours(
        event.groupId,
        event.shuffle,
        customBeneficiaryOrder: event.customBeneficiaryOrder,
      );
      final tours = toursData.map((data) => TourModel.fromJson(data)).toList();
      print('✅ TourBloc - ${tours.length} tours générés avec succès');
      emit(ToursLoaded(tours));
    } catch (e) {
      print('❌ TourBloc - Erreur génération tours: $e');

      // 👇 Extraire le message spécifique de l'API
      final errorMessage = _extractApiErrorMessage(e);
      print('📝 Message extrait: $errorMessage');

      // 👇 Émettre un état d'erreur avec le message user-friendly
      emit(TourError(errorMessage));
    }
  }

  /// Extraire le message d'erreur de l'API à partir de l'exception
  String _extractApiErrorMessage(dynamic error) {
    String errorString = error.toString();

    // Vérifier si c'est une DioException
    if (error is DioException) {
      // Récupérer la réponse du serveur
      if (error.response?.data != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic>) {
          final apiMessage = responseData['message'] as String?;
          if (apiMessage != null && apiMessage.isNotEmpty) {
            return _mapApiMessageToUserFriendly(apiMessage);
          }
        }
      }

      // Message par défaut selon le code HTTP
      if (error.response?.statusCode == 400) {
        return 'Impossible de générer les tours. Vérifiez que le groupe a assez de membres.';
      } else if (error.response?.statusCode == 403) {
        return 'Vous n\'êtes pas autorisé à générer les tours de ce groupe.';
      } else if (error.response?.statusCode == 404) {
        return 'Groupe non trouvé.';
      } else if (error.response?.statusCode == 500) {
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      }
    }

    return _mapApiMessageToUserFriendly(errorString);
  }

  /// Convertir les messages API en messages user-friendly
  String _mapApiMessageToUserFriendly(String message) {
    // Liste des messages d'erreur spécifiques à mapper
    if (message.contains('déjà été générés') ||
        message.contains('already generated')) {
      return '✅ Les tours ont déjà été générés pour ce groupe.';
    }

    if (message.contains('pas assez de membres') ||
        message.contains('not enough members')) {
      return '⚠️ Impossible de générer les tours. Le groupe doit avoir au moins 2 membres.';
    }

    if (message.contains('non trouvé') || message.contains('not found')) {
      return '❌ Groupe introuvable.';
    }

    if (message.contains('non autorisé') || message.contains('unauthorized')) {
      return '🔒 Vous n\'êtes pas autorisé à effectuer cette action.';
    }

    // Si c'est déjà un message user-friendly, le retourner tel quel
    if (message.startsWith('✅') ||
        message.startsWith('⚠️') ||
        message.startsWith('❌') ||
        message.startsWith('🔒')) {
      return message;
    }

    // Message par défaut
    return '❌ Erreur: $message';
  }

  /// Convertir les erreurs génériques en messages user-friendly
  String _getUserFriendlyMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Aucun tour disponible pour ce groupe.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Vous n\'avez pas accès à ce groupe.';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }

    if (errorString.contains('timeout')) {
      return 'La requête a expiré. Vérifiez votre connexion internet.';
    }

    if (errorString.contains('socket')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion.';
    }

    return 'Une erreur est survenue: ${error.toString()}';
  }
}
