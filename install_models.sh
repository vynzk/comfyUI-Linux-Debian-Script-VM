#!/usr/bin/env bash
set -euo pipefail

# Try to locate ComfyUI root.
# Priority:
# 1) COMFYUI_DIR env var
# 2) If current dir has "models" folder -> assume it's ComfyUI root
# 3) If current dir has "ComfyUI/models" -> assume current is parent of ComfyUI
COMFYUI_DIR="${COMFYUI_DIR:-}"

if [[ -z "${COMFYUI_DIR}" ]]; then
  if [[ -d "./models" && -f "./main.py" ]]; then
    COMFYUI_DIR="$(pwd)"
  elif [[ -d "./ComfyUI/models" && -f "./ComfyUI/main.py" ]]; then
    COMFYUI_DIR="$(pwd)/ComfyUI"
  else
    echo "No pude detectar la carpeta de ComfyUI."
    echo "Soluciones:"
    echo "  1) Ejecuta este script dentro de la carpeta ComfyUI (donde está main.py), o"
    echo "  2) Exporta la ruta manualmente:"
    echo "     export COMFYUI_DIR=/ruta/a/ComfyUI"
    exit 1
  fi
fi

MODELS_DIR="${COMFYUI_DIR}/models"

if [[ ! -d "${MODELS_DIR}" ]]; then
  echo "Error: no existe ${MODELS_DIR}. ¿Seguro que COMFYUI_DIR apunta a ComfyUI?"
  exit 1
fi

# Map well-known model subfolders to ComfyUI/models/<folder>
# (ComfyUI uses these commonly; custom paths can also be handled).
declare -A FOLDER_MAP=(
  ["checkpoints"]="checkpoints"
  ["diffusion_models"]="diffusion_models"
  ["unet"]="unet"
  ["vae"]="vae"
  ["vae_approx"]="vae_approx"
  ["clip"]="clip"
  ["clip_vision"]="clip_vision"
  ["controlnet"]="controlnet"
  ["loras"]="loras"
  ["embeddings"]="embeddings"
  ["text_encoders"]="text_encoders"
  ["ipadapter"]="ipadapter"
  ["upscale_models"]="upscale_models"
  ["upscalers"]="upscale_models"
  ["gligen"]="gligen"
  ["hypernetworks"]="hypernetworks"
  ["photomaker"]="photomaker"
  ["style_models"]="style_models"
)

choose_target_dir() {
  local url="$1"

  # Remove querystring
  local clean="${url%%\?*}"

  # Try to infer destination from HuggingFace "split_files/.../<category>/filename"
  # Example:
  # .../split_files/diffusion_models/flux-2-klein-base-4b.safetensors
  if [[ "$clean" =~ /split_files/([^/]+)/ ]]; then
    local cat="${BASH_REMATCH[1]}"
    if [[ -n "${FOLDER_MAP[$cat]:-}" ]]; then
      echo "${MODELS_DIR}/${FOLDER_MAP[$cat]}"
      return
    fi
    # Unknown category: still place under models/<cat>
    echo "${MODELS_DIR}/${cat}"
    return
  fi

  # Try to infer by common path elements in URL
  for key in "${!FOLDER_MAP[@]}"; do
    if [[ "$clean" =~ /${key}/ ]]; then
      echo "${MODELS_DIR}/${FOLDER_MAP[$key]}"
      return
    fi
  done

  # Fallback: ask user
  echo ""
  echo "No pude inferir carpeta para:"
  echo "  $url"
  echo "Elige destino dentro de ${MODELS_DIR}:"
  echo "  1) checkpoints"
  echo "  2) diffusion_models"
  echo "  3) unet"
  echo "  4) vae"
  echo "  5) clip"
  echo "  6) clip_vision"
  echo "  7) controlnet"
  echo "  8) loras"
  echo "  9) embeddings"
  echo "  10) upscale_models"
  echo "  11) otro (escribir nombre de carpeta)"
  read -r -p "Opción: " opt

  case "$opt" in
    1)  echo "${MODELS_DIR}/checkpoints" ;;
    2)  echo "${MODELS_DIR}/diffusion_models" ;;
    3)  echo "${MODELS_DIR}/unet" ;;
    4)  echo "${MODELS_DIR}/vae" ;;
    5)  echo "${MODELS_DIR}/clip" ;;
    6)  echo "${MODELS_DIR}/clip_vision" ;;
    7)  echo "${MODELS_DIR}/controlnet" ;;
    8)  echo "${MODELS_DIR}/loras" ;;
    9)  echo "${MODELS_DIR}/embeddings" ;;
    10) echo "${MODELS_DIR}/upscale_models" ;;
    11)
        read -r -p "Nombre de carpeta dentro de models/: " custom
        custom="${custom// /_}"
        echo "${MODELS_DIR}/${custom}"
        ;;
    *)
        echo "${MODELS_DIR}/checkpoints"
        ;;
  esac
}

filename_from_url() {
  local url="$1"
  local clean="${url%%\?*}"
  echo "${clean##*/}"
}

download_one() {
  local url="$1"
  local target_dir="$2"
  local filename
  filename="$(filename_from_url "$url")"

  mkdir -p "$target_dir"
  local out="${target_dir}/${filename}"

  echo ""
  echo "==> Descargando:"
  echo "URL:      $url"
  echo "Destino:  $out"
  echo ""

  # -L follow redirects
  # -C - resume
  # --fail fail on HTTP errors
  # --retry retry transient
  curl -L --fail --retry 3 --retry-delay 2 -C - -o "$out" "$url"

  echo "OK ✅ Guardado en: $out"
}

echo "ComfyUI detectado en: ${COMFYUI_DIR}"
echo "Carpeta models en:    ${MODELS_DIR}"
echo ""
echo "Pega URLs (una por línea). Enter vacío para terminar."
echo "Ejemplo:"
echo "  https://huggingface.co/.../split_files/diffusion_models/archivo.safetensors"
echo ""

urls=()
while true; do
  read -r -p "> " line || true
  line="$(echo "$line" | xargs || true)"  # trim spaces
  [[ -z "$line" ]] && break
  urls+=("$line")
done

if [[ "${#urls[@]}" -eq 0 ]]; then
  echo "No ingresaste URLs. Saliendo."
  exit 0
fi

echo ""
echo "==> Descargando ${#urls[@]} archivo(s)..."

for u in "${urls[@]}"; do
  target="$(choose_target_dir "$u")"
  download_one "$u" "$target"
done

echo ""
echo "Listo 🎉"
echo "Si ComfyUI estaba abierto, reinícialo para que detecte nuevos modelos."
echo "Servicio (si usas systemd): sudo systemctl restart comfyui"
