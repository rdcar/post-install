# ZorinOS 18 Post-Install Automation

Este script automatiza a configuração de uma instalação limpa do **ZorinOS 18 Core**, focando em produtividade, correções de hardware e segurança.

## 🛠️ O que este script faz?

1.  **Atualização:** Sincroniza os repositórios e atualiza todos os pacotes do sistema.
2.  **Hardware:** Adiciona `i8042.nopnp` ao GRUB (essencial para teclados/touchpads em laptops Lenovo/Ideapad).
3.  **Segurança:** Configura o Firewall (UFW) para permitir o uso do KDE Connect/GSConnect.
4.  **Aplicações:** Instala uma lista robusta de aplicativos via Flatpak (System-wide) e pacotes utilitários via APT (como `nala`, `neofetch` e `bpytop`).

## 🚀 Como Executar

Clone o repositório ou baixe o arquivo `post-install.sh`, abra o terminal na pasta e execute:

```bash
chmod +x post-install.sh
sudo ./post-install.sh
