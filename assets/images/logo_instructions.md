# Logo PariBa - Instructions

## Créer le logo

Pour créer le logo de l'application PariBa, vous avez plusieurs options :

### Option 1 : Utiliser un outil en ligne (Recommandé)
1. Allez sur **Canva** (https://www.canva.com)
2. Créez un design de 1024x1024 pixels
3. Utilisez les couleurs de PariBa :
   - Vert principal : #4CAF50
   - Orange secondaire : #FF9800
4. Ajoutez le texte "PariBa" avec une icône de portefeuille/tontine
5. Exportez en PNG avec fond transparent

### Option 2 : Utiliser un générateur d'icônes
1. Allez sur **App Icon Generator** (https://www.appicon.co)
2. Uploadez votre logo 1024x1024
3. Générez toutes les tailles d'icônes

### Option 3 : Design simple avec texte
Créez un logo simple avec :
- Fond vert (#4CAF50)
- Texte blanc "PB" ou "PariBa"
- Icône de portefeuille ou groupe

## Fichiers nécessaires

Placez les fichiers suivants dans ce dossier :

1. **logo.png** (1024x1024) - Pour le splash screen
2. **app_icon.png** (1024x1024) - Pour l'icône de l'application

## Générer les icônes

Après avoir créé le logo, exécutez :

```bash
# Installer flutter_launcher_icons
flutter pub add dev:flutter_launcher_icons

# Générer les icônes
flutter pub run flutter_launcher_icons
```

## Configuration temporaire

En attendant votre logo personnalisé, un logo par défaut sera utilisé.
