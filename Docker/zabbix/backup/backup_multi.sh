#!/bin/bash

# Definir as variáveis do banco de dados
DB_NAME="nome_do_banco"
DB_USER="usuario_do_banco"
DB_PASSWORD="senha_do_banco"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_DIR="/caminho/para/diretorio/de/backup"

# Definir a data e hora para o nome do arquivo de backup
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-backup-$DATE.sql"

# Função para realizar o backup local (sem Docker)
backup_local() {
  echo "Iniciando backup local de $DB_NAME..."
  
  # Realizar o backup usando pg_dump
  PGPASSWORD=$DB_PASSWORD pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME > $BACKUP_FILE
  
  if [ $? -eq 0 ]; then
    echo "Backup local realizado com sucesso! Arquivo: $BACKUP_FILE"
  else
    echo "Erro ao realizar o backup local."
    exit 1
  fi
}

# Função para realizar o backup no Docker
backup_docker() {
  CONTAINER_NAME="nome_do_container_postgresql"
  echo "Iniciando backup do PostgreSQL no contêiner Docker..."

  # Verificar se o contêiner Docker está em execução
  docker ps | grep -q "$CONTAINER_NAME"
  if [ $? -ne 0 ]; then
    echo "Contêiner Docker $CONTAINER_NAME não está em execução!"
    exit 1
  fi
  
  # Realizar o backup no contêiner Docker
  docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME -f /tmp/$DB_NAME-backup-$DATE.sql
  
  # Copiar o arquivo de backup do contêiner para o host local
  docker cp $CONTAINER_NAME:/tmp/$DB_NAME-backup-$DATE.sql $BACKUP_FILE
  
  if [ $? -eq 0 ]; then
    echo "Backup realizado com sucesso no Docker! Arquivo: $BACKUP_FILE"
  else
    echo "Erro ao realizar o backup no Docker."
    exit 1
  fi
}

# Função principal para exibir opções e capturar escolha do usuário
mostrar_menu() {
  echo "Escolha o método de backup:"
  echo "1. Backup local"
  echo "2. Backup no Docker"
  echo "3. Sair"
  read -p "Digite o número da opção desejada: " escolha
}

# Loop para o menu de opções
while true; do
  mostrar_menu

  case $escolha in
    1)
      backup_local
      break
      ;;
    2)
      backup_docker
      break
      ;;
    3)
      echo "Saindo..."
      exit 0
      ;;
    *)
      echo "Opção inválida. Por favor, escolha uma opção válida."
      ;;
  esac
done
