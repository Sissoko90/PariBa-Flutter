/// Service pour traduire les erreurs techniques du backend en messages conviviaux
class ErrorMessageMapper {
  ErrorMessageMapper._();

  /// Traduit un message d'erreur technique en message convivial
  static String mapErrorMessage(String technicalMessage) {
    final lowerMessage = technicalMessage.toLowerCase();

    // Erreurs de validation des champs
    if (lowerMessage.contains('prenom') || lowerMessage.contains('prénom')) {
      if (lowerMessage.contains('requis') ||
          lowerMessage.contains('required')) {
        return 'Le prénom est obligatoire';
      }
      if (lowerMessage.contains('size') || lowerMessage.contains('taille')) {
        return 'Le prénom doit contenir entre 2 et 50 caractères';
      }
    }

    if (lowerMessage.contains('nom')) {
      if (lowerMessage.contains('requis') ||
          lowerMessage.contains('required')) {
        return 'Le nom est obligatoire';
      }
      if (lowerMessage.contains('size') || lowerMessage.contains('taille')) {
        return 'Le nom doit contenir entre 2 et 50 caractères';
      }
    }

    if (lowerMessage.contains('email')) {
      if (lowerMessage.contains('invalid') ||
          lowerMessage.contains('invalide')) {
        return 'L\'adresse email n\'est pas valide';
      }
      if (lowerMessage.contains('déjà') ||
          lowerMessage.contains('already') ||
          lowerMessage.contains('existe')) {
        return 'Cette adresse email est déjà utilisée';
      }
    }

    if (lowerMessage.contains('phone') || lowerMessage.contains('téléphone')) {
      if (lowerMessage.contains('requis') ||
          lowerMessage.contains('required')) {
        return 'Le numéro de téléphone est obligatoire';
      }
      if (lowerMessage.contains('invalid') ||
          lowerMessage.contains('invalide')) {
        return 'Le numéro de téléphone n\'est pas valide. Format attendu: +223XXXXXXXX';
      }
      if (lowerMessage.contains('déjà') ||
          lowerMessage.contains('already') ||
          lowerMessage.contains('existe')) {
        return 'Ce numéro de téléphone est déjà utilisé';
      }
    }

    if (lowerMessage.contains('password') ||
        lowerMessage.contains('mot de passe')) {
      if (lowerMessage.contains('requis') ||
          lowerMessage.contains('required')) {
        return 'Le mot de passe est obligatoire';
      }
      if (lowerMessage.contains('4 chiffres') || lowerMessage.contains('8')) {
        return 'Le mot de passe doit contenir au moins 8 caractères';
      }
      if (lowerMessage.contains('incorrect') ||
          lowerMessage.contains('wrong')) {
        return 'Le mot de passe est incorrect';
      }
    }

    // Erreurs d'authentification
    if (lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('non autorisé')) {
      return 'Vous n\'êtes pas autorisé à effectuer cette action';
    }

    if (lowerMessage.contains('credentials') ||
        lowerMessage.contains('identifiants')) {
      return 'Identifiants incorrects. Vérifiez votre email/téléphone et mot de passe';
    }

    // Erreurs de connexion réseau
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('réseau') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('connexion')) {
      return 'Problème de connexion. Vérifiez votre connexion internet';
    }

    if (lowerMessage.contains('timeout') || lowerMessage.contains('délai')) {
      return 'La requête a pris trop de temps. Veuillez réessayer';
    }

    // Erreurs serveur
    if (lowerMessage.contains('500') ||
        lowerMessage.contains('internal server')) {
      return 'Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard';
    }

    if (lowerMessage.contains('503') || lowerMessage.contains('unavailable')) {
      return 'Le service est temporairement indisponible. Veuillez réessayer plus tard';
    }

    // Erreurs de conflit
    if (lowerMessage.contains('409') ||
        lowerMessage.contains('conflict') ||
        lowerMessage.contains('existe déjà') ||
        lowerMessage.contains('already exists')) {
      return 'Un compte avec ces informations existe déjà';
    }

    // Erreurs de validation générale
    if (lowerMessage.contains('validation') ||
        lowerMessage.contains('invalid')) {
      return 'Les informations fournies ne sont pas valides. Vérifiez vos données';
    }

    // Erreurs 404
    if (lowerMessage.contains('404') || lowerMessage.contains('not found')) {
      return 'La ressource demandée n\'a pas été trouvée';
    }

    // Erreurs de token
    if (lowerMessage.contains('token') &&
        (lowerMessage.contains('expired') || lowerMessage.contains('expiré'))) {
      return 'Votre session a expiré. Veuillez vous reconnecter';
    }

    // Erreurs spécifiques d'inscription
    if (lowerMessage.contains('cet utilisateur existe déjà')) {
      return 'Un compte avec cet email ou ce numéro de téléphone existe déjà';
    }

    // Si aucune correspondance, retourner un message générique convivial
    // mais éviter de montrer les détails techniques
    if (lowerMessage.contains('exception') ||
        lowerMessage.contains('error') ||
        lowerMessage.contains('failed')) {
      return 'Une erreur s\'est produite. Veuillez vérifier vos informations et réessayer';
    }

    // Dernier recours : retourner le message original s'il est déjà convivial
    // (pas de termes techniques)
    if (!_containsTechnicalTerms(lowerMessage)) {
      return technicalMessage;
    }

    return 'Une erreur s\'est produite. Veuillez réessayer';
  }

  /// Vérifie si le message contient des termes techniques
  static bool _containsTechnicalTerms(String message) {
    final technicalTerms = [
      'exception',
      'null',
      'undefined',
      'stack',
      'trace',
      'http',
      'dio',
      'response',
      'request',
      'status code',
      'json',
      'parse',
      'serialize',
    ];

    return technicalTerms.any((term) => message.contains(term));
  }

  /// Extrait un message d'erreur convivial depuis une réponse API
  static String extractFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Une erreur inconnue s\'est produite';
    }

    String message = error.toString();

    // Si c'est déjà un message convivial, le retourner
    if (!_containsTechnicalTerms(message.toLowerCase())) {
      return message;
    }

    // Sinon, le mapper
    return mapErrorMessage(message);
  }
}
