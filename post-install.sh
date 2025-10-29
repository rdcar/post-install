#!/bin/bash

# Script de pós-instalação para Ubuntu e derivados
# Autor: [@rdcar]
# Data: 29/10/2025

set -euo pipefail  # Sair em caso de erro, variável não definida ou falha em pipe
IFS=$'\n\t'       # Definir separador de campo interno

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verificar se está rodando como root
if [[ $EUID -eq 0 ]]; then
   print_error "Este script não deve ser executado como root!"
   exit 1
fi

# Verificar se está rodando em sistema baseado em Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    print_error "Este script é apenas para sistemas baseados em Debian/Ubuntu"
    exit 1
fi

# Criar arquivo de log
LOG_FILE="$HOME/post-install-$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

print_message "Iniciando script de pós-instalação..."
print_message "Log sendo salvo em: $LOG_FILE"

# Função para verificar sucesso de comando
check_success() {
    if [ $? -eq 0 ]; then
        print_message "$1 concluído com sucesso."
    else
        print_error "$1 falhou."
        return 1
    fi
}

# Atualizar o sistema
print_message "Atualizando repositórios e sistema..."
sudo apt update && sudo apt upgrade -y
check_success "Atualização do sistema"

# Instalar dependências necessárias
print_message "Instalando aplicações essenciais via apt..."
PACKAGES="nala ubuntu-restricted-extras bpytop wget curl neofetch git build-essential"
for package in $PACKAGES; do
    if ! dpkg -l | grep -q "^ii  $package"; then
        print_message "Instalando $package..."
        sudo apt install "$package" -y
    else
        print_message "$package já está instalado."
    fi
done

# Instalar GitHub CLI
print_message "Configurando GitHub CLI..."
if ! command -v gh &> /dev/null; then
    # Garantir wget está instalado
    type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)
    
    # Configurar chave GPG
    sudo mkdir -p -m 755 /etc/apt/keyrings
    
    # Baixar e instalar chave com tratamento de erro
    TEMP_KEY=$(mktemp)
    if wget -nv -O"$TEMP_KEY" https://cli.github.com/packages/githubcli-archive-keyring.gpg; then
        cat "$TEMP_KEY" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        
        # Adicionar repositório
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        
        # Instalar GitHub CLI
        sudo apt update && sudo apt install gh -y
        check_success "Instalação do GitHub CLI"
    else
        print_error "Falha ao baixar chave GPG do GitHub CLI"
    fi
    rm -f "$TEMP_KEY"
else
    print_message "GitHub CLI já está instalado."
fi

# Instalar Tailscale VPN
print_message "Instalando Tailscale VPN..."
if ! command -v tailscale &> /dev/null; then
    if curl -fsSL https://tailscale.com/install.sh | sh; then
        check_success "Instalação do Tailscale"
    else
        print_error "Falha na instalação do Tailscale"
    fi
else
    print_message "Tailscale já está instalado."
fi

# Configurar Flatpak
print_message "Configurando Flatpak..."
if ! command -v flatpak &> /dev/null; then
    print_message "Instalando Flatpak..."
    sudo apt install flatpak -y
    # Para GNOME (adicionar suporte à loja de software)
    if command -v gnome-shell &> /dev/null; then
        sudo apt install gnome-software-plugin-flatpak -y
    fi
else
    print_message "Flatpak já está instalado."
fi

# Adicionar o repositório Flathub
if ! flatpak remote-list | grep -q 'flathub'; then
    print_message "Adicionando repositório Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    print_message "Repositório Flathub já está configurado."
fi

# Lista de aplicativos Flatpak
declare -A FLATPAK_APPS=(
    ["org.videolan.VLC"]="VLC Media Player"
    ["com.spotify.Client"]="Spotify"
    ["org.gimp.GIMP"]="GIMP"
    ["com.brave.Browser"]="Brave Browser"
    ["com.calibre_ebook.calibre"]="Calibre"
    ["com.github.johnfactotum.Foliate"]="Foliate"
    ["com.teamspeak.TeamSpeak3"]="TeamSpeak 3"
    ["org.qbittorrent.qBittorrent"]="qBittorrent"
    ["io.github.peazip.PeaZip"]="PeaZip"
    ["org.jdownloader.JDownloader"]="JDownloader"
    ["com.github.unrud.VideoDownloader"]="Video Downloader"
    ["io.github.JakubMelka.Pdf4qt"]="PDF4QT"
    ["org.mozilla.Thunderbird"]="Thunderbird"
    ["org.localsend.localsend_app"]="LocalSend"
    ["io.gitlab.adhami3310.Impression"]="Impression"
    ["io.github.thetumultuousunicornofdarkness.cpu-x"]="CPU-X"
    ["org.gnome.NetworkDisplays"]="Network Displays"
    ["com.mattjakeman.ExtensionManager"]="Extension Manager"
)

# Instalar aplicativos Flatpak
print_message "Instalando aplicativos Flatpak..."
for app_id in "${!FLATPAK_APPS[@]}"; do
    app_name="${FLATPAK_APPS[$app_id]}"
    if ! flatpak list | grep -q "$app_id"; then
        print_message "Instalando $app_name..."
        if sudo flatpak install -y flathub "$app_id"; then
            print_message "$app_name instalado com sucesso."
        else
            print_warning "Falha ao instalar $app_name, continuando..."
        fi
    else
        print_message "$app_name já está instalado."
    fi
done

# Abrir URLs para download manual
print_message "Abrindo páginas para downloads manuais..."
print_message "Por favor, baixe e instale manualmente os seguintes aplicativos:"

# Verificar se xdg-open está disponível
if command -v xdg-open &> /dev/null; then
    xdg-open "https://code.visualstudio.com/" 2>/dev/null &
    xdg-open "https://github.com/Martichou/rquickshare/releases" 2>/dev/null &
else
    print_message "Visual Studio Code: https://code.visualstudio.com/"
    print_message "RQuickShare: https://github.com/Martichou/rquickshare/releases"
fi

# Instalar Anaconda (opcional)
read -p "Deseja instalar o Anaconda? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_message "Baixando e instalando Anaconda..."
    ANACONDA_INSTALLER="Anaconda3-latest-Linux-x86_64.sh"
    
    # Baixar a versão mais recente
    if wget -q --show-progress "https://repo.anaconda.com/archive/Anaconda3-2025.06-1-Linux-x86_64.sh" -O "$ANACONDA_INSTALLER"; then
        # Instalar em modo batch no diretório home do usuário
        bash "$ANACONDA_INSTALLER" -b -p "$HOME/anaconda3"
        
        # Adicionar ao PATH (opcional)
        read -p "Deseja adicionar Anaconda ao PATH? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            "$HOME/anaconda3/bin/conda" init bash
            print_message "Anaconda adicionado ao PATH. Reinicie o terminal para aplicar."
        fi
        
        rm -f "$ANACONDA_INSTALLER"
        check_success "Instalação do Anaconda"
    else
        print_error "Falha ao baixar o Anaconda"
    fi
else
    print_message "Instalação do Anaconda pulada."
fi

# Configurar Firewall para KDE Connect/GSConnect
if command -v ufw &> /dev/null; then
    print_message "Configurando firewall para KDE Connect/GSConnect..."
    sudo ufw allow 1714:1764/udp
    sudo ufw allow 1714:1764/tcp
    sudo ufw reload
    check_success "Configuração do firewall"
else
    print_warning "UFW não encontrado, pulando configuração de firewall."
fi

# Fix para problemas de áudio (Intel Sound Cards)
read -p "Aplicar fix para problemas de áudio Intel (Dummy Output)? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_message "Aplicando correções de áudio..."
    
    # Criar backup dos arquivos originais
    sudo cp /etc/modprobe.d/alsa-base.conf /etc/modprobe.d/alsa-base.conf.backup 2>/dev/null || true
    sudo cp /etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf.backup 2>/dev/null || true
    
    # Aplicar correções
    echo "options snd-hda-intel dmic_detect=0" | sudo tee -a /etc/modprobe.d/alsa-base.conf
    echo "blacklist snd_soc_skl" | sudo tee -a /etc/modprobe.d/blacklist.conf
    
    check_success "Correções de áudio"
    print_warning "As correções de áudio requerem reinicialização para ter efeito."
else
    print_message "Correções de áudio puladas."
fi

# Limpeza do sistema
print_message "Realizando limpeza do sistema..."
sudo apt autoremove -y
sudo apt autoclean

# Resumo final
echo
print_message "========================================="
print_message "     INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
print_message "========================================="
print_message "Log completo salvo em: $LOG_FILE"
echo
print_warning "Recomenda-se reiniciar o sistema para garantir que todas as mudanças entrem em efeito."
echo
read -p "Deseja reiniciar agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_message "Reiniciando o sistema em 5 segundos..."
    sleep 5
    sudo reboot
else
    print_message "Por favor, reinicie o sistema quando conveniente."
fi
