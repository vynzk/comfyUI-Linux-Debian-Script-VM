#!/usr/bin/env bash
set -euo pipefail

# -------- Config --------
INSTALL_DIR="${HOME}/comfy"
REPO_URL="https://github.com/comfyanonymous/ComfyUI.git"
SERVICE_NAME="comfyui"
LISTEN_ADDR="0.0.0.0"
PORT="8188"
# ------------------------

echo "==> ComfyUI installer"
echo "Install dir: ${INSTALL_DIR}"
echo

# Basic deps
echo "==> Installing basic dependencies (git, curl, python3-venv)..."
sudo apt-get update -y
sudo apt-get install -y git curl ca-certificates python3-pip python3-venv

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

# Clone or update repo
if [ -d "${INSTALL_DIR}/ComfyUI/.git" ]; then
  echo "==> ComfyUI repo already exists. Pulling latest..."
  cd "${INSTALL_DIR}/ComfyUI"
  git pull
else
  echo "==> Cloning ComfyUI..."
  git clone "${REPO_URL}"
  cd "${INSTALL_DIR}/ComfyUI"
fi

# Create venv if not exists
if [ ! -d ".venv" ]; then
  echo "==> Creating virtual environment (.venv)..."
  python3 -m venv .venv
else
  echo "==> .venv already exists. Skipping venv creation."
fi

# Activate venv
echo "==> Activating virtual environment..."
source .venv/bin/activate

# Install PyTorch + deps
echo "==> Installing PyTorch (NVIDIA CUDA 12.9 wheels: cu129)..."
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129

# AMD option (commented)
# echo "==> Installing PyTorch for AMD ROCm 6.4..."
# pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4

echo "==> Installing ComfyUI requirements..."
pip install -r requirements.txt

# Create systemd service
echo "==> Creating systemd service: ${SERVICE_NAME}.service"

USER_NAME="$(id -un)"
WORKDIR="${INSTALL_DIR}/ComfyUI"

SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

SERVICE_CONTENT="[Unit]
Description=ComfyUI Server
After=network.target

[Service]
Type=simple
User=${USER_NAME}
WorkingDirectory=${WORKDIR}
ExecStart=${WORKDIR}/.venv/bin/python main.py --listen ${LISTEN_ADDR}
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
"

echo "==> Writing ${SERVICE_FILE} (requires sudo)..."
echo "${SERVICE_CONTENT}" | sudo tee "${SERVICE_FILE}" >/dev/null

echo "==> Reloading systemd and enabling service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}"
sudo systemctl restart "${SERVICE_NAME}"

echo
echo "==> Done!"
echo "ComfyUI should now start automatically on boot."
echo
echo "Check status:"
echo "  systemctl status ${SERVICE_NAME}"
echo
echo "Follow logs:"
echo "  journalctl -u ${SERVICE_NAME} -f"
echo
echo "Access (if firewall allows):"
echo "  http://<VM_IP>:${PORT}"
