#!/usr/bin/env python3
"""
Script para baixar wallpapers HD do Unsplash
Baixa wallpapers na resolução exata da tela (1600x900)
"""

import os
import requests
from urllib.parse import urlencode

def download_wallpaper(url, filename, wallpaper_dir):
    """Baixa um wallpaper"""
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        filepath = os.path.join(wallpaper_dir, filename)
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"✅ Baixado: {filename}")
        return True
    except Exception as e:
        print(f"❌ Erro ao baixar {filename}: {e}")
        return False

def download_hd_wallpapers():
    """Baixa vários wallpapers HD"""
    wallpaper_dir = os.path.expanduser("~/Wallpapers/HD/")
    os.makedirs(wallpaper_dir, exist_ok=True)
    
    # URLs de wallpapers do Unsplash em 1600x900
    wallpapers = [
        ("https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1600&h=900&fit=crop", "desert-sunset.jpg"),
        ("https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=1600&h=900&fit=crop", "forest-lake.jpg"),
        ("https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1600&h=900&fit=crop", "sunset-field.jpg"),
        ("https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=1600&h=900&fit=crop", "night-ocean.jpg"),
        ("https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=1600&h=900&fit=crop", "mountain-snow.jpg"),
        ("https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=1600&h=900&fit=crop", "autumn-forest.jpg"),
        ("https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1600&h=900&fit=crop", "mountain-lake.jpg"),
        ("https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1600&h=900&fit=crop", "space-stars.jpg"),
        ("https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=1600&h=900&fit=crop", "galaxy.jpg"),
    ]
    
    print(f"📥 Baixando wallpapers HD para: {wallpaper_dir}")
    
    successful = 0
    for url, filename in wallpapers:
        filepath = os.path.join(wallpaper_dir, filename)
        
        # Pular se já existe
        if os.path.exists(filepath):
            print(f"⏭️  Já existe: {filename}")
            successful += 1
            continue
            
        if download_wallpaper(url, filename, wallpaper_dir):
            successful += 1
    
    print(f"\n🎯 Download completo: {successful}/{len(wallpapers)} wallpapers")
    print(f"📁 Localização: {wallpaper_dir}")

if __name__ == "__main__":
    download_hd_wallpapers()