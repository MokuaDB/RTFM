#!/usr/bin/env bash
# =====================================================================
# CachyOS HP Omen – Ryzen AI 7 + NVIDIA RTX (OPEN MODULES)
# BSPWM + X11 ONLY + DEV + SECURITY + LOCAL AI READY
# =====================================================================

set -euo pipefail

# ---------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
CONFIG_DIR="$USER_HOME/.config"

# ---------------------------------------------------------------------
# CHECKS
# ---------------------------------------------------------------------
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)."
  exit 1
fi

if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "ERROR: No internet connection."
  exit 1
fi

echo "[OK] Root + Internet detected"

# =====================================================================
# BASE DEL SISTEMA
# =====================================================================
echo "==> Base system"

pacman -Syu --noconfirm

pacman -S --noconfirm \
  base-devel \
  linux-cachyos-lts-nvidia-open \
  linux-cachyos-lts-headers \
  git curl wget unzip zip \
  networkmanager \
  bluez bluez-utils \
  openssh samba nmap tcpdump \
  qemu-full virt-manager dnsmasq bridge-utils \
  apparmor audit

systemctl enable NetworkManager bluetooth libvirtd apparmor auditd

# =====================================================================
# NVIDIA OPEN (CRÍTICO – SIN DKMS)
# =====================================================================
echo "==> NVIDIA Open Kernel Modules"

# Eliminar cualquier resto DKMS o drivers clásicos
pacman -Rns --noconfirm \
  nvidia-dkms \
  nvidia-580xx-dkms \
  nvidia || true

pacman -S --noconfirm \
  nvidia-utils \
  nvidia-settings \
  lib32-nvidia-utils

# Blacklist nouveau (obligatorio incluso con open modules)
cat >/etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
options nouveau modeset=0
EOF

# NVIDIA DRM
if ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
  sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1 /' /etc/default/grub
fi

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

# Forzar X11 (evitar Wayland)
mkdir -p /etc/environment.d
echo "XDG_SESSION_TYPE=x11" >/etc/environment.d/99-x11.conf

# =====================================================================
# X11 + BSPWM
# =====================================================================
echo "==> X11 + BSPWM"

pacman -S --noconfirm \
  xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
  bspwm sxhkd \
  kitty \
  picom \
  rofi \
  dunst \
  thunar thunar-archive-plugin file-roller \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  pamixer brightnessctl \
  feh \
  network-manager-applet blueman

# =====================================================================
# APPS
# =====================================================================
pacman -S --noconfirm \
  firefox \
  obsidian \
  zsh \
  neovim

chsh -s /bin/zsh "$USER_NAME"

# =====================================================================
# DESARROLLO + IA LOCAL (BASE)
# =====================================================================
pacman -S --noconfirm \
  python python-pip python-virtualenv pipx \
  docker docker-compose

systemctl enable docker
usermod -aG docker "$USER_NAME"

# Base para IA local (NO descarga modelos)
# Ollama vía Docker (estable y aislado)
docker pull ollama/ollama

# =====================================================================
# SEGURIDAD BASE (SIN ROMPER DESKTOP)
# =====================================================================
echo "==> Security baseline"

# SSH hardening mínimo
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl enable sshd

# =====================================================================
# CONFIGURACIONES DE USUARIO
# =====================================================================
echo "==> User configuration files"

runuser -u "$USER_NAME" -- mkdir -p \
  "$CONFIG_DIR"/{bspwm,sxhkd,picom,kitty,rofi,dunst,nvim}

# -----------------------------
# .xinitrc
# -----------------------------
cat >"$USER_HOME/.xinitrc" <<'EOF'
#!/bin/sh
exec bspwm
EOF
chmod +x "$USER_HOME/.xinitrc"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/.xinitrc"

# -----------------------------
# BSPWM
# -----------------------------
cat >"$CONFIG_DIR/bspwm/bspwmrc" <<'EOF'
#!/bin/sh
sxhkd &
picom --config ~/.config/picom/picom.conf &
nm-applet &
blueman-applet &
dunst &
bspc monitor -d I II III IV V VI VII VIII IX X
bspc config border_width 2
bspc config window_gap 12
bspc config focus_follows_pointer true
EOF
chmod +x "$CONFIG_DIR/bspwm/bspwmrc"

# -----------------------------
# SXHKD
# -----------------------------
cat >"$CONFIG_DIR/sxhkd/sxhkdrc" <<'EOF'
super + Return
	kitty
super + d
	rofi -show drun
super + q
	bspc node -c
super + Escape
	bspc quit
EOF

# -----------------------------
# Picom (NVIDIA OPEN SAFE)
# -----------------------------
cat >"$CONFIG_DIR/picom/picom.conf" <<'EOF'
backend = "glx";
vsync = true;
use-damage = true;
unredir-if-possible = false;
glx-no-stencil = true;
glx-no-rebind-pixmap = true;
EOF

# -----------------------------
# Kitty
# -----------------------------
cat >"$CONFIG_DIR/kitty/kitty.conf" <<'EOF'
font_family monospace
font_size 11
enable_audio_bell no
EOF

# -----------------------------
# Rofi
# -----------------------------
cat >"$CONFIG_DIR/rofi/config.rasi" <<'EOF'
configuration {
  modi: "drun";
  show-icons: true;
}
EOF

# -----------------------------
# Dunst
# -----------------------------
cat >"$CONFIG_DIR/dunst/dunstrc" <<'EOF'
[global]
geometry = "300x5-10+10"
frame_width = 2
EOF

# -----------------------------
# ZSH + Oh My Zsh
# -----------------------------
runuser -u "$USER_NAME" -- bash <<'EOF'
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true
EOF

cat >"$USER_HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
EOF
chown "$USER_NAME:$USER_NAME" "$USER_HOME/.zshrc"

# -----------------------------
# Neovim (LSP + Treesitter)
# -----------------------------
cat >"$CONFIG_DIR/nvim/init.lua" <<'EOF'
require("lazy").setup({
  {"neovim/nvim-lspconfig"},
  {"nvim-treesitter/nvim-treesitter", build=":TSUpdate"},
  {"nvim-telescope/telescope.nvim", dependencies={"nvim-lua/plenary.nvim"}},
  {"windwp/nvim-autopairs"},
  {"lewis6991/gitsigns.nvim"}
})
require("lspconfig").pyright.setup({})
require("lspconfig").lua_ls.setup({})
EOF

# =====================================================================
# FINAL
# =====================================================================
echo "====================================================="
echo "SETUP COMPLETED SUCCESSFULLY"
echo "====================================================="
echo
echo "POST-INSTALL:"
echo "  reboot"
echo "  login on TTY"
echo "  startx"
echo
echo "VERIFY:"
echo "  nvidia-smi"
echo "  lsmod | grep nvidia"
echo
echo "LOCAL AI:"
echo "  docker run -d -p 11434:11434 --name ollama ollama/ollama"
echo
echo "DONE."
