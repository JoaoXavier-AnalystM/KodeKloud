#!/bin/bash

# Definindo o arquivo com os domínios a serem verificados
DOMINIOS_FILE="/path/to/domains.txt"

# Definindo o host do Zabbix
HOST="check-dns"
ZABBIX_SERVER="192.168.1.16:8080"

# Função para realizar o ping e retornar 0 (sucesso) ou 1 (falha)
verificar_ping() {
    local dominio=$1
    ping -c 1 $dominio &> /dev/null
    return $?
}

# Laço para verificar cada domínio listado no arquivo txt
while IFS= read -r dominio; do
    if verificar_ping "$dominio"; then
        STATUS="1"  # Sucesso
    else
        STATUS="0"  # Falha
    fi

    # Envio do resultado via Zabbix Sender (enviando para o servidor HTTP)
    zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k "ping.$dominio" -o "$STATUS"

    # Exibindo o resultado
    if [ $STATUS -eq 1 ]; then
        echo "Ping para $dominio bem-sucedido."
    else
        echo "Ping para $dominio falhou."
    fi
done < "$DOMINIOS_FILE"
