#!/bin/bash

echo "Digite o seu nome: "
read NOME
if [ $NOME == "Thiago" ]; then
       echo "Acesso Negado"
       exit 1
fi


echo "Usuario: ${NOME} logou as "$(date +"%d/%m/%Y %H:%M") >> sistema.log
echo "Seja bem vindo "$NOME
