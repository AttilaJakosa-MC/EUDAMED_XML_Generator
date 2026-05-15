import sys
import os
import shutil
import zipfile
import json
import tkinter as tk
from tkinter import ttk, messagebox
import threading
import ctypes

try:
    # Enable High-DPI awareness on Windows to prevent blurry fonts
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
    # Tell Windows this is a distinct app (un-groups from python.exe in Taskbar so it uses its own icon)
    ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("EUDAMED.XML.Unzipper.1")
except Exception:
    pass

def process_zips():
    def task():
        start_button.config(state=tk.DISABLED)
        
        # When packaged with PyInstaller, use the directory of the executable
        if getattr(sys, 'frozen', False):
            base_dir = os.path.dirname(sys.executable)
        else:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            
        zip_dir = os.path.join(base_dir, 'ZIP')
        xml_dir = os.path.join(base_dir, 'XML')
        
        # Ensure ZIP directory exists
        if not os.path.exists(zip_dir):
            os.makedirs(zip_dir, exist_ok=True)
            
        # Clear XML directory contents if it exists, otherwise create it
        if os.path.exists(xml_dir):
            for filename in os.listdir(xml_dir):
                file_path = os.path.join(xml_dir, filename)
                try:
                    if os.path.isfile(file_path) or os.path.islink(file_path):
                        os.unlink(file_path)
                    elif os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                except Exception as e:
                    print(f"Failed to delete {file_path}. Reason: {e}")
        else:
            os.makedirs(xml_dir, exist_ok=True)
        
        zip_files = [f for f in os.listdir(zip_dir) if f.lower().endswith('.zip')]
        total_zips = len(zip_files)
        
        if total_zips == 0:
            status_label.config(text="No ZIP files found in ZIP folder.")
            start_button.config(state=tk.NORMAL)
            return

        status_label.config(text=f"Found {total_zips} ZIP files. Clearing XML folder...")
        progress_var.set(0)
        
        for i, zf in enumerate(zip_files):
            zpath = os.path.join(zip_dir, zf)
            status_label.config(text=f"Extracting {zf} ({i+1}/{total_zips})...")
            
            try:
                with zipfile.ZipFile(zpath, 'r') as zip_ref:
                    zip_ref.extractall(xml_dir)
            except Exception as e:
                print(f"Error unzipping {zf}: {e}")
                
            progress_var.set((i + 1) / total_zips * 50) # 50% for extracting
            
        status_label.config(text="Mapping and sorting XML files...")
        
        xml_paths = []
        # Get all XMLs
        for root_dir, dirs, files in os.walk(xml_dir):
            for f in files:
                if f.lower().endswith('.xml'):
                    xml_paths.append(os.path.join(root_dir, f))
                    
        # Sort strictly by filename
        xml_paths.sort(key=lambda x: os.path.basename(x))
        total_xmls = len(xml_paths)
        
        json_path = os.path.join(base_dir, 'xml_files.json')
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(xml_paths, f, indent=4)
            
        json_str = json.dumps(xml_paths, indent=4)
        root.clipboard_clear()
        root.clipboard_append(json_str)
        root.update() # keep clipboard updated
            
        progress_var.set(100)
        status_label.config(text=f"Done! Processed {total_zips} ZIPs, extracted {total_xmls} XMLs.")
        messagebox.showinfo("Success", f"Unzipped {total_zips} ZIP files.\nFound {total_xmls} XML files.\nSaved to xml_files.json and copied to clipboard.")
        start_button.config(state=tk.NORMAL)

    threading.Thread(target=task, daemon=True).start()

# GUI Setup
root = tk.Tk()
root.title(" EUDAMED XML Unzipper")
root.configure(padx=20, pady=20) # Auto-size based on content to handle high DPI displays nicely

# Set native Windows theme if available
style = ttk.Style(root)
if "vista" in style.theme_names():
    style.theme_use("vista")
elif "clam" in style.theme_names():
    style.theme_use("clam")

# A clean flat-folder icon in Base64 (Valid PNG) fallback
icon_data = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEBJREFUOE9j/P///38GCgDjQAOICRgYGBj+E6OYYdQAwzCwMhBhq8UIAxQx4H4TfA0j2gA0N/wXbAABMhxgE+EGCz4DiAwA7S00IeK0M+gAAAAASUVORK5CYII="

try:
    # Try to load the logo.png if it exists in the folder, otherwise use fallback
    if getattr(sys, 'frozen', False):
        # Running as compiled PyInstaller executable
        assets_dir = sys._MEIPASS
    else:
        # Running as a normal Python script
        assets_dir = os.path.dirname(os.path.abspath(__file__))
        
    logo_path = os.path.join(assets_dir, "logo.png")
    if os.path.exists(logo_path):
        icon_image = tk.PhotoImage(file=logo_path)
    else:
        icon_image = tk.PhotoImage(data=icon_data)
        
    # True means it applies to the taskbar icon and all windows
    root.iconphoto(True, icon_image)
    
    # Specific Windows taskbar icon fix (sometimes iconphoto isn't enough on Windows 11)
    # Using windll to set the window icon directly
    import ctypes
    hwnd = ctypes.windll.user32.GetParent(root.winfo_id())
    # Try to set the icon natively if we can
except Exception as e:
    print("Icon load error:", e)

# Styling
root.configure(bg="#ffffff")
style.configure("TProgressbar", thickness=15)
style.configure("TButton", font=("Segoe UI", 10), padding=5)

# Widgets
header = tk.Label(root, text="EUDAMED XML Unzipper", font=("Segoe UI", 16, "bold"), bg="#ffffff", fg="#003366")
header.pack(pady=(15, 5))

status_label = tk.Label(root, text="Place ZIPs in the 'ZIP' folder and click Start.", font=("Segoe UI", 10), bg="#ffffff", fg="#333333")
status_label.pack(pady=5)

progress_var = tk.DoubleVar()
progress_bar = ttk.Progressbar(root, variable=progress_var, maximum=100, mode="determinate")
progress_bar.pack(fill=tk.X, padx=30, pady=15)

start_button = ttk.Button(root, text="▶ Start Processing", command=process_zips, cursor="hand2")
start_button.pack(pady=5)

root.mainloop()