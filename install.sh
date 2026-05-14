#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Instalando dotfiles desde: $DOTFILES_DIR"

# Detectar distro
if command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
elif command -v apt >/dev/null 2>&1; then
    DISTRO="parrot"
else
    echo "❌ Distro no soportada. Solo Arch o Parrot/Debian."
    exit 1
fi

echo "🧠 Sistema detectado: $DISTRO" 

install_eww_debian() {
    if command -v eww >/dev/null 2>&1; then
        echo "✅ eww ya está instalado."
        return
    fi

    echo "📦 Instalando dependencias para eww..."

    sudo apt install -y \
        git curl build-essential pkg-config \
        libgtk-3-dev libgtk-layer-shell-dev \
        libpango1.0-dev libgdk-pixbuf-2.0-dev \
        libdbusmenu-gtk3-dev libcairo2-dev libglib2.0-dev

    if ! command -v cargo >/dev/null 2>&1; then
        echo "🦀 Instalando Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        source "$HOME/.cargo/env" 2>/dev/null || true
    fi

    if [ ! -d "$HOME/eww" ]; then
        git clone https://github.com/elkowar/eww.git "$HOME/eww"
    fi

    echo "🔨 Compilando eww..."
    cd "$HOME/eww"
    cargo build --release --no-default-features --features x11

    sudo install -m 755 target/release/eww /usr/local/bin/eww

    echo "✅ eww instalado."
}

# INSTALL EWW ARCH

install_eww_arch() {
    if command -v eww >/dev/null 2>&1; then
        echo "✅ eww ya instalado"
        return
    fi

    if ! command -v yay >/dev/null 2>&1; then
        echo "📦 Instalando yay..."

        sudo pacman -S --needed --noconfirm git base-devel

        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay || exit
        makepkg -si --noconfirm
    fi

    echo "📦 Instalando eww..."
    yay -S --noconfirm eww
}


# Instalar paquetes
echo "📦 Instalando paquetes..."

if [ "$DISTRO" = "arch" ]; then
    sudo pacman -S --needed --noconfirm \
        bspwm sxhkd polybar rofi kitty picom dunst feh git zsh \
        playerctl networkmanager xorg-xrandr xorg-xinit \
        curl jq xclip xsel flameshot maim scrot \
        pavucontrol pulseaudio pulseaudio-alsa \
        pacman-contrib \
        unzip wget \
        eza bat neovim firefox \
        zsh-autosuggestions zsh-syntax-highlighting \
        procps-ng coreutils cliphist clipmenu

    install_eww_arch


elif [ "$DISTRO" = "parrot" ]; then
    sudo apt update

    sudo apt install -y \
        bspwm sxhkd polybar rofi kitty picom dunst feh git zsh \
        playerctl network-manager x11-xserver-utils \
        curl jq xclip xsel flameshot maim scrot \
        pavucontrol pulseaudio-utils \
        fonts-font-awesome unzip wget \
        eza bat neovim firefox \
        zsh-autosuggestions zsh-syntax-highlighting \
        procps coreutils

    install_eww_debian
fi


# Backup
echo "📦 Creando backup en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

[ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
[ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$BACKUP_DIR/"

# Linkear configs
echo "🔗 Linkeando configs..."
mkdir -p "$HOME/.config"

for dir in "$DOTFILES_DIR/.config/"*; do
    name="$(basename "$dir")"
    dest="$HOME/.config/$name"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Moviendo $dest al backup..."
        mv "$dest" "$BACKUP_DIR/$name"
    fi

    ln -sfn "$dir" "$dest"
done

# Copiar zsh
echo "💻 Copiando configuración de ZSH..."
[ -f "$DOTFILES_DIR/.zshrc" ] && cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.p10k.zsh" ] && cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Powerlevel10k
if [ ! -d "$HOME/powerlevel10k" ]; then
    echo "Instalando powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
fi

# Root ZSH
echo "👑 Configurando root..."

sudo cp "$HOME/.zshrc" /root/.zshrc 2>/dev/null || true
sudo cp "$HOME/.p10k.zsh" /root/.p10k.zsh 2>/dev/null || true

if [ ! -d "/root/powerlevel10k" ]; then
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
fi

sudo chsh -s /bin/zsh root 2>/dev/null || true

# Fonts
echo "🔤 Instalando fuentes..."
mkdir -p "$HOME/.local/share/fonts"
if [ -d "$DOTFILES_DIR/fonts" ]; then
    cp -r "$DOTFILES_DIR/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
    fc-cache -fv
fi

# Wallpapers
echo "🖼 Instalando wallpapers..."
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    sudo mkdir -p /usr/share/wallpapers
    sudo cp -r "$DOTFILES_DIR/wallpapers/"* /usr/share/wallpapers/ 2>/dev/null || true
fi

# Permisos
echo "🔧 Dando permisos a scripts..."
chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null || true
chmod -R +x "$HOME/.config/bspwm/scripts" 2>/dev/null || true
chmod -R +x "$HOME/.config/polybar/scripts" 2>/dev/null || true
chmod -R +x "$HOME/.config/eww/scripts" 2>/dev/null || true
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true

# NetworkManager
echo "🌐 Activando NetworkManager..."
sudo systemctl enable NetworkManager 2>/dev/null || true
sudo systemctl start NetworkManager 2>/dev/null || true

# xinitrc
echo "🪟 Configurando .xinitrc..."
cat > "$HOME/.xinitrc" <<EOF
exec bspwm
EOF

echo ""
echo "✅ Instalación completa."
echo "📦 Backup guardado en: $BACKUP_DIR"
echo ""
echo "Reiniciá sesión o ejecutá:"
echo "startx"
