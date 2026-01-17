#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
COMFY_DIR="${1:-$PWD}/ComfyUI"   # Puedes pasar la ruta como argumento: ./install_comfy_manager.sh /ruta/ComfyUI
CUSTOM_NODES_DIR="$COMFY_DIR/custom_nodes"
MANAGER_DIR="$CUSTOM_NODES_DIR/ComfyUI-Manager"

echo "==> ComfyUI dir: $COMFY_DIR"

# --- Checks ---
if [[ ! -d "$COMFY_DIR" ]]; then
  echo "ERROR: No existe la carpeta: $COMFY_DIR"
  exit 1
fi

if [[ ! -d "$CUSTOM_NODES_DIR" ]]; then
  echo "ERROR: No existe: $CUSTOM_NODES_DIR"
  echo "Asegurate de apuntar a la carpeta base de ComfyUI (donde esta main.py)."
  exit 1
fi

# --- Install git if missing ---
if ! command -v git >/dev/null 2>&1; then
  echo "==> Git no esta instalado. Instalando..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y git
  else
    echo "ERROR: No encuentro apt-get. Instala git manualmente."
    exit 1
  fi
fi

# --- Clone or update Manager ---
mkdir -p "$CUSTOM_NODES_DIR"

if [[ -d "$MANAGER_DIR/.git" ]]; then
  echo "==> ComfyUI-Manager ya existe. Actualizando..."
  git -C "$MANAGER_DIR" pull --rebase
else
  echo "==> Instalando ComfyUI-Manager..."
  git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
fi

# --- Optional: install python requirements if present ---
REQ1="$MANAGER_DIR/requirements.txt"
REQ2="$MANAGER_DIR/requirements/requirements.txt"

echo "==> Instalando dependencias (si aplica)..."
if [[ -f "$REQ1" ]]; then
  python3 -m pip install -U pip
  python3 -m pip install -r "$REQ1" || true
elif [[ -f "$REQ2" ]]; then
  python3 -m pip install -U pip
  python3 -m pip install -r "$REQ2" || true
else
  echo "   (No requirements.txt detectado, seguimos.)"
fi

echo ""
echo "✅ Listo. Reinicia ComfyUI."
echo "Luego deberias ver un boton/menu 'Manager' en la interfaz."
