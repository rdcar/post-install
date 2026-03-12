#!/bin/bash

# ==========================================================================
# FUNÇÕES DE SUPORTE (Necessárias para as chamadas print_message e check_success)
# ==========================================================================
print_message() {
    echo -e "\n\e[1;34m[+]\e[0m $1"
}

check_success() {
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m✔ $1 concluído com sucesso.\e[0m"
    else
        echo -e "\e[1;31m✘ Erro em: $1. Verifique os logs acima.\e[0m"
    fi
}

# ==========================================================================
# 1. ATUALIZAÇÃO DO SISTEMA
# ==========================================================================
print_message "Atualizando repositórios e sistema..."
sudo apt update && sudo apt upgrade -y
check_success "Atualização do sistema"

# ==========================================================================
# 2. INSTALAÇÃO DE PACOTES APT (.DEB)
# ==========================================================================
# Removidos pacotes base que já vêm no ZorinOS para acelerar o processo.
print_message "Instalando pacotes APT selecionados..."
PACOTES_APT="amdgpu-top bpytop curl dkms gnome-tweaks nala neofetch ntp openssl syncthing ttf-mscorefonts-installer vim-common xxd"

sudo apt install -y --ignore-missing $PACOTES_APT
check_success "Instalação de pacotes APT"

# ==========================================================================
# 3. CORREÇÃO DE HARDWARE (GRUB)
# ==========================================================================
print_message "Verificando configurações do GRUB (Correção i8042.nopnp)..."

# Backup com timestamp
sudo cp /etc/default/grub "/etc/default/grub.bak_$(date +%s)"

if grep -q "i8042.nopnp" /etc/default/grub; then
    echo "[-] O parâmetro i8042.nopnp já está presente. Nenhuma alteração necessária."
else
    echo "[+] Aplicando correção i8042.nopnp para teclado/touchpad..."
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 i8042.nopnp"/' /etc/default/grub
    sudo update-grub
    check_success "Atualização do GRUB"
fi

# ==========================================================================
# 4. CONFIGURAÇÃO DE FIREWALL (KDE CONNECT)
# ==========================================================================
if command -v ufw &> /dev/null; then
    print_message "Configurando firewall para KDE Connect/GSConnect..."
    sudo ufw allow 1714:1764/udp
    sudo ufw allow 1714:1764/tcp
    sudo ufw reload
    check_success "Configuração do firewall"
fi

# ==========================================================================
# 5. INSTALAÇÃO FLATPAK (SYSTEM-WIDE)
# ==========================================================================
print_message "Iniciando instalação de aplicativos Flatpak (System)..."

# Garante que o repositório Flathub está configurado
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

APPS=(
    com.bitwarden.desktop com.calibre_ebook.calibre com.github.johnfactotum.Foliate
    com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager com.moonlight_stream.Moonlight
    com.rtosta.zapzap com.visualstudio.code io.github.flattool.Warehouse
    io.github.kolunmi.Bazaar io.github.peazip.PeaZip io.github.thetumultuousunicornofdarkness.cpu-x
    io.gitlab.adhami3310.Impression io.gitlab.librewolf-community io.missioncenter.MissionCenter
    md.obsidian.Obsidian me.iepure.devtoolbox org.localsend.localsend_app
    org.mozilla.Thunderbird org.onlyoffice.desktopeditors org.qbittorrent.qBittorrent
)

for app in "${APPS[@]}"; do
    sudo flatpak install --system -y flathub "$app"
done

check_success "Instalação de Flatpaks"

print_message "Script finalizado! Recomenda-se reiniciar o sistema para aplicar as mudanças de hardware."
