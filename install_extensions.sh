#!/usr/bin/env bash
set -euo pipefail

# -------- Config --------
INSTALL_DIR="${HOME}/comfy/ComfyUI"
# ------------------------

echo "==> Installing ComfyUI Extensions"
echo "Install dir: ${INSTALL_DIR}"
echo

mkdir -p "${INSTALL_DIR}/models/facerestore_models"
cd "${INSTALL_DIR}"

# Activate ComfyUI virtual environment (created by install.sh)
if [ -d ".venv" ]; then
	echo "==> Activating virtual environment (.venv)..."
	# shellcheck disable=SC1091
	source .venv/bin/activate
else
	echo "WARNING: .venv not found in ${INSTALL_DIR}. Using system Python/pip (may require --break-system-packages)."
fi

#COMFY MANAGER
echo "==> Installing ComfyUI-Manager..."
[ -d "custom_nodes/ComfyUI-Manager" ] && rm -rf "custom_nodes/ComfyUI-Manager"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
pip install -r custom_nodes/ComfyUI-Manager/requirements.txt

# comfyui-workspace-manager
#git clone https://github.com/11cafe/comfyui-workspace-manager.git custom_nodes/comfyui-workspace-manager

#controlnet_aux
echo "==> Installing comfyui_controlnet_aux..."
[ -d "custom_nodes/comfyui_controlnet_aux" ] && rm -rf "custom_nodes/comfyui_controlnet_aux"
git clone https://github.com/Fannovel16/comfyui_controlnet_aux custom_nodes/comfyui_controlnet_aux
pip install -r custom_nodes/comfyui_controlnet_aux/requirements.txt

#IPADAPTER
echo "==> Installing ComfyUI_IPAdapter_plus..."
[ -d "custom_nodes/ComfyUI_IPAdapter_plus" ] && rm -rf "custom_nodes/ComfyUI_IPAdapter_plus"
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus custom_nodes/ComfyUI_IPAdapter_plus

# reactor
echo "==> Installing ComfyUI-ReActor..."
[ -d "custom_nodes/ComfyUI-ReActor" ] && rm -rf "custom_nodes/ComfyUI-ReActor"
git clone https://github.com/Gourieff/ComfyUI-ReActor.git custom_nodes/ComfyUI-ReActor
python custom_nodes/ComfyUI-ReActor/install.py
# WAS node nodes
echo "==> Installing was-node-suite-comfyui..."
[ -d "custom_nodes/was-node-suite-comfyui" ] && rm -rf "custom_nodes/was-node-suite-comfyui"
git clone https://github.com/WASasquatch/was-node-suite-comfyui custom_nodes/was-node-suite-comfyui
pip install -r custom_nodes/was-node-suite-comfyui/requirements.txt

# WAS extra nodes
echo "==> Installing WAS_Extras..."
[ -d "custom_nodes/WAS_Extras" ] && rm -rf "custom_nodes/WAS_Extras"
git clone https://github.com/WASasquatch/WAS_Extras custom_nodes/WAS_Extras
if [ -f "custom_nodes/WAS_Extras/requirements.txt" ]; then
	echo "==> Installing WAS_Extras Python dependencies..."
	pip install -r custom_nodes/WAS_Extras/requirements.txt
fi

#sdxl_prompt_styler
echo "==> Installing sdxl_prompt_styler..."
[ -d "custom_nodes/sdxl_prompt_styler" ] && rm -rf "custom_nodes/sdxl_prompt_styler"
git clone https://github.com/twri/sdxl_prompt_styler custom_nodes/sdxl_prompt_styler

#image-resize-comfyui
echo "==> Installing image-resize-comfyui..."
[ -d "custom_nodes/image-resize-comfyui" ] && rm -rf "custom_nodes/image-resize-comfyui"
git clone https://github.com/palant/image-resize-comfyui custom_nodes/image-resize-comfyui

#https://github.com/BadCafeCode/masquerade-nodes-comfyui

# Impact-Pack
echo "==> Installing ComfyUI-Impact-Pack..."
[ -d "custom_nodes/ComfyUI-Impact-Pack" ] && rm -rf "custom_nodes/ComfyUI-Impact-Pack"
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack custom_nodes/ComfyUI-Impact-Pack
python custom_nodes/ComfyUI-Impact-Pack/install.py

echo "==> Installing facerestore_cf..."
[ -d "custom_nodes/facerestore_cf" ] && rm -rf "custom_nodes/facerestore_cf"
git clone https://github.com/mav-rik/facerestore_cf custom_nodes/facerestore_cf
wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth -P "${INSTALL_DIR}/models/facerestore_models/"
wget https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth -P "${INSTALL_DIR}/models/facerestore_models/"

#git clone https://github.com/pydn/ComfyUI-to-Python-Extension.git
#pip install -r ComfyUI-to-Python-Extension/requirements.txt

echo "==> Extensions installation complete!"