import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/payment_history_item.dart';
import '../../../data/datasources/remote/payment_remote_datasource.dart';
import '../../../data/models/payment_history_model.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// BLoC pour gérer les paiements
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;
  final PaymentRemoteDataSource? _paymentRemoteDataSource;

  PaymentBloc({
    required PaymentService paymentService,
    PaymentRemoteDataSource? paymentRemoteDataSource,
  }) : _paymentService = paymentService,
       _paymentRemoteDataSource = paymentRemoteDataSource,
       super(PaymentInitial()) {
    on<DeclarePaymentEvent>(_onDeclarePayment);
    on<ValidatePaymentEvent>(_onValidatePayment);
    on<LoadGroupPaymentsEvent>(_onLoadGroupPayments);
    on<LoadPendingPaymentsEvent>(_onLoadPendingPayments);
    on<LoadMyPaymentsEvent>(_onLoadMyPayments);
    // Dans payment_bloc.dart, dans le handler de LoadPaymentHistoryEvent :
    on<LoadPaymentHistoryEvent>((event, emit) async {
      emit(PaymentsLoading());
      try {
        // ← Changer getGroupPayments par getPaymentHistory
        final result = await _paymentService.getPaymentHistory(event.groupId);

        print('📊 PaymentBloc - Résultat historique: ${result['success']}');
        print('📊 PaymentBloc - Data: ${result['data']}');

        if (result['success'] == true) {
          final List<dynamic> data = result['data'] ?? [];
          if (data.isEmpty) {
            emit(PaymentsEmpty('Aucun historique de paiement'));
          } else {
            // PaymentHistoryLoaded attend des objets différents de PaymentHistoryResponse
            emit(
              PaymentHistoryLoaded(
                data.map((json) => PaymentHistoryItem.fromJson(json)).toList(),
              ),
            );
          }
        } else {
          emit(PaymentError(result['message'] ?? 'Erreur'));
        }
      } catch (e) {
        emit(PaymentError('Erreur: $e'));
      }
    });
  }

  /// Gérer la déclaration d'un paiement
  Future<void> _onDeclarePayment(
    DeclarePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final result = await _paymentService.declarePayment(
        groupId: event.groupId,
        amount: event.amount,
        paymentType: event.paymentType,
        transactionRef: event.transactionRef,
        notes: event.notes,
      );

      print('📊 PaymentBloc - Résultat déclaration: ${result['success']}');

      if (result['success'] == true) {
        // Convertir les données en entité Payment si disponible
        Payment? payment;
        if (result['data'] != null) {
          final data = result['data'] as Map<String, dynamic>;
          payment = Payment.fromJson(data);
        }

        emit(
          PaymentSuccess(
            result['message'] ?? 'Paiement déclaré avec succès',
            payment: payment,
          ),
        );
      } else {
        emit(
          PaymentError(result['message'] ?? 'Erreur lors de la déclaration'),
        );
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur déclaration: $e');
      emit(PaymentError('Erreur: $e'));
    }
  }

  /// Gérer la validation d'un paiement (admin)
  Future<void> _onValidatePayment(
    ValidatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final result = await _paymentService.validatePayment(
        paymentId: event.paymentId,
        confirmed: event.confirmed,
        notes: event.notes,
      );

      print('📊 PaymentBloc - Résultat validation: ${result['success']}');

      if (result['success'] == true) {
        Payment? payment;
        if (result['data'] != null) {
          final data = result['data'] as Map<String, dynamic>;
          payment = Payment.fromJson(data);
        }

        emit(
          PaymentValidated(
            result['message'] ??
                (event.confirmed
                    ? 'Paiement validé avec succès'
                    : 'Paiement rejeté'),
            payment:
                payment ??
                Payment(
                  id: event.paymentId,
                  amount: 0,
                  paymentType: 'UNKNOWN',
                  status: event.confirmed ? 'CONFIRMED' : 'REJECTED',
                  createdAt: DateTime.now(),
                  validatedAt: DateTime.now(),
                ),
          ),
        );
      } else {
        emit(PaymentError(result['message'] ?? 'Erreur lors de la validation'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur validation: $e');
      emit(PaymentError('Erreur de validation: $e'));
    }
  }

  /// Charger les paiements d'un groupe
  Future<void> _onLoadGroupPayments(
    LoadGroupPaymentsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoading());

    try {
      final result = await _paymentService.getGroupPayments(event.groupId);

      print(
        '📊 PaymentBloc - Résultat chargement groupe: ${result['success']}',
      );

      if (result['success'] == true) {
        final List<Payment> payments = [];
        if (result['data'] != null) {
          final List<dynamic> dataList = result['data'] as List<dynamic>;
          payments.addAll(
            dataList.map(
              (data) => Payment.fromJson(data as Map<String, dynamic>),
            ),
          );
        }

        if (payments.isEmpty) {
          emit(PaymentsEmpty('Aucun paiement dans ce groupe'));
        } else {
          emit(PaymentsLoaded(payments: payments));
        }
      } else {
        emit(PaymentError(result['message'] ?? 'Erreur de chargement'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur chargement groupe: $e');
      emit(PaymentError('Erreur de chargement: $e'));
    }
  }

  /// Charger les paiements en attente (admin)
  Future<void> _onLoadPendingPayments(
    LoadPendingPaymentsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoading());

    try {
      final result = await _paymentService.getPendingPayments(event.groupId);

      print(
        '📊 PaymentBloc - Résultat chargement en attente: ${result['success']}',
      );

      if (result['success'] == true) {
        final List<Payment> pendingPayments = [];
        final List<Payment> allPayments = [];

        if (result['data'] != null) {
          final List<dynamic> dataList = result['data'] as List<dynamic>;
          for (var data in dataList) {
            final payment = Payment.fromJson(data as Map<String, dynamic>);
            allPayments.add(payment);
            if (payment.isPending) {
              pendingPayments.add(payment);
            }
          }
        }

        if (pendingPayments.isEmpty) {
          emit(PaymentsEmpty('Aucun paiement en attente'));
        } else {
          emit(
            PaymentsLoaded(
              payments: allPayments,
              pendingPayments: pendingPayments,
            ),
          );
        }
      } else {
        emit(PaymentError(result['message'] ?? 'Erreur de chargement'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur chargement en attente: $e');
      emit(PaymentError('Erreur de chargement: $e'));
    }
  }

  /// Charger les paiements personnels
  Future<void> _onLoadMyPayments(
    LoadMyPaymentsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoading());

    try {
      final result = await _paymentService.getMyPayments();

      print(
        '📊 PaymentBloc - Résultat chargement mes paiements: ${result['success']}',
      );

      if (result['success'] == true) {
        final List<Payment> payments = [];
        if (result['data'] != null) {
          final List<dynamic> dataList = result['data'] as List<dynamic>;
          payments.addAll(
            dataList.map(
              (data) => Payment.fromJson(data as Map<String, dynamic>),
            ),
          );
        }

        if (payments.isEmpty) {
          emit(PaymentsEmpty('Aucun paiement trouvé'));
        } else {
          emit(PaymentsLoaded(payments: payments));
        }
      } else {
        emit(PaymentError(result['message'] ?? 'Erreur de chargement'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur chargement mes paiements: $e');
      emit(PaymentError('Erreur de chargement: $e'));
    }
  }

  /// Charger l'historique des paiements d'un groupe
  // Dans payment_bloc.dart - CORRIGÉ

  /// Charger l'historique des paiements d'un groupe
  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoading());

    try {
      // Utiliser PaymentService au lieu de PaymentRemoteDataSource
      final result = await _paymentService.getPaymentHistory(event.groupId);

      print('📊 PaymentBloc - Résultat historique: ${result['success']}');
      print('📊 PaymentBloc - Data: ${result['data']}');

      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        if (data.isEmpty) {
          emit(PaymentsEmpty('Aucun historique de paiement'));
        } else {
          // Convertir directement en PaymentHistoryItem
          final history = data
              .map(
                (json) =>
                    PaymentHistoryItem.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          emit(PaymentHistoryLoaded(history));
        }
      } else {
        emit(PaymentError(result['message'] ?? 'Erreur de chargement'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Erreur chargement historique: $e');
      emit(PaymentError('Erreur de chargement de l\'historique: $e'));
    }
  }
}
