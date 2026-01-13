#!/usr/bin/env bash
# =====================================================================
# CachyOS HP Omen – ROBUST VIRGIN INSTALL
# NVIDIA OPEN + BSPWM + X11
# =====================================================================

set -Eeuo pipefail
trap 'echo "❌ ERROR on line $LINENO"; exit 1' ERR

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
  echo "ERROR: Run as root"
  exit 1
fi

if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "ERROR: No internet"
  exit 1
fi

echo "[OK] Root + Internet"

# =====================================================================
# BASE SYSTEM
# =====================================================================
echo "==> System sync"
pacman -Syyu --noconfirm

pacman -S --noconfirm \
  base-devel \
  git curl wget \
  networkmanager \
  xdg-user-dirs

systemctl enable NetworkManager

# =====================================================================
# NVIDIA OPEN – SAFE DETECTION
# =====================================================================
echo "==> NVIDIA Open detection"

# Remove legacy NVIDIA if present
for pkg in nvidia nvidia-dkms nvidia-580xx-dkms; do
  if pacman -Q "$pkg" &>/dev/null; then
    pacman -Rns --noconfirm "$pkg"
  fi
done

# Detect available NVIDIA Open kernel
if pacman -Ss linux-cachyos | grep -q nvidia-open; then
  echo "[OK] NVIDIA Open kernel found"
  pacman -S --noconfirm linux-cachyos-lts-nvidia-open nvidia-utils nvidia-settings
else
  echo "❌ NVIDIA Open kernel NOT found in repos"
  echo "Run: pacman -Ss nvidia-open"
  exit 1
fi

# Blacklist nouveau
cat >/etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
options nouveau modeset=0
EOF

# =====================================================================
# BOOTLOADER SAFE HANDLING
# =====================================================================
echo "==> Bootloader handling"

if command -v grub-mkconfig &>/dev/null; then
  sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1 /' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
elif [[ -d /boot/loader/entries ]]; then
  echo "systemd-boot detected"
  for entry in /boot/loader/entries/*.conf; do
    sed -i 's/^options /options nvidia_drm.modeset=1 /' "$entry"
  done
else
  echo "⚠️ No bootloader config modified"
fi

mkinitcpio -P

# =====================================================================
# X11 + BSPWM MINIMAL
# =====================================================================
echo "==> X11 + BSPWM"

pacman -S --noconfirm \
  xorg-server xorg-xinit \
  bspwm sxhkd \
  kitty picom rofi dunst \
  pipewire pipewire-pulse wireplumber \
  firefox zsh

chsh -s /bin/zsh "$USER_NAME"

# =====================================================================
# USER CONFIG
# =====================================================================
runuser -u "$USER_NAME" -- mkdir -p \
  "$CONFIG_DIR"/{bspwm,sxhkd,picom}

cat >"$USER_HOME/.xinitrc" <<'EOF'
#!/bin/sh
exec bspwm
EOF
chmod +x "$USER_HOME/.xinitrc"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/.xinitrc"

cat >"$CONFIG_DIR/bspwm/bspwmrc" <<'EOF'
#!/bin/sh
sxhkd &
picom &
exec bspwm
EOF
chmod +x "$CONFIG_DIR/bspwm/bspwmrc"

cat >"$CONFIG_DIR/sxhkd/sxhkdrc" <<'EOF'
super + Return
	kitty
super + d
	rofi -show drun
EOF

# =====================================================================
# FINAL
# =====================================================================
echo "================================================="
echo "SETUP FINISHED"
echo "Check log: setup.log"
echo
echo "Reboot → login → startx"
echo "Verify: nvidia-smi"
echo "================================================="
