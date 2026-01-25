# 📢 Intégration du Système de Publicités

## Vue d'ensemble

Le système de publicités affiche des publicités aux utilisateurs **non abonnés uniquement**. Il supporte 3 types de placements :
- **BANNER** : Bannière dans le contenu
- **POPUP** : Popup après 3 secondes
- **FULLSCREEN** : Plein écran après 10 secondes

---

## 🚀 Utilisation dans la Page d'Accueil

### 1. Importer le widget

```dart
import 'package:pariba/presentation/widgets/home_advertisement_section.dart';
```

### 2. Ajouter le widget dans votre page

```dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupérer le statut d'abonnement de l'utilisateur
    final subscription = ref.watch(subscriptionProvider);
    final hasActiveSubscription = subscription?.isActive ?? false;

    return Scaffold(
      body: ListView(
        children: [
          // Votre contenu...
          
          // Widget de publicités (affiche automatiquement si pas d'abonnement)
          HomeAdvertisementSection(
            hasActiveSubscription: hasActiveSubscription,
          ),
          
          // Suite du contenu...
        ],
      ),
    );
  }
}
```

---

## 📋 Fonctionnement Automatique

Le widget `HomeAdvertisementSection` gère automatiquement :

### ✅ Vérification de l'abonnement
- Si l'utilisateur a un abonnement actif → **Aucune publicité affichée**
- Si l'utilisateur n'a pas d'abonnement → **Publicités affichées**

### ✅ Chargement des publicités
- Récupère les publicités actives depuis le backend
- Filtre par placement (BANNER, POPUP, FULLSCREEN)

### ✅ Affichage intelligent
- **BANNER** : Affiché immédiatement dans le contenu
- **POPUP** : Affiché après 3 secondes en dialog
- **FULLSCREEN** : Affiché après 10 secondes en plein écran

### ✅ Tracking automatique
- Enregistre les **impressions** (vues)
- Enregistre les **clics** sur les publicités

---

## 🎨 Types de Publicités

### 1. Banner (Bannière)
```dart
AdvertisementBanner(
  advertisement: ad,
  onClose: () {
    // Fermer la bannière
  },
)
```

### 2. Popup (Dialog)
```dart
AdvertisementPopup(
  advertisement: ad,
  onClose: () {
    // Fermer le popup
  },
  onTap: () {
    // Enregistrer le clic
  },
)
```

### 3. Fullscreen (Plein écran)
```dart
AdvertisementFullscreen(
  advertisement: ad,
  onClose: () {
    // Fermer le fullscreen
  },
  onTap: () {
    // Enregistrer le clic
  },
)
```

---

## 🔧 Configuration Backend

### Endpoints API

```
GET  /api/v1/advertisements?placement=BANNER
POST /api/v1/advertisements/{adId}/impression
POST /api/v1/advertisements/{adId}/click
```

### Vérification d'abonnement côté backend

Le backend vérifie automatiquement si l'utilisateur a un abonnement actif :
- Si **abonné** → Retourne une liste vide
- Si **non abonné** → Retourne les publicités actives

---

## 📊 Modèle de Données

```dart
class AdvertisementModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? linkUrl;
  final AdPlacement placement; // FULLSCREEN, BANNER, POPUP
  final int impressions;
  final int clicks;
  final bool active;
}

enum AdPlacement {
  fullscreen,
  banner,
  popup,
}
```

---

## 🎯 Exemple Complet

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pariba/presentation/widgets/home_advertisement_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupérer le statut d'abonnement
    final subscription = ref.watch(subscriptionProvider);
    final hasActiveSubscription = subscription?.isActive ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: ListView(
        children: [
          // En-tête
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bienvenue sur PariBa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // 📢 Section Publicités (automatique)
          HomeAdvertisementSection(
            hasActiveSubscription: hasActiveSubscription,
          ),

          // Contenu principal
          _buildGroupsList(),
          _buildRecentActivity(),
        ],
      ),
    );
  }
}
```

---

## ✨ Avantages

✅ **Automatique** : Pas besoin de gérer manuellement l'affichage  
✅ **Intelligent** : Vérifie l'abonnement automatiquement  
✅ **Tracking** : Enregistre les impressions et clics  
✅ **Flexible** : 3 types de placements différents  
✅ **Performant** : Cache les images avec `cached_network_image`  
✅ **UX optimale** : Bouton de fermeture sur toutes les publicités  

---

## 🔄 Génération du Code

Après avoir modifié le modèle, exécutez :

```bash
cd pariba
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Notes

- Les publicités sont affichées **uniquement aux utilisateurs non abonnés**
- Le backend gère la logique de vérification d'abonnement
- Les publicités sont chargées de manière asynchrone
- Les erreurs sont gérées silencieusement (pas d'affichage si erreur)
