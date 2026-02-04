import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/payment.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// BLoC pour gérer les paiements
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;

  PaymentBloc({required PaymentService paymentService})
    : _paymentService = paymentService,
      super(PaymentInitial()) {
    on<DeclarePaymentEvent>(_onDeclarePayment);
    on<ValidatePaymentEvent>(_onValidatePayment);
    on<LoadGroupPaymentsEvent>(_onLoadGroupPayments);
    on<LoadPendingPaymentsEvent>(_onLoadPendingPayments);
    on<LoadMyPaymentsEvent>(_onLoadMyPayments);
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
  /// Dans _onLoadPendingPayments method:
  Future<void> _onLoadPendingPayments(
    LoadPendingPaymentsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoading());
    print(
      '🔄 PaymentBloc - Chargement paiements en attente pour groupe: ${event.groupId}',
    );

    try {
      final result = await _paymentService.getPendingPayments(event.groupId);

      print('📊 PaymentBloc - Résultat API: ${result['success']}');
      print('📊 PaymentBloc - Message: ${result['message']}');
      print('📊 PaymentBloc - Données brutes: ${result['data']}');

      if (result['success'] == true) {
        final List<Payment> pendingPayments = [];
        final List<Payment> allPayments = [];

        if (result['data'] != null) {
          final List<dynamic> dataList = result['data'] as List<dynamic>;
          print(
            '📊 PaymentBloc - Nombre d\'éléments reçus: ${dataList.length}',
          );

          for (var i = 0; i < dataList.length; i++) {
            final data = dataList[i] as Map<String, dynamic>;
            print('📊 PaymentBloc - Élément $i: $data');

            try {
              final payment = Payment.fromJson(data);
              print(
                '📊 PaymentBloc - Payment créé: ${payment.id}, ${payment.payerName}, ${payment.status}',
              );
              allPayments.add(payment);
              if (payment.isPending) {
                pendingPayments.add(payment);
              }
            } catch (e) {
              print('❌ PaymentBloc - Erreur création payment: $e');
            }
          }
        }

        print('📊 PaymentBloc - Total payments: ${allPayments.length}');
        print('📊 PaymentBloc - Pending payments: ${pendingPayments.length}');

        if (pendingPayments.isEmpty) {
          print(
            '📊 PaymentBloc - Aucun paiement en attente, emission PaymentsEmpty',
          );
          emit(PaymentsEmpty('Aucun paiement en attente'));
        } else {
          print(
            '📊 PaymentBloc - Emission PaymentsLoaded avec ${pendingPayments.length} paiements en attente',
          );
          emit(
            PaymentsLoaded(
              payments: allPayments,
              pendingPayments: pendingPayments,
            ),
          );
        }
      } else {
        print('❌ PaymentBloc - Erreur API: ${result['message']}');
        emit(PaymentError(result['message'] ?? 'Erreur de chargement'));
      }
    } catch (e) {
      print('❌ PaymentBloc - Exception: $e');
      print('❌ PaymentBloc - StackTrace: ${e.toString()}');
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
}
