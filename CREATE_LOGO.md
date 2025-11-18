# 🎨 Créer le Logo PariBa - Guide Rapide

## Option Rapide : Logo Texte Simple

Créez un logo simple avec un éditeur d'image ou en ligne :

### Méthode 1 : Canva (Recommandé - 5 minutes)

1. **Allez sur** : https://www.canva.com
2. **Créez** : Un design personnalisé 1024x1024 pixels
3. **Ajoutez** :
   - Fond vert (#4CAF50)
   - Texte "PariBa" en blanc, police bold
   - Icône de portefeuille ou groupe (optionnel)
4. **Téléchargez** : En PNG
5. **Renommez** :
   - Une copie en `logo.png`
   - Une copie en `app_icon.png`
6. **Placez** dans `assets/images/`

### Méthode 2 : Logo Maker en Ligne (3 minutes)

1. **Allez sur** : https://www.designevo.com ou https://www.freelogodesign.org
2. **Recherchez** : "wallet" ou "finance" ou "group"
3. **Personnalisez** :
   - Texte : "PariBa" ou "PB"
   - Couleur : Vert #4CAF50
4. **Téléchargez** en 1024x1024
5. **Placez** dans `assets/images/`

### Méthode 3 : Logo Simple avec PowerPoint/Keynote

1. **Créez** une diapositive carrée
2. **Ajoutez** :
   - Rectangle vert (#4CAF50)
   - Texte blanc "PB" ou "PariBa"
   - Icône (optionnel)
3. **Exportez** en PNG 1024x1024
4. **Placez** dans `assets/images/`

## 📐 Spécifications du Logo

### Pour le Splash Screen (`logo.png`)
- **Taille** : 1024x1024 pixels
- **Format** : PNG
- **Fond** : Transparent ou blanc
- **Logo** : Centré, ~60% de la taille

### Pour l'Icône (`app_icon.png`)
- **Taille** : 1024x1024 pixels
- **Format** : PNG
- **Fond** : Vert #4CAF50 (recommandé)
- **Logo** : Centré, ~70% de la taille

## 🎨 Couleurs PariBa

```
Vert Principal : #4CAF50
Orange Secondaire : #FF9800
Blanc : #FFFFFF
Noir : #000000
```

## ✅ Checklist

- [ ] Créer `logo.png` (1024x1024)
- [ ] Créer `app_icon.png` (1024x1024)
- [ ] Placer dans `assets/images/`
- [ ] Vérifier que les fichiers existent
- [ ] Lancer `flutter pub get`
- [ ] Générer le splash : `flutter pub run flutter_native_splash:create`
- [ ] Générer les icônes : `flutter pub run flutter_launcher_icons`
- [ ] Tester avec `flutter run`

## 🚀 Commandes à Exécuter

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Générer le splash screen
flutter pub run flutter_native_splash:create

# 3. Générer les icônes
flutter pub run flutter_launcher_icons

# 4. Nettoyer et relancer
flutter clean
flutter run
```

## 💡 Idées de Logo

### Simple et Efficace
- **PB** en lettres blanches sur fond vert
- **PariBa** en texte stylisé
- Icône de portefeuille + texte
- Icône de groupe de personnes + texte

### Avec Icône
- 💰 Portefeuille
- 👥 Groupe de personnes
- 🤝 Poignée de main
- 💵 Billets
- 🔄 Rotation/Cycle

## 📱 Aperçu du Résultat

Après génération, vous verrez :

1. **Splash Screen** : Logo centré sur fond vert pendant 2 secondes
2. **Icône App** : Logo sur l'écran d'accueil du téléphone
3. **Onboarding** : 4 écrans d'introduction
4. **Login** : Page de connexion

---

**Besoin d'aide ?** Consultez `SETUP_SPLASH_ICON.md` pour plus de détails.
