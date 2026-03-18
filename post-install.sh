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
# 3. CORREÇÃO DE HARDWARE (AMD PMC)
# ==========================================================================
#print_message "Configurando módulo amd_pmc (enable_stb=1)..."

# Cria ou sobrescreve o arquivo de configuração de forma não interativa
#echo "options amd_pmc enable_stb=1" | sudo tee /etc/modprobe.d/amd_pmc.conf > /dev/null
#check_success "Criação do arquivo /etc/modprobe.d/amd_pmc.conf"

# Atualização do initramfs (Geralmente necessária para aplicar módulos no boot)
#print_message "Atualizando initramfs para aplicar alterações de módulo..."
#sudo update-initramfs -u
#check_success "Atualização do initramfs"

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
    org.jdownloader.JDownloader org.jousse.vincent.Pomodorolm page.kramo.Sly
    re.fossplant.songrec org.gnome.gitlab.somas.Apostrophe com.discordapp.Discord
    
)

for app in "${APPS[@]}"; do
    sudo flatpak install --system -y flathub "$app"
done

check_success "Instalação de Flatpaks"

# ==========================================================================
# 6. CONSERVAÇÃO DE BATERIA LENOVO (LIMITE 80%)
# ==========================================================================
print_message "Configurando modo de conservação de bateria (limite 80%)..."
DEVICE_ID="VPC2004:00"
ACPI_PATH="/sys/bus/platform/drivers/ideapad_acpi/$DEVICE_ID"

if [ -d "$ACPI_PATH" ]; then
    # Ativa o limite imediatamente para a sessão atual
    echo 1 | sudo tee "$ACPI_PATH/conservation_mode" > /dev/null
    
    # Cria o serviço systemd para persistência nos próximos boots
    sudo bash -c "cat > /etc/systemd/system/battery-conservation.service <<EOF
[Unit]
Description=Enable Lenovo Battery Conservation Mode

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 1 > $ACPI_PATH/conservation_mode'

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl enable --now battery-conservation.service > /dev/null 2>&1
    check_success "Serviço de conservação de bateria ativado"
else
    echo -e "\e[1;33m⚠ Caminho $ACPI_PATH não encontrado. O módulo ideapad_acpi está ativo?\e[0m"
fi

# ==========================================================================
# 7. COMPORTAMENTO DA TAMPA (LID SWITCH)
# ==========================================================================
print_message "Desabilitando suspensão ao fechar a tampa do notebook..."

# O comando sed procura a linha HandleLidSwitch (comentada ou não) e a altera para 'ignore'
sudo sed -i 's/^#*HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

# Caso a linha não exista no arquivo original por algum motivo, ele a adiciona ao final
if ! grep -q "^HandleLidSwitch=ignore" /etc/systemd/logind.conf; then
    echo "HandleLidSwitch=ignore" | sudo tee -a /etc/systemd/logind.conf > /dev/null
fi

check_success "Configuração do arquivo logind.conf"

# ==========================================================================
# FINALIZAÇÃO
# ==========================================================================
print_message "Script finalizado! Recomenda-se reiniciar o sistema para aplicar as mudanças de hardware e systemd."
