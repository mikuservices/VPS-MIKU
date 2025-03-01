#!/bin/bash
#31/01/2025 by @mikuservices
clear
clear
SCPdir="/etc/VPS-MIKU"
SCPfrm="${SCPdir}/tools" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocols"&& [[ ! -d ${SCPinst} ]] && exit
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
dirapache="/usr/local/lib/ubuntn/apache/ver" && [[ ! -d ${dirapache} ]] && exit
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<20; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.5
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m########################################\033[1;33m] - \033[1;32m OK \033[0m"
sleep 1s
}
ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
echo -e "\033[1;33m $(fun_trans  "Deteniendo Stunnel")"
msg -bar
service stunnel4 stop > /dev/null 2>&1
fun_bar "apt-get purge  stunnel4 -y"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Detenido con exito!")"
msg -bar
return 0
}
echo -e "\033[1;32m $(fun_trans  "              Instalador SSL By VPS-MIKU")"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Selecciona un puerto de redireccion interna")"
echo -e "\033[1;33m $(fun_trans  "Un puerto SSH/DROPBEAR/SQUID/OPENVPN/SSL")"
msg -bar
         while true; do
         echo -e "\033[1;37m"
         read -p " Local-Port: " portx
		 echo ""
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m Puerto invalido"
             fi
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m   Ahora el puerto LISTEN"
msg -bar
    while true; do
	echo -e "\033[1;37m"
    read -p " Listen-SSL: " SSLPORT
	echo ""
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m El puerto está en uso"
    unset SSLPORT
    done
msg -bar
echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
apt-get install stunnel4 -y > /dev/null 2>&1
echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${portx}" > /etc/stunnel/stunnel.conf
####Coreccion2.0##### 
openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1

# (echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "@vpsmx" )|openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1

openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt

cat stunnel.crt stunnel.key > stunnel.pem 

mv stunnel.pem /etc/stunnel/
######-------
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
msg -bar
echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
msg -bar
rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
rm -rf /root/stunnel.crt > /dev/null 2>&1
rm -rf /root/stunnel.key > /dev/null 2>&1
return 0
}
SPR &
ssl_stunel_2 () {
echo -e "\033[1;32m $(fun_trans  "             AGREGAR MAS PUERTOS SSL")"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Introduce un puerto de redireccion interna")"
echo -e "\033[1;33m $(fun_trans  "Un puerto SSH/DROPBEAR/SQUID/OPENVPN/SSL")"
msg -bar
         while true; do
         echo -ne "\033[1;37m"
         read -p " Local-Port: " portx
		 echo ""
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerto invalido")"
             fi
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m $(fun_trans  "Ahora el puerto LISTEN")"
msg -bar
    while true; do
	echo -ne "\033[1;37m"
    read -p " Listen-SSL: " SSLPORT
	echo ""
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans  "Este puerto esta en uso")"
    unset SSLPORT
    done
msg -bar
echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "client = no\n[SSL+]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" >> /etc/stunnel/stunnel.conf
######-------
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
msg -bar
echo -e "${cor[4]}            INSTALADO CON EXITO"
msg -bar
rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
rm -rf /root/stunnel.crt > /dev/null 2>&1
rm -rf /root/stunnel.key > /dev/null 2>&1
return 0
}
ssl_stunel_3 () {
clear
clear
msg -bar
msg -tit
echo -e "\033[1;93m      SSL + PYDIRECT  \033[1;94m By @AleSosaCreaciones "
msg -bar
echo -e "\033[1;91m Necesitas el puerto 22 SSH y los puertos libres (80 y 443)"
msg -bar

 install_python(){ 
 echo -e "\033[1;97m Activando puerto 80\n"
 fun_bar "apt-get install python -y" 
 sleep 3  
 screen -dmS pydic-80 python ${SCPinst}/python.py 80 "VPS-MIKU" && echo "80 VPS-MIKU" >> /etc/VPS-MIKU/PySSL.log
 msg -bar
 } 
 install_ssl(){  
 echo -e "\033[1;97m Activando Servicios SSL 80 ► 443\n"
 fun_bar "apt-get install stunnel4 -y" 
 apt-get install stunnel4 -y > /dev/null 2>&1 
 echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = 443\nconnect = 127.0.0.1:80" > /etc/stunnel/stunnel.conf 
 openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1 
 #(echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "@vpsmx" )|openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1
 openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt  
 cat stunnel.crt stunnel.key > stunnel.pem   
 mv stunnel.pem /etc/stunnel/ 
 ######------- 
 sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 
 service stunnel4 restart > /dev/null 2>&1  
 rm -rf /root/stunnel.crt > /dev/null 2>&1 
 rm -rf /root/stunnel.key > /dev/null 2>&1 
 } 
install_python 
install_ssl 
msg -bar
echo -e "${cor[4]}               INSTALACION COMPLETA"
msg -bar
}
clear
clear
msg -bar
msg -bar3
msg -tit
echo -e "${cor[3]}       Instalador SSL de puerto unico o multipuerto By @mikuservices"
msg -bar
echo -e "${cor[1]}            Elige la opcion deseada."
msg -bar
echo -e "${cor[4]} 1).-\033[1;37m INICIAR | DETENER SSL "
echo -e "${cor[4]} 2).-\033[1;37m AGREGAR PUERTOS SSL "
msg -bar
echo -e "${cor[4]} 3).-\033[1;37m SSL+PYDIREC (AUTO CONFIGURACION)   "
echo -ne ""$(msg -bar)"   \n$(msg -verd " 0).-") $(msg -verm2 "==>")" &&  msg -bra  "  \e[97m\033[1;41m RETURN \033[1;37m"
msg -bar
echo -ne "\033[1;37mIntroduce solo el numero segun la opcion deseada : "


read opcao
case $opcao in
1)
msg -bar
ssl_stunel
;;
2)
msg -bar
ssl_stunel_2
;;
3)
msg -bar
ssl_stunel_3
msg -ne "Pulsa enter para continuar" && read enter
/etc/VPS-MIKU/protocols/ssl.sh
;;
4)
exit
;;
esac
