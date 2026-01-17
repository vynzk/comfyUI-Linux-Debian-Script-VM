
# ComfyUI Auto Installer + Autorun (Linux)

Este repositorio/script instala **ComfyUI** desde cero y lo configura para que **se inicie automáticamente** cada vez que arranca la máquina virtual usando **systemd**.

Funciona idealmente en:
- Debian / Ubuntu
- Máquinas virtuales (local, Google Cloud, AWS, etc.)
- GPUs NVIDIA (CUDA) o AMD (ROCm)

---

## ✨ Qué hace este instalador

El ejecutable `install` realiza automáticamente:

- Clona el repositorio oficial de **ComfyUI**
- Instala `uv` (gestor moderno de Python)
- Crea un entorno virtual (`.venv`)
- Instala PyTorch según tu GPU
- Instala las dependencias de ComfyUI
- Crea un servicio **systemd**
- Configura ComfyUI para iniciar en cada arranque del sistema

---

## Servicio creado
/etc/systemd/system/comfyui.service

## ⚙️ Requisitos

- Linux (Debian / Ubuntu)
- Acceso a sudo

- Conexión a internet

### GPU compatible:
- NVIDIA (CUDA 12.9 recomendado)
- AMD (ROCm 6.4)

## ⚠️ Si usas Google Cloud / AWS:

Asegúrate de abrir el puerto 8188 en el firewall.

## 🔄 Control del servicio
Ver estado

```systemctl status comfyui```

Ver logs en tiempo real
```journalctl -u comfyui -f```

Reiniciar ComfyUI
```sudo systemctl restart comfyui```

Detener ComfyUI
```sudo systemctl stop comfyui```

Deshabilitar arranque automático
```sudo systemctl disable comfyui```

## 🎮 GPU: NVIDIA vs AMD
### NVIDIA (por defecto)

Se instala PyTorch con CUDA 12.9:

https://download.pytorch.org/whl/cu129

### AMD (ROCm)

Edita el script install y descomenta:

```uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4```


Y comenta la línea de NVIDIA.

## 🧠 Detalles técnicos

El servicio usa:

Restart=always → se reinicia si falla

--listen 0.0.0.0 → accesible desde red

No requiere sesión gráfica ni terminal abierta

## ❗ Problemas comunes
### ❌ No puedo acceder desde el navegador

Revisa firewall

Verifica IP pública de la VM

Confirma que el servicio esté activo

### ❌ uv no encontrado

Verifica con:

which uv

El script ya usa la ruta absoluta automáticamente

# Cómo instalar modelos rápidamente
aplica
```
chmod +x install_models.sh #sólo una vez

```
luego ejecuta cuando necesites
```
./install_models
```
copia las URLs solicitadas en cada línea y cuando termines aplica doble enter para que las descargue
