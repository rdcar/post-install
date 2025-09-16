#!/bin/bash

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias
echo "Instalando aplicações via apt..."
sudo apt install nala ubuntu-restricted-extras bpytop wget curl neofetch -y

# Instalar GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
# Instalar Tailscale VPN
curl -fsSL https://tailscale.com/install.sh | sh

# Verificar se o Flatpak está instalado
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak não encontrado, instalando..."
    sudo apt install flatpak -y
else
    echo "Flatpak já está instalado."
fi

# Adicionar o repositório Flathub, se não estiver presente
if ! flatpak remote-list | grep -q 'flathub'; then
    echo "Adicionando o repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "Repositório Flathub já está adicionado."
fi

# Lista de aplicativos Flatpak a serem instalados
apps=(
    "org.videolan.VLC"
    "com.spotify.Client"
    "org.gimp.GIMP"
    "com.brave.Browser"
    "com.calibre_ebook.calibre"
    "com.github.johnfactotum.Foliate"
    "com.teamspeak.TeamSpeak3"
    "org.qbittorrent.qBittorrent"
    "io.github.peazip.PeaZip"
    "org.jdownloader.JDownloader"
    "com.github.unrud.VideoDownloader"
    "io.github.JakubMelka.Pdf4qt"
    "org.mozilla.Thunderbird"
    "org.localsend.localsend_app"
    "io.gitlab.adhami3310.Impression"
    "io.github.thetumultuousunicornofdarkness.cpu-x"
    "org.gnome.NetworkDisplays"
    "com.mattjakeman.ExtensionManager"
)

# Instalando os aplicativos
echo "Instalando aplicativos Flatpak..."
for app in "${apps[@]}"; do
    if ! flatpak list | grep -q "$app"; then
        echo "Instalando $app..."
        flatpak install -y flathub "$app"
    else
        echo "$app já está instalado."
    fi
done

# Open a specific URL in the default browser
xdg-open https://code.visualstudio.com/
xdg-open https://github.com/Martichou/rquickshare/releases

# Baixando o script de instalação do Anaconda
echo "Instalando o Anaconda..."
curl -O https://repo.anaconda.com/archive/Anaconda3-2025.06-0-Linux-x86_64.sh -O anaconda.sh
bash anaconda.sh -b
rm anaconda.sh

# Adicionando regras no Firewall para GSConnect / KDE Connect / Zorin Connect
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp
sudo ufw reload

### Fixes the common Dummy Output error on some Intel sound cards in kernel 6.8+
echo "options snd-hda-intel dmic_detect=0" | sudo tee -a /etc/modprobe.d/alsa-base.conf echo "blacklist snd_soc_skl" | sudo tee -a /etc/modprobe.d/blacklist.conf

# Finalizando
echo "Instalação concluída!"
echo "Reinicie o sistema para garantir que todas as mudanças entrem em efeito corretamente."
