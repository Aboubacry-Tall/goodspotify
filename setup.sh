#!/bin/bash

# Script de configuration pour GoodSpotify
echo "🎵 Configuration de GoodSpotify..."

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé."
    echo "📦 Installation de Flutter via snap..."
    sudo snap install flutter --classic
    
    # Ajouter Flutter au PATH si nécessaire
    echo 'export PATH="$PATH:/snap/flutter/current/bin"' >> ~/.bashrc
    source ~/.bashrc
    
    echo "✅ Flutter installé!"
else
    echo "✅ Flutter est déjà installé."
fi

# Naviguer vers le répertoire du projet
cd goodspotify

# Vérifier la configuration Flutter
echo "🔍 Vérification de la configuration Flutter..."
flutter doctor

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Créer les fichiers de configuration manquants si nécessaire
echo "📝 Vérification des fichiers de configuration..."

# Vérifier si les fichiers Firebase existent
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Fichier google-services.json manquant pour Android"
    echo "   Téléchargez-le depuis votre console Firebase"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Fichier GoogleService-Info.plist manquant pour iOS"
    echo "   Téléchargez-le depuis votre console Firebase"
fi

echo ""
echo "🎉 Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Configurez votre projet Spotify Developer (Client ID)"
echo "2. Configurez votre projet Firebase"
echo "3. Lancez l'application avec: flutter run"
echo ""
echo "📚 Documentation complète dans README.md"
