#!/bin/bash
# Instalación MINIMAL para DWM en CachyOS
# Solo lo esencial, sin bloat de DE

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[→]${NC} $1"; }

echo "=== Instalación MINIMAL para DWM ==="
echo ""

# Actualizar sistema
print_info "Actualizando sistema..."
sudo pacman -Syu --noconfirm

# Instalar paru
if ! command -v paru &> /dev/null; then
    print_info "Instalando paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd ~
fi

# ========================================
# XORG Y DWM
# ========================================
print_info "Instalando Xorg y DWM..."
sudo pacman -S --needed --noconfirm \
    xorg xorg-xinit \
    xorg-xrandr xorg-xsetroot xorg-xprop \
    libx11 libxft libxinerama \
    dmenu st

# Clonar DWM, dmenu, st
print_info "Clonando suckless tools..."
mkdir -p ~/suckless
cd ~/suckless

if [ ! -d "dwm" ]; then
    git clone https://git.suckless.org/dwm
fi
if [ ! -d "dmenu" ]; then
    git clone https://git.suckless.org/dmenu
fi
if [ ! -d "st" ]; then
    git clone https://git.suckless.org/st
fi

print_status "Suckless tools clonados"

# ========================================
# DRIVERS NVIDIA
# ========================================
print_info "Instalando drivers NVIDIA..."
sudo pacman -S --needed --noconfirm \
    nvidia nvidia-utils nvidia-settings \
    opencl-nvidia cuda cudnn \
    nvtop

print_status "NVIDIA instalado"

# ========================================
# UTILIDADES ESENCIALES (sin bloat)
# ========================================
print_info "Instalando utilidades esenciales..."
sudo pacman -S --needed --noconfirm \
    picom \
    nitrogen \
    dunst \
    rofi \
    kitty \
    thunar thunar-volman gvfs gvfs-mtp \
    lxappearance \
    network-manager-applet \
    pavucontrol pipewire pipewire-pulse wireplumber \
    blueman \
    flameshot \
    xautolock \
    brightnessctl \
    playerctl \
    copyq \
    arandr \
    xclip xdotool

print_status "Utilidades instaladas"

# ========================================
# FUENTES
# ========================================
print_info "Instalando fuentes..."
sudo pacman -S --needed --noconfirm \
    ttf-dejavu ttf-liberation \
    noto-fonts noto-fonts-emoji \
    ttf-font-awesome

paru -S --needed --noconfirm \
    nerd-fonts-jetbrains-mono

print_status "Fuentes instaladas"

# ========================================
# ICONOS Y TEMAS
# ========================================
print_info "Instalando temas..."
sudo pacman -S --needed --noconfirm \
    papirus-icon-theme \
    arc-gtk-theme \
    lxappearance-gtk3

print_status "Temas instalados"

# ========================================
# DESARROLLO
# ========================================
print_info "Instalando herramientas de desarrollo..."
sudo pacman -S --needed --noconfirm \
    git base-devel \
    python python-pip python-virtualenv \
    nodejs npm \
    docker docker-compose docker-buildx \
    neovim \
    zsh zsh-completions \
    ripgrep fd bat eza fzf \
    tmux \
    htop btop nvtop neofetch

print_status "Desarrollo instalado"

# ========================================
# APLICACIONES
# ========================================
print_info "Instalando aplicaciones..."
paru -S --needed --noconfirm \
    brave-bin \
    visual-studio-code-bin \
    spotify \
    discord

print_status "Aplicaciones instaladas"

# ========================================
# SERVICIOS
# ========================================
print_info "Habilitando servicios..."
sudo systemctl enable --now docker
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo usermod -aG docker $USER

print_status "Servicios configurados"

# ========================================
# CREAR ESTRUCTURA
# ========================================
print_info "Creando estructura de directorios..."
mkdir -p ~/Projects/{Python,WebDev,AI,Automation}
mkdir -p ~/Pictures/{Wallpapers,Screenshots}
mkdir -p ~/Documents
mkdir -p ~/.local/{bin,share}
mkdir -p ~/.config
mkdir -p ~/.dwm

print_status "Estructura creada"

# ========================================
# XINITRC
# ========================================
print_info "Creando .xinitrc..."
cat > ~/.xinitrc <<'EOF'
#!/bin/sh

# Cargar recursos
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# Start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Ejecutar DWM
exec dwm
EOF

chmod +x ~/.xinitrc

print_status ".xinitrc creado"

# ========================================
# XRESOURCES BASE
# ========================================
print_info "Creando .Xresources base..."
cat > ~/.Xresources <<'EOF'
! Xft settings
Xft.dpi: 96
Xft.antialias: true
Xft.hinting: true
Xft.rgba: rgb
Xft.autohint: false
Xft.hintstyle: hintslight
Xft.lcdfilter: lcddefault

! Cursor
Xcursor.theme: Adwaita
Xcursor.size: 16
EOF

print_status ".Xresources creado"

# ========================================
# SENSORES (para temperatura)
# ========================================
print_info "Configurando sensores..."
sudo pacman -S --needed --noconfirm lm_sensors
yes | sudo sensors-detect

print_status "Sensores configurados"

# ========================================
# RESUMEN
# ========================================
echo ""
echo "========================================"
print_status "Instalación MINIMAL completada!"
echo "========================================"
echo ""
echo "Instalado:"
echo "  ✓ Xorg + drivers NVIDIA"
echo "  ✓ Suckless tools (dwm, dmenu, st) - SIN compilar"
echo "  ✓ Picom, rofi, dunst, nitrogen"
echo "  ✓ Thunar (file manager ligero)"
echo "  ✓ NetworkManager, pavucontrol, blueman"
echo "  ✓ Docker, Python, Node.js"
echo "  ✓ VS Code, Brave, Spotify, Discord"
echo ""
echo "SIN instalar:"
echo "  ✗ XFCE4 o cualquier DE"
echo "  ✗ Display manager (GDM, SDDM, LightDM)"
echo "  ✗ Paquetes innecesarios"
echo ""
echo "Siguiente paso:"
echo "1. cd ~/suckless/dwm"
echo "2. Ejecuta dwm-mega-patch.sh"
echo "3. sudo make clean install"
echo "4. Ejecuta dwmblocks-setup.sh"
echo "5. Reinicia y ejecuta: startx"
echo ""
print_info "Tu sistema está LIMPIO y listo para DWM"
echo ""
