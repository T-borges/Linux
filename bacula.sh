#!/bin/bash
#
#Data: 13/11/2016
#Autor: Thiago Borges
#Script criado para gerenciar backups
#

function cadastrar(){
     echo "Digite o ip: "
     read IP
     grep "\<$IP\>" banco.txt
     if [ $? -eq 0 ]; then
             echo "servidor ja cadastrado"
            exit
     fi

     echo "Digite os diretorios: "
     read DIRETORIOS
     echo "$IP:$DIRETORIOS" >> banco.txt

}
function backup(){
        for LINHA in $(cat /root/codigos/banco.txt); do
        IP=$( echo $LINHA | cut -f1 -d":")
        DIRETORIOS=$( echo $LINHA | cut -f2 -d":")
        echo "Fazendo backup de: "$IP
        echo "Dos diretorios: "$DIRETORIOS
        DATA=$(date +%d_%m_%Y_%H_%M)
        ssh root@$IP "tar -zcf /tmp/${IP}_${DATA}.tar.gz $DIRETORIOS"
        scp root@$IP:/tmp/*.tar.gz /backup/
        ssh root@$IP "rm -f /tmp/*.tar.gz"
        sleep 5
     
     done

}
function listar(){
        cat banco.txt
}
function remover(){
        echo "Digite o ip do servidor: "
        read IP
        sed "/\<$IP\>/d" banco.txt
        echo "Deseja mesmo remover? (y/n)"
        read OP
        OP=$(echo $OP | tr [:upper:] [:lower:])
        if [ $OP == "y" ]; then
        sed -i "/\<$IP\>/d" banco.txt
       fi
}

function menu(){

       echo "cadastrar - Para cadastrar novos servidores"
       echo "remover - Remover servidores"
       echo "listar - Lista servidores"
       echo "backup - Gerar backup dos servidores"

}

if [ $# -eq 0 ]; then
         menu
fi
echo $@

case $1 in
       "cadastrar")
              cadastrar
        ;;
        "remover")
               remover
        ;;
        "listar")
               listar
        ;;  
        "backup")
               backup
        ;;
        *)
               echo "Opcao invalida"
        ;; 
esac
