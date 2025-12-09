#!/bin/bash
# DWM MEGA AUTOPATCH - Versión Robusta
# Con mejor manejo de errores

set -e  # Salir si hay error
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" falló con código $?"' ERR

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[→]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Función para aplicar parche de forma segura
apply_patch() {
    local patch_name="$1"
    local patch_file="$2"
    
    print_info "Aplicando ${patch_name}..."
    
    if [ ! -f "patches/${patch_file}" ]; then
        print_error "Archivo ${patch_file} no encontrado"
        return 1
    fi
    
    if patch -p1 --dry-run < "patches/${patch_file}" > /dev/null 2>&1; then
        if patch -p1 < "patches/${patch_file}"; then
            print_status "${patch_name} aplicado"
            return 0
        else
            print_error "${patch_name} falló al aplicar"
            return 1
        fi
    else
        print_warning "${patch_name} tiene conflictos (saltando)"
        return 1
    fi
}

# Verificar directorio
if [ ! -f "dwm.c" ]; then
    print_error "No estás en el directorio de DWM"
    echo "Ejecuta: cd ~/suckless/dwm"
    exit 1
fi

DWM_DIR=$(pwd)

echo "╔════════════════════════════════════════╗"
echo "║   DWM MEGA AUTOPATCH - Versión Safe   ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Directorio: $DWM_DIR"
echo ""

# Backup
print_info "Creando backup..."
BACKUP_DIR="../dwm-backup-$(date +%Y%m%d-%H%M%S)"
cp -r . "$BACKUP_DIR"
print_status "Backup en: $BACKUP_DIR"

# Crear directorio de parches
mkdir -p patches

# Contadores
TOTAL=0
SUCCESS=0
FAILED=0

# ========================================
# DESCARGAR PARCHES
# ========================================
echo ""
print_info "=== Descargando parches ==="

cd patches

declare -A PATCHES=(
    ["bar-height"]="bar-height/dwm-bar-height-6.2.diff"
    ["barpadding"]="barpadding/dwm-barpadding-20211020-a786211.diff"
    ["statuspadding"]="statuspadding/dwm-statuspadding-6.3.diff"
    ["statuscolors"]="statuscolors/dwm-statuscolors-20181008-b69c870.diff"
    ["underlinetags"]="underlinetags/dwm-underlinetags-6.2.diff"
    ["hide_vacant_tags"]="hide_vacant_tags/dwm-hide_vacant_tags-6.3.diff"
    ["xresources"]="xresources/dwm-xresources-20210827-138b405.diff"
    ["vanitygaps"]="vanitygaps/dwm-vanitygaps-20200610-f09418b.diff"
    ["systray"]="systray/dwm-systray-20230922-9f88553.diff"
    ["pertag"]="pertag/dwm-pertag-20200914-61bb8b2.diff"
    ["sticky"]="sticky/dwm-sticky-20160911-ab9571b.diff"
    ["swallow"]="swallow/dwm-swallow-20201211-61bb8b2.diff"
    ["cyclelayouts"]="cyclelayouts/dwm-cyclelayouts-20180524-6.2.diff"
    ["focusonnetactive"]="focusonnetactive/dwm-focusonnetactive-6.2.diff"
    ["warp"]="warp/dwm-warp-20210816-8d3e7ca.diff"
    ["rotatestack"]="rotatestack/dwm-rotatestack-20161021-ab9571b.diff"
    ["resizecorners"]="resizecorners/dwm-resizecorners-6.2.diff"
    ["attachaside"]="attachaside/dwm-attachaside-6.2.diff"
    ["autostart"]="autostart/dwm-autostart-20210120-cb3f58a.diff"
    ["restartsig"]="restartsig/dwm-restartsig-20180523-6.2.diff"
)

for name in "${!PATCHES[@]}"; do
    url="https://dwm.suckless.org/patches/${PATCHES[$name]}"
    filename="${name}.diff"
    
    if wget -q "$url" -O "$filename" 2>/dev/null; then
        print_status "${name} descargado"
    else
        print_warning "${name} no se pudo descargar (puede no existir)"
    fi
done

cd "$DWM_DIR"

# ========================================
# PREGUNTAS AL USUARIO
# ========================================
echo ""
read -p "¿Usar fakefullscreen (mantiene barra) en lugar de actualfullscreen? (s/n): " use_fake
read -p "¿Instalar scratchpad (terminal dropdown)? (s/n): " install_scratch

# Descargar según elección
cd patches
if [[ $use_fake == "s" || $use_fake == "S" ]]; then
    wget -q https://dwm.suckless.org/patches/fakefullscreen/dwm-fakefullscreen-20210714-138b405.diff -O fakefullscreen.diff
else
    wget -q https://dwm.suckless.org/patches/actualfullscreen/dwm-actualfullscreen-20211013-cb3f58a.diff -O actualfullscreen.diff
fi

if [[ $install_scratch == "s" || $install_scratch == "S" ]]; then
    wget -q https://dwm.suckless.org/patches/scratchpad/dwm-scratchpad-20221102-ba56fe9.diff -O scratchpad.diff
fi
cd "$DWM_DIR"

# ========================================
# APLICAR PARCHES EN ORDEN
# ========================================
echo ""
print_info "=== Aplicando parches ==="

# Orden óptimo de aplicación
PATCH_ORDER=(
    "bar-height"
    "barpadding"
    "statuspadding"
    "statuscolors"
    "underlinetags"
    "hide_vacant_tags"
    "xresources"
    "vanitygaps"
)

if [[ $use_fake == "s" || $use_fake == "S" ]]; then
    PATCH_ORDER+=("fakefullscreen")
else
    PATCH_ORDER+=("actualfullscreen")
fi

PATCH_ORDER+=(
    "systray"
    "pertag"
    "sticky"
    "swallow"
    "cyclelayouts"
    "focusonnetactive"
    "warp"
    "rotatestack"
    "resizecorners"
    "attachaside"
    "autostart"
    "restartsig"
)

if [[ $install_scratch == "s" || $install_scratch == "S" ]]; then
    PATCH_ORDER+=("scratchpad")
fi

for patch_name in "${PATCH_ORDER[@]}"; do
    TOTAL=$((TOTAL + 1))
    if apply_patch "$patch_name" "${patch_name}.diff"; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

# ========================================
# RESULTADOS
# ========================================
echo ""
echo "========================================"
echo "Resultados del parcheo:"
echo "  Total: $TOTAL parches"
echo "  Exitosos: $SUCCESS"
echo "  Fallidos: $FAILED"
echo "========================================"

if [ $FAILED -gt 0 ]; then
    echo ""
    print_warning "Algunos parches fallaron o tienen conflictos"
    print_info "Revisa los archivos .rej en el directorio de DWM"
    echo ""
    read -p "¿Continuar con la compilación de todos modos? (s/n): " continue_compile
    if [[ ! $continue_compile == "s" && ! $continue_compile == "S" ]]; then
        echo "Saliendo sin compilar. Puedes compilar manualmente con: sudo make clean install"
        exit 0
    fi
fi

# ========================================
# COMPILAR
# ========================================
echo ""
print_info "=== Compilando DWM ==="

# Limpiar
make clean 2>/dev/null || true

# Compilar
print_info "Ejecutando make..."
if make 2>&1 | tee make.log; then
    print_status "Compilación exitosa"
    
    # Instalar
    print_info "Instalando (requiere sudo)..."
    if sudo make install; then
        print_status "DWM instalado correctamente"
    else
        print_error "Error al instalar (permisos?)"
        echo "Intenta manualmente: sudo make install"
        exit 1
    fi
else
    print_error "Error de compilación"
    echo ""
    echo "Log guardado en: make.log"
    echo "Últimas líneas del error:"
    tail -20 make.log
    echo ""
    echo "Para compilar manualmente:"
    echo "  make clean"
    echo "  make"
    echo "  sudo make install"
    exit 1
fi

# ========================================
# POST-INSTALACIÓN
# ========================================
echo ""
print_info "=== Configuración Post-Instalación ==="

# Crear .Xresources
if [ ! -f ~/.Xresources.dark ]; then
    print_info "Creando .Xresources..."
    
    cat > ~/.Xresources.dark <<'EOF'
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
dwm.gappx: 12
EOF

    cat > ~/.Xresources.light <<'EOF'
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
dwm.gappx: 12
EOF

    cp ~/.Xresources.dark ~/.Xresources
    xrdb -merge ~/.Xresources 2>/dev/null || true
    
    print_status "Xresources creados"
fi

# Crear script auto-darkmode
if [ ! -f ~/.local/bin/dwm-auto-theme ]; then
    print_info "Creando script auto-darkmode..."
    
    mkdir -p ~/.local/bin
    
    cat > ~/.local/bin/dwm-auto-theme <<'EOF'
#!/bin/bash
HOUR=$(date +%H)
XRESOURCES=~/.Xresources

if [ $HOUR -ge 6 -a $HOUR -lt 18 ]; then
    cp ~/.Xresources.light $XRESOURCES
else
    cp ~/.Xresources.dark $XRESOURCES
fi

xrdb -merge $XRESOURCES
pkill -HUP dwm 2>/dev/null
EOF

    chmod +x ~/.local/bin/dwm-auto-theme
    print_status "Script auto-darkmode creado"
    
    read -p "¿Añadir a crontab (cambio automático cada hora)? (s/n): " add_cron
    if [[ $add_cron == "s" || $add_cron == "S" ]]; then
        (crontab -l 2>/dev/null; echo "0 * * * * ~/.local/bin/dwm-auto-theme") | crontab -
        print_status "Añadido a crontab"
    fi
fi

# Crear autostart
if [ ! -f ~/.dwm/autostart.sh ]; then
    print_info "Creando autostart.sh..."
    
    mkdir -p ~/.dwm
    
    cat > ~/.dwm/autostart.sh <<'EOF'
#!/bin/bash
dwmblocks &
picom -b &
nitrogen --restore &
nm-applet &
blueman-applet &
dunst &
~/.local/bin/dwm-auto-theme &
EOF

    chmod +x ~/.dwm/autostart.sh
    print_status "autostart.sh creado"
fi

# ========================================
# RESUMEN FINAL
# ========================================
echo ""
echo "╔════════════════════════════════════════╗"
echo "║     ✓ INSTALACIÓN COMPLETADA          ║"
echo "╚════════════════════════════════════════╝"
echo ""
print_status "DWM parcheado y compilado exitosamente"
echo ""
echo "📊 Estadísticas:"
echo "  • Parches aplicados: $SUCCESS/$TOTAL"
echo "  • Backup en: $BACKUP_DIR"
echo ""
echo "📁 Archivos creados:"
echo "  • ~/.Xresources.dark/.light"
echo "  • ~/.local/bin/dwm-auto-theme"
echo "  • ~/.dwm/autostart.sh"
echo ""
echo "⚡ Siguiente paso:"
echo "  1. Reinicia DWM: Super + Shift + Q"
echo "  2. O ejecuta: startx"
echo ""
print_info "¡Disfruta tu DWM ultra-personalizado! 🎉"
echo ""
