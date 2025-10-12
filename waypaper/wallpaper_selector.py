#!/usr/bin/env python3
"""
Seletor de Wallpapers com navegação por setas
Permite navegar entre 3 wallpapers e aplicar com swww
"""

import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import subprocess
import glob
import os
from pathlib import Path

class WallpaperSelector:
    def __init__(self, root):
        self.root = root
        self.root.title("Seletor de Wallpapers - Use ← → para navegar")
        self.root.geometry("650x400")
        self.root.configure(bg='#2b2b2b')
        
        # Lista de wallpapers disponíveis
        self.wallpapers = self.get_wallpapers()
        
        if len(self.wallpapers) < 3:
            print("Precisamos de pelo menos 3 wallpapers!")
            return
            
        # Seleção inicial dos 3 primeiros wallpapers
        self.current_set = 0
        self.selected_index = 0
        
        # Modo de redimensionamento atual
        self.resize_modes = ['crop', 'fit', 'stretch', 'no']
        self.resize_mode_names = ['Crop (Preenche)', 'Fit (Ajusta)', 'Stretch (Estica)', 'No (Original)']
        self.current_resize_mode = 0
        
        self.setup_ui()
        self.load_wallpapers()
        
        # Bind das teclas
        self.root.bind('<Key>', self.on_key_press)
        self.root.focus_set()
        
    def get_wallpapers(self):
        """Busca wallpapers disponíveis, priorizando HD"""
        # Diretórios priorizados por qualidade
        hd_dirs = [
            os.path.expanduser("~/Wallpapers/HD/"),
            os.path.expanduser("~/Wallpapers/"),
            os.path.expanduser("~/Pictures/"),
        ]
        
        # Diretórios secundários (podem ter baixa resolução)
        backup_dirs = [
            "/usr/share/backgrounds/",
            "/usr/share/pixmaps/",
        ]
        
        extensions = ['*.png', '*.jpg', '*.jpeg', '*.webp']
        hd_wallpapers = []
        backup_wallpapers = []
        
        # Buscar primeiro wallpapers HD
        for directory in hd_dirs:
            if os.path.exists(directory):
                for ext in extensions:
                    found = glob.glob(os.path.join(directory, ext))
                    hd_wallpapers.extend(found)
        
        # Se não tiver wallpapers HD suficientes, buscar nos outros diretórios
        if len(hd_wallpapers) < 9:  # Queremos pelo menos 3 conjuntos
            for directory in backup_dirs:
                if os.path.exists(directory):
                    for ext in extensions:
                        found = glob.glob(os.path.join(directory, ext))
                        backup_wallpapers.extend(found)
        
        # Filtrar por resolução mínima
        filtered_wallpapers = []
        min_resolution = 800  # Resolução mínima aceitável
        
        # Primeiro verificar wallpapers HD
        for wallpaper_path in hd_wallpapers:
            if self._check_resolution(wallpaper_path, min_resolution):
                filtered_wallpapers.append(wallpaper_path)
        
        # Se ainda precisar de mais, adicionar dos backups (mesmo com resolução menor)
        if len(filtered_wallpapers) < 6:
            filtered_wallpapers.extend(backup_wallpapers[:9])  # Máximo 9 do backup
        
        # Remove duplicatas e ordena
        unique_wallpapers = sorted(list(set(filtered_wallpapers)))
        return unique_wallpapers[:20]  # Aumentei o limite
    
    def _check_resolution(self, image_path, min_size):
        """Verifica se a imagem tem resolução mínima aceitável"""
        try:
            with Image.open(image_path) as img:
                width, height = img.size
                return width >= min_size and height >= min_size
        except Exception:
            return False  # Se não conseguir abrir, considera como baixa resolução
    
    def setup_ui(self):
        """Configura a interface gráfica"""
        # Título
        title_label = tk.Label(
            self.root, 
            text="← → para navegar | Enter aplicar | M para modo | ↑ ↓ conjuntos | ESC sair",
            font=("Arial", 10, "bold"),
            bg='#2b2b2b',
            fg='white'
        )
        title_label.pack(pady=2)
        
        # Frame principal para as imagens
        self.main_frame = tk.Frame(self.root, bg='#2b2b2b')
        self.main_frame.pack(expand=True, fill='both', padx=5, pady=2)
        
        # Frame para cada imagem
        self.image_frames = []
        self.image_labels = []
        self.name_labels = []
        
        for i in range(3):
            frame = tk.Frame(self.main_frame, bg='#2b2b2b', relief='solid', borderwidth=2)
            frame.pack(side='left', expand=True, fill='both', padx=2)
            
            # Label para a imagem
            img_label = tk.Label(frame, bg='#2b2b2b')
            img_label.pack(expand=True, pady=1)
            
            # Label para o nome do arquivo
            name_label = tk.Label(
                frame, 
                text="", 
                font=("Arial", 8),
                bg='#2b2b2b',
                fg='white',
                wraplength=180
            )
            name_label.pack(pady=1)
            
            self.image_frames.append(frame)
            self.image_labels.append(img_label)
            self.name_labels.append(name_label)
        
        # Label para modo de redimensionamento
        self.resize_label = tk.Label(
            self.root,
            text="",
            font=("Arial", 8),
            bg='#2b2b2b',
            fg='cyan'
        )
        self.resize_label.pack(pady=1)
        
        # Status bar
        self.status_label = tk.Label(
            self.root,
            text="",
            font=("Arial", 9),
            bg='#2b2b2b',
            fg='yellow'
        )
        self.status_label.pack(pady=2)
        
        self.update_selection_highlight()
    
    def load_wallpapers(self):
        """Carrega e exibe as 3 imagens atuais"""
        for i in range(3):
            wallpaper_index = (self.current_set * 3 + i) % len(self.wallpapers)
            wallpaper_path = self.wallpapers[wallpaper_index]
            
            try:
                # Carrega e redimensiona a imagem
                with Image.open(wallpaper_path) as img:
                    img.thumbnail((180, 120), Image.Resampling.LANCZOS)
                    photo = ImageTk.PhotoImage(img)
                
                self.image_labels[i].configure(image=photo)
                self.image_labels[i].image = photo  # Mantém referência
                
                # Nome do arquivo e resolução
                filename = os.path.basename(wallpaper_path)
                
                # Obter resolução da imagem original
                try:
                    with Image.open(wallpaper_path) as img_info:
                        width, height = img_info.size
                        resolution_text = f"{filename}\n{width}x{height}"
                        # Cor baseada na qualidade
                        if width >= 1200:  # HD
                            color = '#00ff00'  # Verde
                        elif width >= 800:  # Média
                            color = '#ffff00'  # Amarelo
                        else:  # Baixa
                            color = '#ff6666'  # Vermelho claro
                        self.name_labels[i].configure(text=resolution_text, fg=color)
                except Exception:
                    self.name_labels[i].configure(text=filename, fg='white')
                
            except Exception as e:
                self.image_labels[i].configure(text=f"Erro ao carregar\n{os.path.basename(wallpaper_path)}")
                self.name_labels[i].configure(text="")
        
        self.update_status()
    
    def update_selection_highlight(self):
        """Atualiza o destaque da seleção atual"""
        for i, frame in enumerate(self.image_frames):
            if i == self.selected_index:
                frame.configure(bg='#4a9eff', borderwidth=3)
            else:
                frame.configure(bg='#2b2b2b', borderwidth=2)
    
    def update_status(self):
        """Atualiza a barra de status"""
        current_wallpaper_index = self.current_set * 3 + self.selected_index
        total_wallpapers = len(self.wallpapers)
        current_wallpaper = os.path.basename(self.wallpapers[current_wallpaper_index])
        
        status_text = f"Wallpaper {current_wallpaper_index + 1}/{total_wallpapers} | Selecionado: {current_wallpaper}"
        self.status_label.configure(text=status_text)
        
        # Atualizar modo de redimensionamento
        resize_text = f"Modo: {self.resize_mode_names[self.current_resize_mode]} (Pressione M para mudar)"
        self.resize_label.configure(text=resize_text)
    
    def on_key_press(self, event):
        """Manipula os eventos de tecla"""
        if event.keysym == 'Right':
            self.navigate_right()
        elif event.keysym == 'Left':
            self.navigate_left()
        elif event.keysym == 'Return':
            self.apply_wallpaper()
        elif event.keysym == 'Escape':
            self.root.quit()
        elif event.keysym == 'Up':
            self.previous_set()
        elif event.keysym == 'Down':
            self.next_set()
        elif event.keysym.lower() == 'm':
            self.cycle_resize_mode()
    
    def navigate_right(self):
        """Navega para a direita"""
        if self.selected_index < 2:
            self.selected_index += 1
        else:
            # Se chegou ao fim, vai para o próximo conjunto
            self.next_set()
            self.selected_index = 0
        
        self.update_selection_highlight()
        self.update_status()
    
    def navigate_left(self):
        """Navega para a esquerda"""
        if self.selected_index > 0:
            self.selected_index -= 1
        else:
            # Se chegou ao início, vai para o conjunto anterior
            self.previous_set()
            self.selected_index = 2
        
        self.update_selection_highlight()
        self.update_status()
    
    def next_set(self):
        """Próximo conjunto de 3 wallpapers"""
        max_sets = (len(self.wallpapers) + 2) // 3
        self.current_set = (self.current_set + 1) % max_sets
        self.load_wallpapers()
    
    def previous_set(self):
        """Conjunto anterior de 3 wallpapers"""
        max_sets = (len(self.wallpapers) + 2) // 3
        self.current_set = (self.current_set - 1) % max_sets
        self.load_wallpapers()
    
    def cycle_resize_mode(self):
        """Alterna entre os modos de redimensionamento"""
        self.current_resize_mode = (self.current_resize_mode + 1) % len(self.resize_modes)
        self.update_status()
        
        # Feedback visual temporário
        original_color = self.resize_label.cget('fg')
        self.resize_label.configure(fg='green')
        self.root.after(1500, lambda: self.resize_label.configure(fg=original_color))
    
    def apply_wallpaper(self):
        """Aplica o wallpaper selecionado usando swww"""
        current_wallpaper_index = self.current_set * 3 + self.selected_index
        wallpaper_path = self.wallpapers[current_wallpaper_index]
        
        try:
            # Comando para aplicar wallpaper com swww usando modo selecionado
            current_resize_mode = self.resize_modes[self.current_resize_mode]
            
            result = subprocess.run([
                'swww', 'img', wallpaper_path, 
                '--transition-type', 'fade',
                '--transition-duration', '1',
                '--resize', current_resize_mode,
                '--filter', 'Lanczos3',  # Melhor qualidade de redimensionamento
                '--fill-color', '000000'  # Cor de fundo preta se houver padding
            ], capture_output=True, text=True, check=True)
            
            mode_name = self.resize_mode_names[self.current_resize_mode]
            self.status_label.configure(
                text=f"✅ Wallpaper aplicado ({mode_name}): {os.path.basename(wallpaper_path)}",
                fg='green'
            )
            
            # Volta para cor original após 3 segundos
            self.root.after(3000, lambda: self.status_label.configure(fg='yellow'))
            
        except subprocess.CalledProcessError as e:
            self.status_label.configure(
                text=f"❌ Erro ao aplicar wallpaper: {e}",
                fg='red'
            )
        except FileNotFoundError:
            self.status_label.configure(
                text="❌ swww não encontrado. Instale com: sudo dnf install swww",
                fg='red'
            )

def main():
    root = tk.Tk()
    app = WallpaperSelector(root)
    root.mainloop()

if __name__ == "__main__":
    main()