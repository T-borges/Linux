#!/bin/bash
#
#Data: 13/11/2016
#Autor: Thiago Borges
#Script criado para gerenciar backups
#

DB_USER="root"
DB="bacula"
DB_PASS="123456"


function cadastrar(){
     echo "Digite o ip: "
     read IP
     echo "Digite os diretorios: "
     iead DIRETORIOS
     mysql -u$DB_USER -p$DB_PASS $DB -e "insert into servidores(endereco,diretorios) values('$IP','$DIRETORIOS')" 
}
function backup(){
        mysql -u$DB_USER -p$DB_PASS $DB -se "select * from servidores" > /tmp/select.tmp
        sed -i "s/\t/:/g" /tmp/select.tmp
        for LINHA in $(cat /tmp/select.tmp); do
        IP=$( echo $LINHA | cut -f2 -d":")
        DIRETORIOS=$( echo $LINHA | cut -f3 -d":")
        echo "Fazendo backup de: "$IP
        echo "Dos diretorios: "$DIRETORIOS
        DATA=$(date +%d_%m_%Y_%H_%M)
        ARQUIVO=$(echo "${IP}_${DATA}.tar.gz")
        INICIO=$(date +"%Y-%m-%d-%H:%M:%S")
        ssh root@$IP "tar -zcf /tmp/$ARQUIVO $DIRETORIOS"
        scp root@$IP:/tmp/*.tar.gz /backup/
        ssh root@$IP "rm -f /tmp/*.tar.gz"
        FIM=$(date +"%Y-%m-%d-%H:%M:%S")
        sleep 5
        mysql -uroot -p123456 backup -e "insert into log(inicio,fim,server,arquivo,status) values('$INICIO','$FIM','$IP','$ARQUIVO','OK')"     

     done

}
function listar(){
        mysql -u$DB_USER -p$DB_PASS $DB -e "select * from servidores"
}
function remover(){
        echo "Digite o ip do servidor: "
        read IP
        sed "/\<$IP\>/d" banco.txt
        echo "Deseja mesmo remover? (y/n)"
        read OP
        OP=$(echo $OP | tr [:upper:] [:lower:])
        if [ $OP == "y" ]; then
            mysql -u$DB_USER -p$DB_PASS $DB -e "delete from servidores where endereco='$IP'"
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
