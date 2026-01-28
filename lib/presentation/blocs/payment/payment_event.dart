// presentation/blocs/payment/payment_event.dart

import 'package:equatable/equatable.dart';

/// Événements pour le BLoC de paiement
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour déclarer un paiement
class DeclarePaymentEvent extends PaymentEvent {
  final String groupId;
  final double amount;
  final String paymentType;
  final String? transactionRef;
  final String? notes;

  const DeclarePaymentEvent({
    required this.groupId,
    required this.amount,
    required this.paymentType,
    this.transactionRef,
    this.notes,
  });

  @override
  List<Object?> get props => [
    groupId,
    amount,
    paymentType,
    transactionRef,
    notes,
  ];
}

/// Événement pour valider un paiement (admin)
class ValidatePaymentEvent extends PaymentEvent {
  final String paymentId;
  final bool confirmed;
  final String? notes;

  const ValidatePaymentEvent({
    required this.paymentId,
    required this.confirmed,
    this.notes,
  });

  @override
  List<Object?> get props => [paymentId, confirmed, notes];
}

/// Événement pour charger les paiements d'un groupe
class LoadGroupPaymentsEvent extends PaymentEvent {
  final String groupId;

  const LoadGroupPaymentsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Événement pour charger les paiements en attente (admin)
class LoadPendingPaymentsEvent extends PaymentEvent {
  final String groupId;

  const LoadPendingPaymentsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Événement pour charger les paiements personnels
class LoadMyPaymentsEvent extends PaymentEvent {
  const LoadMyPaymentsEvent();
}
