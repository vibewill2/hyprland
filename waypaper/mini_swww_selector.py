#!/usr/bin/env python3
"""
Mini seletor de wallpapers para swww em janela pequena (3 itens)

Teclas:
- ← →: mover seleção entre os 3 itens
- ↑ ↓: trocar o trio de wallpapers
- Enter: aplicar o selecionado (swww img)
- M: alternar modo de resize (crop, fit, stretch, no)
- ESC: sair
"""

import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import subprocess
import glob
import os
from pathlib import Path
import configparser

THUMB_SIZE = (150, 95)  # miniaturas para caber na janela pequena
WINDOW_SIZE = "560x220"  # janela realmente pequena
BG = "#1f1f1f"
FG = "#e6e6e6"
ACCENT = "#4a9eff"

class MiniSwwwSelector:
    def __init__(self, root):
        self.root = root
        self.root.title("Mini swww: ← → selec | ↑ ↓ trio | Enter aplica | ESC sai")
        self.root.configure(bg=BG)
        self.root.resizable(False, False)

        # Estado
        self.wallpapers = self.get_wallpapers()
        if not self.wallpapers:
            self.wallpapers = []
        self.current_set = 0
        self.selected_index = 0

        self.resize_modes = ['crop', 'fit', 'stretch', 'no']
        self.resize_mode_names = ['Crop', 'Fit', 'Stretch', 'Original']
        self.current_resize_mode = 1  # fit por padrão

        # Cache de thumbs para performance
        self.thumb_cache = {}

        self.setup_ui()
        self.load_wallpapers()
        
        # Centralizar janela após criar a UI
        self.center_window()

        # Keybinds
        self.root.bind('<Left>', lambda e: self.navigate_left())
        self.root.bind('<Right>', lambda e: self.navigate_right())
        self.root.bind('<Up>', lambda e: self.previous_set())
        self.root.bind('<Down>', lambda e: self.next_set())
        self.root.bind('<Return>', lambda e: self.apply_wallpaper())
        self.root.bind('<Escape>', lambda e: self.root.quit())
        self.root.bind('m', lambda e: self.cycle_resize_mode())
        self.root.bind('M', lambda e: self.cycle_resize_mode())

    def center_window(self):
        """Centraliza a janela na tela"""
        try:
            # Tentar usar método nativo do Tkinter
            self.root.eval('tk::PlaceWindow . center')
        except:
            # Fallback para cálculo manual
            self.root.update_idletasks()
            
            # Obter dimensões da tela
            screen_width = self.root.winfo_screenwidth()
            screen_height = self.root.winfo_screenheight()
            
            # Extrair largura e altura da janela
            width, height = map(int, WINDOW_SIZE.split('x'))
            
            # Calcular posição central
            x = (screen_width - width) // 2
            y = (screen_height - height) // 2 - 100  # Um pouco mais acima
            
            # Definir geometria
            self.root.geometry(f"{width}x{height}+{x}+{y}")
        
        # Trazer para frente
        self.root.lift()
        self.root.focus_force()

    def read_config_folder(self):
        cfg_path = os.path.expanduser("~/.config/waypaper/config.ini")
        if os.path.exists(cfg_path):
            config = configparser.ConfigParser()
            try:
                config.read(cfg_path)
                folder = config.get('Settings', 'folder', fallback='').strip()
                if folder:
                    folder = os.path.expanduser(folder)
                    if os.path.isdir(folder):
                        return folder
            except Exception:
                pass
        # fallback comuns
        for p in [
            os.path.expanduser('~/Imagens/wallpapers'),
            os.path.expanduser('~/Wallpapers'),
            os.path.expanduser('~/Pictures'),
            '/usr/share/backgrounds',
        ]:
            if os.path.isdir(p):
                return p
        return os.path.expanduser('~')

    def get_wallpapers(self):
        exts = ('*.png', '*.jpg', '*.jpeg', '*.webp')
        folder = self.read_config_folder()
        found = []
        for ext in exts:
            found.extend(glob.glob(os.path.join(folder, ext)))
        # fallback: inclui subpastas imediatas se muito poucos
        if len(found) < 6:
            for root_dir, dirs, files in os.walk(folder):
                for ext in exts:
                    found.extend(glob.glob(os.path.join(root_dir, ext)))
                if len(found) >= 60:
                    break
        found = sorted(list(dict.fromkeys(found)))
        return found[:90]  # limitar

    def setup_ui(self):
        # frame principal minúsculo
        self.main_frame = tk.Frame(self.root, bg=BG)
        self.main_frame.pack(expand=True, fill='both', padx=6, pady=4)

        self.image_frames = []
        self.image_labels = []
        self.name_labels = []

        for i in range(3):
            frame = tk.Frame(self.main_frame, bg=BG, highlightthickness=2, highlightbackground="#3a3a3a")
            frame.pack(side='left', expand=True, fill='both', padx=4)

            img_label = tk.Label(frame, bg=BG)
            img_label.pack(expand=True, pady=2)

            name_label = tk.Label(frame, text="", font=("Arial", 8), bg=BG, fg=FG, wraplength=THUMB_SIZE[0])
            name_label.pack(pady=1)

            self.image_frames.append(frame)
            self.image_labels.append(img_label)
            self.name_labels.append(name_label)

        # barra de status compacta
        self.status_label = tk.Label(self.root, text="", font=("Arial", 9), bg=BG, fg="#e6d35c")
        self.status_label.pack(pady=2)

        self.update_selection_highlight()

    def _make_thumb(self, path):
        if path in self.thumb_cache:
            return self.thumb_cache[path]
        try:
            with Image.open(path) as img:
                img.thumbnail(THUMB_SIZE, Image.Resampling.LANCZOS)
                photo = ImageTk.PhotoImage(img)
                self.thumb_cache[path] = photo
                return photo
        except Exception:
            return None

    def load_wallpapers(self):
        if not self.wallpapers:
            self.status_label.config(text="Nenhum wallpaper encontrado")
            return
        total = len(self.wallpapers)
        for i in range(3):
            idx = (self.current_set * 3 + i) % total
            path = self.wallpapers[idx]
            photo = self._make_thumb(path)
            if photo:
                self.image_labels[i].configure(image=photo, text="")
                self.image_labels[i].image = photo
            else:
                self.image_labels[i].configure(text="Erro", image="")
                self.image_labels[i].image = None
            base = os.path.basename(path)
            self.name_labels[i].configure(text=base)
        self.update_status()

    def update_selection_highlight(self):
        for i, frame in enumerate(self.image_frames):
            if i == self.selected_index:
                frame.configure(highlightbackground=ACCENT, highlightcolor=ACCENT)
            else:
                frame.configure(highlightbackground="#3a3a3a", highlightcolor="#3a3a3a")

    def update_status(self):
        if not self.wallpapers:
            return
        total = len(self.wallpapers)
        idx = (self.current_set * 3 + self.selected_index) % total
        base = os.path.basename(self.wallpapers[idx])
        mode = self.resize_mode_names[self.current_resize_mode]
        self.status_label.configure(text=f"{idx+1}/{total} • {base} • modo {mode}")

    # Navegação
    def navigate_left(self):
        if self.selected_index > 0:
            self.selected_index -= 1
        else:
            self.previous_set()
            self.selected_index = 2
        self.update_selection_highlight()
        self.update_status()

    def navigate_right(self):
        if self.selected_index < 2:
            self.selected_index += 1
        else:
            self.next_set()
            self.selected_index = 0
        self.update_selection_highlight()
        self.update_status()

    def next_set(self):
        if not self.wallpapers:
            return
        max_sets = (len(self.wallpapers) + 2) // 3
        self.current_set = (self.current_set + 1) % max_sets
        self.load_wallpapers()

    def previous_set(self):
        if not self.wallpapers:
            return
        max_sets = (len(self.wallpapers) + 2) // 3
        self.current_set = (self.current_set - 1) % max_sets
        self.load_wallpapers()

    def cycle_resize_mode(self):
        self.current_resize_mode = (self.current_resize_mode + 1) % len(self.resize_modes)
        self.update_status()

    def apply_wallpaper(self):
        if not self.wallpapers:
            return
        idx = (self.current_set * 3 + self.selected_index) % len(self.wallpapers)
        path = self.wallpapers[idx]
        mode = self.resize_modes[self.current_resize_mode]
        try:
            subprocess.run([
                'swww', 'img', path,
                '--transition-type', 'fade',
                '--transition-duration', '0.6',
                '--resize', mode,
                '--filter', 'Lanczos3',
                '--fill-color', '000000'
            ], check=True, capture_output=True, text=True)
            self.status_label.configure(text=f"OK: aplicado {os.path.basename(path)} ({mode})", fg="#79e07d")
            self.root.after(1500, lambda: self.status_label.configure(fg="#e6d35c"))
        except FileNotFoundError:
            self.status_label.configure(text="swww não encontrado (instale)", fg="#ff6b6b")
        except subprocess.CalledProcessError as e:
            self.status_label.configure(text=f"Erro swww: {e.returncode}", fg="#ff6b6b")


def main():
    root = tk.Tk()
    app = MiniSwwwSelector(root)
    root.mainloop()

if __name__ == '__main__':
    main()
