import '../constants/app_constants.dart';

/// Input Validators
class Validators {
  Validators._();

  /// Validate email (optionnel)
  static String? email(String? value) {
    // Email est optionnel
    if (value == null || value.isEmpty) {
      return null; // Pas d'erreur si vide
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'L\'adresse email n\'est pas valide';
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro invalide. Format: +223XXXXXXXX';
    }

    return null;
  }

  /// Validate password (aligné avec backend: min 8 caractères)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe ne doit pas dépasser ${AppConstants.maxPasswordLength} caractères';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }

  /// Validate OTP code
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code OTP est requis';
    }

    if (value.length != AppConstants.otpLength) {
      return 'Le code doit contenir ${AppConstants.otpLength} chiffres';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le code doit contenir uniquement des chiffres';
    }

    return null;
  }

  /// Validate amount
  static String? amount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }

    if (min != null && amount < min) {
      return 'Le montant minimum est $min ${AppConstants.currency}';
    }

    if (max != null && amount > max) {
      return 'Le montant maximum est $max ${AppConstants.currency}';
    }

    return null;
  }

  /// Validate name (aligné avec backend: 2-50 caractères)
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Le nom'} est requis';
    }

    if (value.length < 2) {
      return '${fieldName ?? 'Le nom'} doit contenir au moins 2 caractères';
    }

    if (value.length > 50) {
      return '${fieldName ?? 'Le nom'} ne doit pas dépasser 50 caractères';
    }

    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(value)) {
      return '${fieldName ?? 'Le nom'} contient des caractères invalides';
    }

    return null;
  }
}
