// presentation/blocs/payment/payment_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../data/models/payment_history_model.dart';

/// États pour le BLoC de paiement
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// État initial
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// État de chargement
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// État de chargement des paiements
class PaymentsLoading extends PaymentState {
  const PaymentsLoading();
}

/// État de chargement réussi des paiements
class PaymentsLoaded extends PaymentState {
  final List<Payment> payments;
  final List<Payment> pendingPayments; // Pour l'admin

  const PaymentsLoaded({
    required this.payments,
    this.pendingPayments = const [],
  });

  @override
  List<Object?> get props => [payments, pendingPayments];
}

/// État de paiement déclaré avec succès
class PaymentSuccess extends PaymentState {
  final String message;
  final Payment? payment; // Le paiement créé

  const PaymentSuccess(this.message, {this.payment});

  @override
  List<Object?> get props => [message, payment];
}

/// État de paiement validé avec succès
class PaymentValidated extends PaymentState {
  final String message;
  final Payment payment;

  const PaymentValidated(this.message, {required this.payment});

  @override
  List<Object?> get props => [message, payment];
}

/// État d'erreur
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// État vide (pas de paiements)
class PaymentsEmpty extends PaymentState {
  final String message;

  const PaymentsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// État de l'historique des paiements chargé
class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentHistoryModel> history;

  const PaymentHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}
