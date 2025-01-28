#!/bin/bash

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias
echo "Instalando apliações via apt..."
sudo apt install nala ubuntu-restricted-extras bpytop  -y

echo "Instalando o Anaconda..."
# Baixando o script de instalação do Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh -O anaconda.sh

# Executando o script de instalação
bash anaconda.sh -b

# Limpando o arquivo de instalação
rm anaconda.sh

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
xdg-open https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
xdg-open https://github.com/Martichou/rquickshare/releases

# Finalizando
echo "Instalação concluída!"
echo "Reinicie o sistema para garantir que todas as mudanças entrem em efeito corretamente."
