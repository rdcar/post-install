#!/bin/bash

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias
echo "Instalando dependências necessárias..."
sudo apt install -y \
    software-properties-common \
    apt-transport-https \
    curl \
    wget \
    gnome-shell-extension-manager \
    snapd

# Adicionar repositório do Brave
echo "Adicionando repositório do Brave..."
sudo curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser.asc | sudo gpg --dearmor -o /usr/share/keyrings/brave-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/stable/deb/ all main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Adicionar repositório do Visual Studio Code
echo "Adicionando repositório do Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

# Atualizar novamente os repositórios
echo "Atualizando os repositórios..."
sudo apt update

# Instalar os programas
echo "Instalando os programas..."
sudo apt install -y \
    brave-browser \
    code \
    bitwarden-desktop \
    calibre \
    jdownloader \
    peazip \
    foliate \
    vlc \
    bpytop \
    ubuntu-restricted-extras \
    

# Instalar RQuickShare via Snap (não disponível via APT)
echo "Instalando o RQuickShare..."
sudo snap install rquickshare

# Instalar o Anaconda
echo "Instalando o Anaconda..."
# Baixando o script de instalação do Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh -O anaconda.sh

# Executando o script de instalação
bash anaconda.sh -b

# Limpando o arquivo de instalação
rm anaconda.sh

# Finalizando
echo "Instalação concluída!"
echo "Reinicie o sistema para garantir que todas as mudanças entrem em efeito corretamente."
