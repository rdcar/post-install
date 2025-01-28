### Script para automatizar a instalação de programas no Ubuntu 24.04 LTS.

O script adiciona os respositórios necessários e instala as seguintes aplicações:
* Browser Brave,
* Visual Studio Code,
* Gnome Extension Maneger,
* Bitwarden,
* Calibre,
* JDownloader,
* PeaZip,
* Foliate,
* RQuickShare,
* VLC Media Player.

### Passos do script:
1. **Atualização do sistema:** `sudo apt update && sudo apt upgrade -y`
2. **Instalação de dependências necessárias:** O script instala o `software-properties-common`, `apt-transport-https`, `curl`, `wget`, e `gnome-shell-extension-manager`.
3. **Repositórios de Brave e VS Code:** Eles são adicionados para que o sistema possa instalar as versões mais recentes desses navegadores e editores.
4. **Instalação dos programas via APT:** Instala o Brave, Visual Studio Code, Bitwarden, Calibre, JDownloader, PeaZip, Foliate e VLC.
5. **RQuickShare via Snap:** Já que RQuickShare não está disponível via APT, o script usa o Snap para instalá-lo.
6. **Finalização e reinício do sistema:** Recomenda o reinício do sistema para garantir que tudo funcione corretamente.

### Como usar:
1. Crie um arquivo com o nome `post-install.sh`.
2. Dê permissão de execução: 
   ```bash
   chmod +x post-install.sh
   ```
3. Execute o script:
   ```bash
   ./instalar_programas.sh
   ```
