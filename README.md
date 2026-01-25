# pariba

Application mobile Flutter pour la gestion collaborative de tontines (épargne rotative).

## 🎯 Fonctionnalités Principales

- **Authentification sécurisée** : Inscription, connexion, OTP
- **Gestion de groupes** : Création et administration de tontines
- **Invitations** : Par numéro de téléphone ou lien partageable
- **Tours rotatifs** : Planification automatique des bénéficiaires
- **Contributions** : Suivi des cotisations et paiements
- **Paiements mobiles** : Orange Money, Moov Money, Wave
- **Notifications** : Rappels push, SMS, WhatsApp
- **Transparence** : Historique et audit complets
- **Exports** : Génération de rapports PDF/Excel

## 📁 Architecture du Projet

```
lib/
├── core/                    # Fonctionnalités partagées
│   ├── constants/          # Constantes (API, App, Storage)
│   ├── errors/             # Gestion des erreurs
│   ├── network/            # Configuration réseau (Dio)
│   ├── security/           # Sécurité (Tokens, Encryption)
│   ├── theme/              # Thème de l'application
│   └── utils/              # Utilitaires (Validators, Formatters)
├── data/                    # Couche de données
│   ├── datasources/        # Sources de données (Local/Remote)
│   ├── models/             # Modèles de données (DTOs)
│   └── repositories/       # Implémentations des repositories
├── domain/                  # Logique métier
│   ├── entities/           # Entités métier
│   ├── repositories/       # Contrats des repositories
│   └── usecases/           # Cas d'utilisation
├── presentation/            # Interface utilisateur
│   ├── blocs/              # Gestion d'état (BLoC)
│   ├── pages/              # Écrans de l'application
│   └── widgets/            # Widgets réutilisables
└── di/                      # Dependency Injection

```

## 🛠️ Technologies Utilisées

- **Framework** : Flutter 3.9+
- **State Management** : flutter_bloc
- **Dependency Injection** : get_it + injectable
- **Network** : dio + retrofit
- **Local Storage** : shared_preferences + flutter_secure_storage + hive
- **Navigation** : go_router
- **Code Generation** : build_runner + json_serializable
- **Firebase** : Push Notifications (FCM)

## 🚀 Installation

### Prérequis

- Flutter SDK 3.9 ou supérieur
- Dart SDK 3.9 ou supérieur
- Android Studio / Xcode
- Node.js (pour JSON Server)

### Étapes

1. **Cloner le projet**
```bash
git clone <repository-url>
cd pariba
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer le code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Lancer JSON Server (Backend Mock)**
```bash
cd server
json-server --watch db.json --port 3000
```

5. **Lancer l'application**
```bash
flutter run
```

## 📝 Configuration

### API Base URL

Modifiez l'URL de base dans `lib/core/constants/api_constants.dart` :

```dart
static const String baseUrl = 'http://localhost:3000'; // ou votre URL
```

### Firebase (Notifications Push)

1. Ajoutez vos fichiers de configuration Firebase :
   - Android : `android/app/google-services.json`
   - iOS : `ios/Runner/GoogleService-Info.plist`

2. Suivez la documentation Firebase pour Flutter

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test
```

## 📦 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 Design System

### Couleurs Principales
- **Primary** : #2E7D32 (Vert)
- **Secondary** : #FFA726 (Orange)
- **Accent** : #00BCD4 (Cyan)

### Typographie
- **Headings** : Bold, 16-32px
- **Body** : Regular, 12-16px
- **Buttons** : Semi-bold, 14-16px

## 📚 Documentation API

### Endpoints Principaux

- `POST /auth/login` - Connexion
- `POST /auth/register` - Inscription
- `GET /tontineGroups` - Liste des groupes
- `POST /tontineGroups` - Créer un groupe
- `GET /contributions` - Liste des contributions
- `POST /payments` - Effectuer un paiement

Voir `db.json` pour la structure complète des données.

## 🤝 Contribution

1. Fork le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## 👥 Équipe

- **Développeur Principal** : Cheick Kounta

## 📞 Support

Pour toute question ou support :
- Email : abdaty11@gmail.com
- Téléphone : +223 97 75 86 97

---

**Version** : 1.0.0  
**Dernière mise à jour** : Novembre 2025
samples, guidance on mobile development, and a full API reference.
