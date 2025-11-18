# 📱 Documentation des Pages PariBa

## 🎯 Vue d'ensemble

Cette documentation liste toutes les pages créées pour l'application PariBa avec leurs fonctionnalités.

---

## 🏠 Pages Principales

### 1. **Dashboard Amélioré** (`improved_dashboard_page.dart`)
**Localisation** : `lib/presentation/pages/home/`

**Fonctionnalités** :
- ✅ SliverAppBar avec effet de scroll
- ✅ Carte de bienvenue avec gradient et date
- ✅ 4 statistiques : Groupes, Actifs, Montant total, Paiements en attente
- ✅ 3 actions rapides : Créer, Rejoindre, Paiements
- ✅ Liste des groupes récents avec statut
- ✅ Section paiements à venir
- ✅ Bottom Navigation (4 onglets)

**Navigation** :
- Onglet 0 : Dashboard
- Onglet 1 : Liste des groupes
- Onglet 2 : Notifications
- Onglet 3 : Profil amélioré

---

## 👥 Pages Groupes

### 2. **Liste des Groupes** (`groups_list_page.dart`)
**Localisation** : `lib/presentation/pages/groups/`

**Fonctionnalités** :
- ✅ Liste complète de tous les groupes
- ✅ Affichage : Nom, Montant, Fréquence, Nombre de tours
- ✅ État vide avec message
- ✅ Gestion des erreurs
- ✅ Navigation vers détails (à implémenter)

---

### 3. **Créer un Groupe** (`create_group_page.dart`)
**Localisation** : `lib/presentation/pages/groups/`

**Fonctionnalités** :
- ✅ Formulaire complet avec validation
- ✅ Champs : Nom, Description, Montant, Fréquence
- ✅ Mode de rotation : Séquentiel, Aléatoire, Enchères
- ✅ Nombre de tours
- ✅ Sélecteur de date de début
- ✅ Pénalités optionnelles : Jours de grâce, Montant
- ✅ Création et retour automatique
- ✅ Feedback utilisateur (SnackBar)

**Validations** :
- Nom requis
- Montant requis et numérique
- Nombre de tours requis et numérique

---

### 4. **Rejoindre un Groupe** (`join_group_page.dart`)
**Localisation** : `lib/presentation/pages/groups/`

**Fonctionnalités** :
- ✅ Formulaire avec code d'invitation
- ✅ Validation du code (minimum 6 caractères)
- ✅ Bouton "Scanner QR Code" (préparé)
- ✅ Card d'information
- ✅ Design moderne avec illustration
- ✅ Feedback utilisateur

**À implémenter** :
- Scanner QR Code
- Connexion à l'API pour rejoindre

---

## 🔔 Pages Notifications

### 5. **Notifications** (`notifications_page.dart`)
**Localisation** : `lib/presentation/pages/notifications/`

**Fonctionnalités** :
- ✅ Liste des notifications avec icônes colorées
- ✅ Indicateur "non lu" (point coloré)
- ✅ Types : Paiement, Rappel, Invitation, Tour complété
- ✅ Bouton "Tout marquer comme lu"
- ✅ État vide avec message
- ✅ Timestamp pour chaque notification

**Types de notifications** :
- 🟢 Paiement reçu (Success)
- 🟡 Rappel de cotisation (Warning)
- 🔵 Invitation à un groupe (Info)
- 🟢 Tour complété (Success)

---

## 👤 Pages Profil

### 6. **Profil Amélioré** (`enhanced_profile_page.dart`)
**Localisation** : `lib/presentation/pages/profile/`

**Fonctionnalités** :
- ✅ SliverAppBar avec photo de profil et gradient
- ✅ Badge rôle avec icône
- ✅ 3 statistiques rapides : Groupes, Paiements, En attente
- ✅ Menu rapide : Modifier, Sécurité, Aide
- ✅ Sections organisées avec icônes
- ✅ Design moderne avec bordures et ombres
- ✅ Déconnexion avec confirmation

**Sections** :
1. **Informations personnelles**
   - Nom complet
   - Téléphone
   - Email

2. **Compte & Sécurité**
   - Modifier le profil
   - Changer le mot de passe

3. **Préférences**
   - Paramètres
   - Notifications

4. **Support**
   - Aide & Support
   - À propos

---

### 7. **Modifier le Profil** (`edit_profile_page.dart`)
**Localisation** : `lib/presentation/pages/profile/`

**Fonctionnalités** :
- ✅ Formulaire pré-rempli avec données actuelles
- ✅ Champs : Prénom, Nom, Téléphone
- ✅ Bouton Enregistrer
- ✅ Feedback utilisateur

**À implémenter** :
- Connexion à l'API pour mise à jour
- Upload de photo de profil

---

### 8. **Changer le Mot de Passe** (`change_password_page.dart`)
**Localisation** : `lib/presentation/pages/profile/`

**Fonctionnalités** :
- ✅ Formulaire sécurisé
- ✅ Champs : Mot de passe actuel, Nouveau, Confirmation
- ✅ Champs masqués (obscureText)
- ✅ Bouton de changement
- ✅ Feedback utilisateur

**À implémenter** :
- Validation du mot de passe actuel
- Vérification de la confirmation
- Connexion à l'API

---

### 9. **Paramètres** (`settings_page.dart`)
**Localisation** : `lib/presentation/pages/profile/`

**Fonctionnalités** :
- ✅ Switch pour activer/désactiver les notifications
- ✅ Notifications par email
- ✅ Notifications par SMS
- ✅ Mode sombre (préparé)
- ✅ Sections organisées

**Paramètres disponibles** :
1. **Notifications**
   - Activer/Désactiver toutes les notifications
   - Notifications par email
   - Notifications par SMS

2. **Apparence**
   - Mode sombre (en développement)

---

### 10. **Aide & Support** (`help_support_page.dart`)
**Localisation** : `lib/presentation/pages/profile/`

**Fonctionnalités** :
- ✅ Cards pour chaque option d'aide
- ✅ FAQ (préparé)
- ✅ Contacter le support
- ✅ Guide d'utilisation
- ✅ Signaler un problème
- ✅ Informations de contact

**Options disponibles** :
- 📖 FAQ
- 📧 Contacter le support
- 📚 Guide d'utilisation
- 🐛 Signaler un problème

**Contact** :
- Email : support@pariba.com
- Téléphone : +223 76 71 41 42

---

## 🔐 Pages Authentification

### 11. **Connexion** (`login_page.dart`)
**Localisation** : `lib/presentation/pages/auth/`

**Fonctionnalités** :
- ✅ Formulaire de connexion
- ✅ Validation email et mot de passe
- ✅ Navigation vers inscription
- ✅ BLoC pour gestion d'état
- ✅ Feedback utilisateur

---

### 12. **Inscription** (`register_page.dart`)
**Localisation** : `lib/presentation/pages/auth/`

**Fonctionnalités** :
- ✅ Formulaire complet
- ✅ Validation de tous les champs
- ✅ Confirmation du mot de passe
- ✅ Navigation vers connexion
- ✅ BLoC pour gestion d'état
- ✅ Feedback utilisateur

---

## 🎨 Design System

### Couleurs
- **Primary** : Vert (#4CAF50)
- **Secondary** : Orange (#FF9800)
- **Success** : Vert (#4CAF50)
- **Warning** : Orange (#FF9800)
- **Error** : Rouge (#F44336)
- **Info** : Bleu (#2196F3)

### Composants Réutilisables
- `CustomTextField` : Champ de texte personnalisé
- `CustomButton` : Bouton personnalisé
- `LoadingIndicator` : Indicateur de chargement

---

## 📊 Architecture

```
lib/presentation/pages/
├── home/
│   ├── dashboard_page.dart              (Ancien)
│   └── improved_dashboard_page.dart     ✅ Nouveau
├── groups/
│   ├── groups_list_page.dart            ✅
│   ├── create_group_page.dart           ✅
│   └── join_group_page.dart             ✅
├── notifications/
│   └── notifications_page.dart          ✅
├── profile/
│   ├── profile_page.dart                (Ancien)
│   ├── enhanced_profile_page.dart       ✅ Nouveau
│   ├── edit_profile_page.dart           ✅
│   ├── change_password_page.dart        ✅
│   ├── settings_page.dart               ✅
│   └── help_support_page.dart           ✅
└── auth/
    ├── login_page.dart                  ✅
    └── register_page.dart               ✅
```

---

## 🚀 Navigation

### Bottom Navigation (4 onglets)
1. **Accueil** (Dashboard)
2. **Groupes** (Liste + FAB Créer)
3. **Notifications**
4. **Profil**

### Navigation Hiérarchique
```
Dashboard
├── Créer un groupe
├── Rejoindre un groupe
└── Détails groupe (à implémenter)

Profil
├── Modifier le profil
├── Changer le mot de passe
├── Paramètres
└── Aide & Support
```

---

## ✅ Checklist des Fonctionnalités

### Implémenté ✅
- [x] Dashboard avec statistiques
- [x] Liste des groupes
- [x] Créer un groupe
- [x] Rejoindre un groupe
- [x] Notifications
- [x] Profil amélioré
- [x] Modifier le profil
- [x] Changer le mot de passe
- [x] Paramètres
- [x] Aide & Support
- [x] Connexion
- [x] Inscription

### À implémenter 🔄
- [ ] Détails d'un groupe
- [ ] Scanner QR Code
- [ ] Gestion des paiements
- [ ] Historique des transactions
- [ ] Chat de groupe
- [ ] Invitations
- [ ] Statistiques avancées
- [ ] Export de données

---

## 📱 Captures d'écran

### Dashboard
- Header avec gradient
- 4 statistiques colorées
- Actions rapides (3 boutons)
- Groupes récents
- Paiements à venir

### Profil
- SliverAppBar avec photo
- Badge rôle
- 3 statistiques
- Menu rapide (3 boutons)
- Sections organisées

---

## 🐛 Corrections Apportées

### Overflow corrigé ✅
- **Problème** : RenderFlex overflow de 2.3 pixels
- **Solution** : Utilisation de `Flexible` au lieu de `Expanded` dans les statistiques
- **Fichier** : `enhanced_profile_page.dart`

### Imports nettoyés ✅
- Suppression des imports inutilisés
- Organisation des imports par catégorie

---

## 📝 Notes de Développement

### Bonnes Pratiques
- Utilisation de BLoC pour la gestion d'état
- Widgets réutilisables
- Validation des formulaires
- Feedback utilisateur (SnackBar)
- Gestion des erreurs
- États vides avec messages

### Performance
- Lazy loading des listes
- Optimisation des images
- Cache des données

---

**Version** : 1.0.0  
**Dernière mise à jour** : 17 Novembre 2025  
**Développeur** : PariBa Team
