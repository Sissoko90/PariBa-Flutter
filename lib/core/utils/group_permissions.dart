/// Utilitaire pour gérer les permissions dans les groupes de tontine
///
/// Structure des rôles :
/// - ADMIN : Créateur du groupe, tous les droits
/// - MEMBER : Membre simple, droits limités
class GroupPermissions {
  /// Vérifie si l'utilisateur est administrateur du groupe
  static bool isAdmin(String? currentUserRole) {
    return currentUserRole == 'ADMIN';
  }

  /// Vérifie si l'utilisateur est un membre simple
  static bool isMember(String? currentUserRole) {
    return currentUserRole == 'MEMBER';
  }

  /// Vérifie si l'utilisateur peut modifier le groupe
  /// Seuls les ADMIN peuvent modifier
  static bool canEditGroup(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut supprimer le groupe
  /// Seuls les ADMIN peuvent supprimer
  static bool canDeleteGroup(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut inviter des membres
  /// Seuls les ADMIN peuvent inviter
  static bool canInviteMembers(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut voir les invitations du groupe
  /// Seuls les ADMIN peuvent voir les invitations
  static bool canViewInvitations(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut gérer les membres (retirer, changer rôle)
  /// Seuls les ADMIN peuvent gérer les membres
  static bool canManageMembers(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut démarrer un tour
  /// Seuls les ADMIN peuvent démarrer un tour
  static bool canStartTour(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut voir les détails du groupe
  /// Tous les membres peuvent voir les détails
  static bool canViewGroupDetails(String? currentUserRole) {
    return currentUserRole != null;
  }

  /// Vérifie si l'utilisateur peut voir les membres du groupe
  /// Tous les membres peuvent voir la liste des membres
  static bool canViewMembers(String? currentUserRole) {
    return currentUserRole != null;
  }

  /// Vérifie si l'utilisateur peut quitter le groupe
  /// Tous les membres peuvent quitter (avec conditions côté backend)
  static bool canLeaveGroup(String? currentUserRole) {
    return currentUserRole != null;
  }

  /// Vérifie si l'utilisateur peut voir les contributions
  /// Tous les membres peuvent voir les contributions
  static bool canViewContributions(String? currentUserRole) {
    return currentUserRole != null;
  }

  /// Vérifie si l'utilisateur peut effectuer un paiement
  /// Tous les membres peuvent payer leurs contributions
  static bool canMakePayment(String? currentUserRole) {
    return currentUserRole != null;
  }

  /// Vérifie si l'utilisateur peut valider les paiements
  /// Seuls les ADMIN peuvent valider les paiements
  static bool canValidatePayments(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Vérifie si l'utilisateur peut voir les paiements en attente
  /// Seuls les ADMIN peuvent voir les paiements en attente de validation
  static bool canViewPendingPayments(String? currentUserRole) {
    return isAdmin(currentUserRole);
  }

  /// Retourne le libellé du rôle
  static String getRoleLabel(String? role) {
    switch (role) {
      case 'ADMIN':
        return 'Administrateur';
      case 'MEMBER':
        return 'Membre';
      default:
        return 'Inconnu';
    }
  }

  /// Retourne une description des permissions du rôle
  static String getRoleDescription(String? role) {
    switch (role) {
      case 'ADMIN':
        return 'Tous les droits : modifier, supprimer, inviter, gérer les membres';
      case 'MEMBER':
        return 'Droits limités : voir les infos, payer les contributions, quitter le groupe';
      default:
        return 'Aucune permission';
    }
  }
}
