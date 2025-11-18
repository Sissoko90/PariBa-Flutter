# 🎨 Configuration du Splash Screen et de l'Icône - PariBa

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :
1. ✅ Flutter installé et configuré
2. ✅ Un logo/icône de 1024x1024 pixels

---

## 🖼️ Étape 1 : Créer les Assets

### 1.1 Créer le Logo pour le Splash Screen

Créez un fichier `logo.png` (1024x1024 pixels) avec :
- **Fond transparent** ou blanc
- **Logo PariBa** centré
- **Format PNG**

Placez-le dans : `assets/images/logo.png`

### 1.2 Créer l'Icône de l'Application

Créez un fichier `app_icon.png` (1024x1024 pixels) avec :
- **Fond vert** (#4CAF50) ou transparent
- **Logo PariBa** ou initiales "PB"
- **Format PNG**

Placez-le dans : `assets/images/app_icon.png`

---

## 🚀 Étape 2 : Installer les Dépendances

```bash
cd /Users/abdatytechnologie/StudioProjects/pariba
flutter pub get
```

---

## 🎯 Étape 3 : Générer le Splash Screen Natif

```bash
# Générer le splash screen pour Android et iOS
flutter pub run flutter_native_splash:create
```

Cette commande va :
- ✅ Créer les fichiers natifs pour Android
- ✅ Créer les fichiers natifs pour iOS
- ✅ Configurer les couleurs et l'image
- ✅ Supporter Android 12+ avec le nouveau splash screen

---

## 📱 Étape 4 : Générer les Icônes de l'Application

```bash
# Générer toutes les tailles d'icônes
flutter pub run flutter_launcher_icons
```

Cette commande va créer :
- ✅ Icônes Android (toutes les densités)
- ✅ Icônes iOS (toutes les tailles)
- ✅ Icônes adaptatives pour Android 8+

---

## 🎨 Étape 5 : Personnalisation (Optionnel)

### Changer la Couleur du Splash Screen

Éditez `pubspec.yaml` :

```yaml
flutter_native_splash:
  color: "#4CAF50"  # Changez cette couleur
  image: assets/images/logo.png
```

### Changer la Couleur de l'Icône Adaptative

```yaml
flutter_launcher_icons:
  adaptive_icon_background: "#4CAF50"  # Changez cette couleur
```

Puis relancez les commandes de génération.

---

## ✅ Étape 6 : Tester

### Tester sur Android

```bash
# Nettoyer le build
flutter clean

# Reconstruire l'application
flutter build apk --debug

# Ou lancer directement
flutter run
```

### Tester sur iOS

```bash
# Nettoyer le build
flutter clean

# Reconstruire l'application
flutter build ios --debug

# Ou lancer directement
flutter run
```

---

## 📝 Vérification

Après avoir suivi ces étapes, vous devriez voir :

1. ✅ **Au démarrage** : Splash screen vert avec le logo PariBa
2. ✅ **Sur l'écran d'accueil** : Icône de l'application avec le logo
3. ✅ **Première ouverture** : Pages d'onboarding (4 écrans)
4. ✅ **Ouvertures suivantes** : Directement sur la page de connexion

---

## 🎨 Ressources pour Créer le Logo

### Option 1 : Canva (Gratuit)
1. Allez sur https://www.canva.com
2. Créez un design 1024x1024
3. Utilisez les couleurs PariBa :
   - Vert : #4CAF50
   - Orange : #FF9800
4. Exportez en PNG

### Option 2 : Figma (Gratuit)
1. Créez un frame 1024x1024
2. Dessinez votre logo
3. Exportez en PNG 2x

### Option 3 : Logo Maker en ligne
- **Hatchful** : https://hatchful.shopify.com
- **LogoMakr** : https://logomakr.com
- **Canva Logo Maker** : https://www.canva.com/create/logos

---

## 🐛 Dépannage

### Le splash screen ne s'affiche pas

```bash
# Supprimer les fichiers de build
flutter clean

# Régénérer le splash screen
flutter pub run flutter_native_splash:create

# Reconstruire
flutter run
```

### L'icône ne change pas

```bash
# Régénérer les icônes
flutter pub run flutter_launcher_icons

# Sur Android, désinstaller l'app et réinstaller
flutter clean
flutter run
```

### Erreur "Image not found"

Vérifiez que les fichiers existent :
- `assets/images/logo.png`
- `assets/images/app_icon.png`

---

## 📱 Résultat Final

### Splash Screen
- **Durée** : ~2 secondes
- **Couleur** : Vert (#4CAF50)
- **Logo** : Centré
- **Transition** : Fluide vers l'onboarding ou login

### Icône de l'Application
- **Android** : Icône adaptative avec fond vert
- **iOS** : Icône arrondie
- **Toutes les tailles** : Générées automatiquement

### Onboarding
- **4 écrans** : Bienvenue, Groupes, Paiements, Sécurité
- **Skip** : Bouton pour passer
- **Indicateurs** : Points de progression
- **Une seule fois** : Sauvegardé dans SharedPreferences

---

## 🎉 C'est Terminé !

Votre application PariBa a maintenant :
- ✅ Un splash screen natif professionnel
- ✅ Une icône d'application personnalisée
- ✅ Un onboarding interactif
- ✅ Une expérience utilisateur complète

**Profitez de votre application ! 🚀**
