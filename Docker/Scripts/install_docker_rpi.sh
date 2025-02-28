#!/bin/bash

function print_color(){
  NC='\033[0m' # No Color

  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}

set -e  # Para interromper a execução em caso de erro

echo "---------------- Atualiza o sistema ----------------"

print_color "green" "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instala dependências
print_color "green" "Instalando dependências..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "---------------- Adiciona a chave GPG do repositório oficial do Docker ----------------"
print_color "green" "Adicionando chave GPG do Docker..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adiciona o repositório do Docker
print_color "green" "Adicionando repositório do Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza os pacotes novamente
print_color "green" "Atualizando pacotes após adicionar o repositório..."
sudo apt update -y

echo "---------------- Instalando Docker e Componentes ----------------"
print_color "green" "Instalando o Docker e Componentes..."
sudo apt install -y docker-ce docker-ce-cli docker-compose containerd.io

# Adiciona o usuário atual ao grupo Docker (evita usar sudo para rodar docker)
echo "Adicionando o usuário $(whoami) ao grupo docker..."
sudo usermod -aG docker $(whoami)

# Habilita e inicia o serviço do Docker
print_color "Habilitando e iniciando o Docker..."
sudo systemctl enable --now docker

# Verifica se a instalação foi bem-sucedida
echo "Verificando instalação..."
docker --version
docker compose --version
echo "Docker instalado com sucesso!"
