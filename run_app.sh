#!/bin/bash

# Script pour lancer l'application GoodSpotify
echo "🎵 Lancement de GoodSpotify..."

# Naviguer vers le répertoire du projet
cd goodspotify

# Vérifier si un appareil/émulateur est connecté
echo "📱 Vérification des appareils disponibles..."
/home/tall/Documents/Flutter/Sdk/flutter/bin/flutter devices

echo ""
echo "🚀 Lancement de l'application..."
echo "   - Mode: Debug"
echo "   - Plateforme: Automatique"
echo ""

# Lancer l'application
/home/tall/Documents/Flutter/Sdk/flutter/bin/flutter run

echo ""
echo "✅ Application terminée"
