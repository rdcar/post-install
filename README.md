# Script Pós-Instalação para Ubuntu e Derivados

Um script para automatizar a instalação de aplicações essenciais, utilitários e aplicar correções comuns em sistemas baseados em Ubuntu/Debian.

## Como Usar

1.  Salve o conteúdo do script em um arquivo (por exemplo, `post-install.sh`).
2.  Dê permissão de execução ao arquivo:
    ```bash
    chmod +x post-install.sh
    ```
3.  Execute o script **sem sudo**:
    ```bash
    ./post-install.sh
    ```

> **IMPORTANTE:** Não execute este script como `root` ou usando `sudo`. O script foi projetado para ser executado como um usuário normal e solicitará privilégios de administrador (senha `sudo`) apenas quando necessário para instalações ou configurações específicas.

## O que o script faz?

### 1. Verificações e Preparação
* Verifica se não está sendo executado como `root`.
* Verifica se o sistema é baseado em Debian/Ubuntu (procurando pelo `apt`).
* Inicia um arquivo de log detalhado no seu diretório `$HOME`.
* Atualiza os repositórios e o sistema (`apt update && apt upgrade`).

### 2. Aplicações Essenciais (via Apt)
O script instala os seguintes pacotes `apt`:
* nala (um frontend para o `apt`)
* ubuntu-restricted-extras
* bpytop (monitor de sistema)
* wget
* curl
* neofetch
* git
* build-essential

### 3. Software Adicional
* **GitHub CLI:** Adiciona o repositório oficial e instala o `gh`.
* **Tailscale VPN:** Baixa e executa o script de instalação oficial.

### 4. Configuração e Aplicativos Flatpak
* Instala o `flatpak` e o plugin para a loja de software GNOME (se detectado).
* Adiciona o repositório principal `flathub`.
* Instala a seguinte lista de aplicativos via Flathub:
    * VLC Media Player
    * Spotify
    * GIMP
    * Brave Browser
    * Calibre
    * Foliate
    * TeamSpeak 3
    * qBittorrent
    * PeaZip
    * JDownloader
    * Video Downloader
    * PDF4QT
    * Thunderbird
    * LocalSend
    * Impression
    * CPU-X
    * Network Displays
    * Extension Manager (Gerenciador de Extensões GNOME)

### 5. Instalações Opcionais (Interativo)
* **Anaconda:** O script perguntará se você deseja baixar e instalar o Anaconda.

### 6. Instalações Manuais (Abre o Navegador)
O script abrirá as seguintes páginas no seu navegador para download e instalação manual:
* Visual Studio Code
* RQuickShare

### 7. Correções e Configurações (Interativo)
* **Firewall (UFW):** Pergunta se você deseja configurar o firewall para permitir o KDE Connect / GSConnect (portas 1714-1764).
* **Correção de Áudio (Intel):** Pergunta se você deseja aplicar uma correção comum para problemas de "Dummy Output" em placas de som Intel (`snd-hda-intel` e `snd_soc_skl`).

### 8. Limpeza e Finalização
* Executa `apt autoremove` e `apt autoclean` para limpar pacotes desnecessários.
* Informa onde o log foi salvo.
* Pergunta se você deseja reiniciar o computador para aplicar todas as alterações.

---

### Nota: Correção Manual para o Brave (Não incluída no Script)

O `readme.md` anterior mencionava uma correção para o Brave em Wayland. O script **instala** o Brave, mas **não** aplica esta correção. Se você notar imagens borradas no Brave ao usar escalonamento fracionado (Fractional Scaling) em Wayland, siga estes passos manualmente:

1.  Abra o Brave e digite na barra de endereços: `brave://flags/`
2.  Procure por: `Preferred Ozone platform`
3.  Mude o valor de "Default" para "**Wayland**".
4.  Reinicie o navegador.
