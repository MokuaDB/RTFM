#!/bin/bash
# DWM MEGA AUTOPATCH - Setup Profesional Completo
# Incluye: estética, productividad, auto-darkmode, xresources

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[→]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

if [ ! -f "dwm.c" ]; then
    print_error "No estás en el directorio de DWM"
    exit 1
fi

echo "╔════════════════════════════════════════╗"
echo "║   DWM MEGA AUTOPATCH - Setup Pro      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Backup
print_info "Creando backup..."
cp -r . ../dwm-backup-mega-$(date +%Y%m%d-%H%M%S)
print_status "Backup creado"

mkdir -p patches
cd patches

# ========================================
# FASE 1: ESTÉTICA DE BARRA
# ========================================
echo ""
print_info "=== FASE 1: Estética de Barra ==="

# Bar height
print_info "Descargando bar-height..."
wget -q https://dwm.suckless.org/patches/bar-height/dwm-bar-height-6.2.diff
cd .. && patch -p1 < patches/dwm-bar-height-6.2.diff && cd patches
print_status "bar-height aplicado"

# Bar padding
print_info "Descargando barpadding..."
wget -q https://dwm.suckless.org/patches/barpadding/dwm-barpadding-20211020-a786211.diff
cd .. && patch -p1 < patches/dwm-barpadding-20211020-a786211.diff && cd patches
print_status "barpadding aplicado"

# Status padding
print_info "Descargando statuspadding..."
wget -q https://dwm.suckless.org/patches/statuspadding/dwm-statuspadding-6.3.diff
cd .. && patch -p1 < patches/dwm-statuspadding-6.3.diff && cd patches
print_status "statuspadding aplicado"

# Status colors
print_info "Descargando statuscolors..."
wget -q https://dwm.suckless.org/patches/statuscolors/dwm-statuscolors-20181008-b69c870.diff
cd .. && patch -p1 < patches/dwm-statuscolors-20181008-b69c870.diff && cd patches
print_status "statuscolors aplicado"

# Underline tags
print_info "Descargando underlinetags..."
wget -q https://dwm.suckless.org/patches/underlinetags/dwm-underlinetags-6.2.diff
cd .. && patch -p1 < patches/dwm-underlinetags-6.2.diff && cd patches
print_status "underlinetags aplicado"

# Hide vacant tags
print_info "Descargando hide_vacant_tags..."
wget -q https://dwm.suckless.org/patches/hide_vacant_tags/dwm-hide_vacant_tags-6.3.diff
cd .. && patch -p1 < patches/dwm-hide_vacant_tags-6.3.diff && cd patches
print_status "hide_vacant_tags aplicado"

# ========================================
# FASE 2: XRESOURCES Y TEMAS
# ========================================
echo ""
print_info "=== FASE 2: Xresources y Temas ==="

# Xresources
print_info "Descargando xresources..."
wget -q https://dwm.suckless.org/patches/xresources/dwm-xresources-20210827-138b405.diff
cd .. && patch -p1 < patches/dwm-xresources-20210827-138b405.diff && cd patches
print_status "xresources aplicado"

# ========================================
# FASE 3: GESTIÓN DE VENTANAS
# ========================================
echo ""
print_info "=== FASE 3: Gestión de Ventanas ==="

# Vanitygaps
print_info "Descargando vanitygaps..."
wget -q https://dwm.suckless.org/patches/vanitygaps/dwm-vanitygaps-20200610-f09418b.diff
cd .. && patch -p1 < patches/dwm-vanitygaps-20200610-f09418b.diff && cd patches
print_status "vanitygaps aplicado"

# Actualfullscreen vs Fakefullscreen
read -p "¿Usar fakefullscreen (mantiene barra) en lugar de actualfullscreen? (s/n): " use_fake

if [[ $use_fake == "s" || $use_fake == "S" ]]; then
    print_info "Descargando fakefullscreen..."
    wget -q https://dwm.suckless.org/patches/fakefullscreen/dwm-fakefullscreen-20210714-138b405.diff
    cd .. && patch -p1 < patches/dwm-fakefullscreen-20210714-138b405.diff && cd patches
    print_status "fakefullscreen aplicado"
else
    print_info "Descargando actualfullscreen..."
    wget -q https://dwm.suckless.org/patches/actualfullscreen/dwm-actualfullscreen-20211013-cb3f58a.diff
    cd .. && patch -p1 < patches/dwm-actualfullscreen-20211013-cb3f58a.diff && cd patches
    print_status "actualfullscreen aplicado"
fi

# Systray
print_info "Descargando systray..."
wget -q https://dwm.suckless.org/patches/systray/dwm-systray-20230922-9f88553.diff
cd .. && patch -p1 < patches/dwm-systray-20230922-9f88553.diff && cd patches
print_status "systray aplicado"

# Pertag
print_info "Descargando pertag..."
wget -q https://dwm.suckless.org/patches/pertag/dwm-pertag-20200914-61bb8b2.diff
cd .. && patch -p1 < patches/dwm-pertag-20200914-61bb8b2.diff && cd patches
print_status "pertag aplicado"

# Sticky
print_info "Descargando sticky..."
wget -q https://dwm.suckless.org/patches/sticky/dwm-sticky-20160911-ab9571b.diff
cd .. && patch -p1 < patches/dwm-sticky-20160911-ab9571b.diff && cd patches
print_status "sticky aplicado"

# Swallow
print_info "Descargando swallow..."
wget -q https://dwm.suckless.org/patches/swallow/dwm-swallow-20201211-61bb8b2.diff
cd .. && patch -p1 < patches/dwm-swallow-20201211-61bb8b2.diff && cd patches
print_status "swallow aplicado"

# Cyclelayouts
print_info "Descargando cyclelayouts..."
wget -q https://dwm.suckless.org/patches/cyclelayouts/dwm-cyclelayouts-20180524-6.2.diff
cd .. && patch -p1 < patches/dwm-cyclelayouts-20180524-6.2.diff && cd patches
print_status "cyclelayouts aplicado"

# Focus on net active
print_info "Descargando focusonnetactive..."
wget -q https://dwm.suckless.org/patches/focusonnetactive/dwm-focusonnetactive-6.2.diff
cd .. && patch -p1 < patches/dwm-focusonnetactive-6.2.diff && cd patches
print_status "focusonnetactive aplicado"

# Warp
print_info "Descargando warp..."
wget -q https://dwm.suckless.org/patches/warp/dwm-warp-20210816-8d3e7ca.diff
cd .. && patch -p1 < patches/dwm-warp-20210816-8d3e7ca.diff && cd patches
print_status "warp aplicado"

# Rotatestack
print_info "Descargando rotatestack..."
wget -q https://dwm.suckless.org/patches/rotatestack/dwm-rotatestack-20161021-ab9571b.diff
cd .. && patch -p1 < patches/dwm-rotatestack-20161021-ab9571b.diff && cd patches
print_status "rotatestack aplicado"

# Resize corners
print_info "Descargando resizecorners..."
wget -q https://dwm.suckless.org/patches/resizecorners/dwm-resizecorners-6.2.diff
cd .. && patch -p1 < patches/dwm-resizecorners-6.2.diff && cd patches
print_status "resizecorners aplicado"

# Attachaside
print_info "Descargando attachaside..."
wget -q https://dwm.suckless.org/patches/attachaside/dwm-attachaside-6.2.diff
cd .. && patch -p1 < patches/dwm-attachaside-6.2.diff && cd patches
print_status "attachaside aplicado"

# ========================================
# FASE 4: SISTEMA
# ========================================
echo ""
print_info "=== FASE 4: Sistema ==="

# Autostart
print_info "Descargando autostart..."
wget -q https://dwm.suckless.org/patches/autostart/dwm-autostart-20210120-cb3f58a.diff
cd .. && patch -p1 < patches/dwm-autostart-20210120-cb3f58a.diff && cd patches
print_status "autostart aplicado"

# Restartsig
print_info "Descargando restartsig..."
wget -q https://dwm.suckless.org/patches/restartsig/dwm-restartsig-20180523-6.2.diff
cd .. && patch -p1 < patches/dwm-restartsig-20180523-6.2.diff && cd patches
print_status "restartsig aplicado"

# Scratchpad (opcional)
read -p "¿Instalar scratchpad (terminal dropdown)? (s/n): " install_scratch
if [[ $install_scratch == "s" || $install_scratch == "S" ]]; then
    print_info "Descargando scratchpad..."
    wget -q https://dwm.suckless.org/patches/scratchpad/dwm-scratchpad-20221102-ba56fe9.diff
    cd .. && patch -p1 < patches/dwm-scratchpad-20221102-ba56fe9.diff && cd patches
    print_status "scratchpad aplicado"
fi

cd ..

# ========================================
# COMPILAR
# ========================================
echo ""
print_info "Compilando DWM..."
if sudo make clean install; then
    print_status "DWM compilado e instalado"
else
    print_error "Error al compilar, revisar conflictos"
    exit 1
fi

# ========================================
# CONFIGURAR XRESOURCES
# ========================================
echo ""
print_info "Creando archivos .Xresources..."

# Tema oscuro (Dracula)
cat > ~/.Xresources.dark <<'EOF'
! DWM - Tema Oscuro (Dracula)
dwm.normbgcolor: #282a36
dwm.normbordercolor: #44475a
dwm.normfgcolor: #f8f8f2
dwm.selfgcolor: #f8f8f2
dwm.selbordercolor: #bd93f9
dwm.selbgcolor: #bd93f9
dwm.borderpx: 2
dwm.snap: 32
dwm.showbar: 1
dwm.topbar: 1
dwm.bar_height: 32
dwm.bar_padding: 8
dwm.status_padding: 12
dwm.gappx: 12
EOF

# Tema claro
cat > ~/.Xresources.light <<'EOF'
! DWM - Tema Claro
dwm.normbgcolor: #f8f8f2
dwm.normbordercolor: #e0e0e0
dwm.normfgcolor: #282a36
dwm.selfgcolor: #ffffff
dwm.selbordercolor: #6272a4
dwm.selbgcolor: #6272a4
dwm.borderpx: 2
dwm.snap: 32
dwm.showbar: 1
dwm.topbar: 1
dwm.bar_height: 32
dwm.bar_padding: 8
dwm.status_padding: 12
dwm.gappx: 12
EOF

# Copiar tema oscuro por defecto
cp ~/.Xresources.dark ~/.Xresources
xrdb -merge ~/.Xresources

print_status "Xresources configurados"

# ========================================
# CREAR SCRIPT AUTO-DARKMODE
# ========================================
echo ""
print_info "Creando script auto-darkmode..."

mkdir -p ~/.local/bin

cat > ~/.local/bin/dwm-auto-theme <<'EOF'
#!/bin/bash
# Auto cambio de tema DWM según hora del día

HOUR=$(date +%H)
XRESOURCES=~/.Xresources

if [ $HOUR -ge 6 -a $HOUR -lt 18 ]; then
    # Tema claro (6:00 - 17:59)
    cp ~/.Xresources.light $XRESOURCES
else
    # Tema oscuro (18:00 - 5:59)
    cp ~/.Xresources.dark $XRESOURCES
fi

xrdb -merge $XRESOURCES
pkill -HUP dwm 2>/dev/null  # Recarga DWM (restartsig patch)
EOF

chmod +x ~/.local/bin/dwm-auto-theme

print_status "Script auto-darkmode creado"

# Añadir a crontab
print_info "¿Añadir auto-darkmode a crontab (cambio automático cada hora)?"
read -p "(s/n): " add_cron

if [[ $add_cron == "s" || $add_cron == "S" ]]; then
    (crontab -l 2>/dev/null; echo "0 * * * * ~/.local/bin/dwm-auto-theme") | crontab -
    print_status "Auto-darkmode añadido a crontab"
fi

# ========================================
# CREAR AUTOSTART.SH
# ========================================
echo ""
print_info "Creando autostart.sh..."

cat > ~/.dwm/autostart.sh <<'EOF'
#!/bin/bash

# dwmblocks (barra de estado)
dwmblocks &

# Picom (compositor)
picom &

# Wallpaper
nitrogen --restore &

# Network Manager
nm-applet &

# Bluetooth
blueman-applet &

# Volume icon (opcional)
# volumeicon &

# Auto-darkmode (aplicar tema inicial)
~/.local/bin/dwm-auto-theme &

# Notificaciones
dunst &
EOF

chmod +x ~/.dwm/autostart.sh

print_status "autostart.sh creado"

# ========================================
# RESUMEN FINAL
# ========================================
echo ""
echo "╔════════════════════════════════════════╗"
echo "║     ✓ DWM MEGA SETUP COMPLETADO       ║"
echo "╚════════════════════════════════════════╝"
echo ""
print_status "Parches aplicados exitosamente:"
echo ""
echo "📊 ESTÉTICA DE BARRA:"
echo "  ✓ bar-height, barpadding, statuspadding"
echo "  ✓ statuscolors (colores en dwmblocks)"
echo "  ✓ underlinetags + hide_vacant_tags"
echo ""
echo "🎨 TEMAS:"
echo "  ✓ xresources (recarga temas sin recompilar)"
echo "  ✓ auto-darkmode (cambio automático día/noche)"
echo ""
echo "🪟 GESTIÓN DE VENTANAS:"
echo "  ✓ vanitygaps, systray, pertag, sticky"
echo "  ✓ swallow, cyclelayouts, warp"
echo "  ✓ rotatestack, resizecorners, attachaside"
echo "  ✓ focusonnetactive"
if [[ $use_fake == "s" ]]; then
    echo "  ✓ fakefullscreen"
else
    echo "  ✓ actualfullscreen"
fi
if [[ $install_scratch == "s" ]]; then
    echo "  ✓ scratchpad"
fi
echo ""
echo "⚙️  SISTEMA:"
echo "  ✓ autostart (ejecuta ~/.dwm/autostart.sh)"
echo "  ✓ restartsig (reinicio sin cerrar sesión)"
echo ""
echo "📁 ARCHIVOS CREADOS:"
echo "  ~/.Xresources.dark"
echo "  ~/.Xresources.light"
echo "  ~/.local/bin/dwm-auto-theme"
echo "  ~/.dwm/autostart.sh"
echo ""
echo "⌨️  NUEVOS ATAJOS:"
echo "  Super + Tab        - Cycle layouts"
echo "  Super + Shift + J/K - Rotate stack"
echo "  Super + -/=        - Ajustar gaps"
echo "  Super + Shift + -/= - Reset gaps"
echo "  Super + S          - Toggle sticky"
if [[ $install_scratch == "s" ]]; then
    echo "  Super + `          - Toggle scratchpad"
fi
echo "  Super + Shift + R  - Reiniciar DWM (sin cerrar apps)"
echo ""
print_warning "SIGUIENTE PASO:"
echo "1. Edita config.h si necesitas ajustes"
echo "2. Ejecuta: dwm-auto-theme (aplicar tema actual)"
echo "3. Reinicia DWM: Super + Shift + Q"
echo ""
print_info "Para cambiar tema manualmente:"
echo "  cp ~/.Xresources.dark ~/.Xresources && xrdb -merge ~/.Xresources && pkill -HUP dwm"
echo ""
