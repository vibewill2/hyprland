import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import subprocess
import glob
import os
from pathlib import Path
import configparser

THUMB_SIZE = (150, 95)
WINDOW_SIZE = "650x240"
BG = "#1f1f1f"
FG = "#e6e6e6"
ACCENT = "#4a9eff"

class MiniSwwwSelector:
    def __init__(self, root):
        self.root = root
        self.root.title("Mini Wallpaper Selector")
        self.root.configure(bg=BG)
        self.root.resizable(False, False)

        self.wallpapers = self.get_wallpapers()
        self.current_set = 0
        self.selected_index = 0

        self.thumb_cache = {}

        self.setup_ui()
        self.load_wallpapers()
        self.center_window()

        self.root.bind('<Left>', lambda e: self.navigate_left())
        self.root.bind('<Right>', lambda e: self.navigate_right())
        self.root.bind('<Up>', lambda e: self.previous_set())
        self.root.bind('<Down>', lambda e: self.next_set())
        self.root.bind('<Return>', lambda e: self.apply_wallpaper())
        self.root.bind('<Escape>', lambda e: self.root.quit())

    def center_window(self):
        try:
            self.root.eval('tk::PlaceWindow . center')
        except:
            self.root.update_idletasks()
            screen_width = self.root.winfo_screenwidth()
            screen_height = self.root.winfo_screenheight()
            width, height = map(int, WINDOW_SIZE.split('x'))
            x = (screen_width - width) // 2
            y = (screen_height - height) // 2 - 100
            self.root.geometry(f"{width}x{height}+{x}+{y}")
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

        if len(found) < 6:
            for root_dir, dirs, files in os.walk(folder):
                for ext in exts:
                    found.extend(glob.glob(os.path.join(root_dir, ext)))
                if len(found) >= 60:
                    break

        found = sorted(list(dict.fromkeys(found)))
        return found[:90]

    def setup_ui(self):
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
                frame.configure(highlightbackground=ACCENT)
            else:
                frame.configure(highlightbackground="#3a3a3a")

    def update_status(self):
        if not self.wallpapers:
            return
        total = len(self.wallpapers)
        idx = (self.current_set * 3 + self.selected_index) % total
        base = os.path.basename(self.wallpapers[idx])
        self.status_label.configure(text=f"{idx+1}/{total} • {base} • Tela Cheia")

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

    def apply_wallpaper(self):
        if not self.wallpapers:
            return

        idx = (self.current_set * 3 + self.selected_index) % len(self.wallpapers)
        path = self.wallpapers[idx]

        try:
            subprocess.run(['pkill', '-x', 'swaybg'], stderr=subprocess.DEVNULL)

            subprocess.Popen([
                'swaybg',
                '-i', path,
                '-m', 'fill'
            ])

            self.status_label.configure(
                text=f"OK: {os.path.basename(path)} (Tela Cheia)",
                fg="#79e07d"
            )
            self.root.after(2000, lambda: self.status_label.configure(fg="#e6d35c"))

        except FileNotFoundError:
            self.status_label.configure(text="swaybg não encontrado", fg="#ff6b6b")
        except Exception as e:
            self.status_label.configure(text=f"Erro: {e}", fg="#ff6b6b")


def main():
    root = tk.Tk()
    app = MiniSwwwSelector(root)
    root.mainloop()

if __name__ == '__main__':
    main()