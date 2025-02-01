# !/bin/bash
# 01/02/2025
clear
clear
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/VPS-MIKU" && [[ ! -d ${SCPdir} ]] && exit 1
SCPusr="${SCPdir}/controller" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="${SCPdir}/tools" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="${SCPdir}/protocols" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
dnsnetflix () {
echo "nameserver $dnsp" > /etc/resolv.conf
#echo "nameserver 8.8.8.8" >> /etc/resolv.conf
/etc/init.d/ssrmu stop &>/dev/null
/etc/init.d/ssrmu start &>/dev/null
/etc/init.d/shadowsocks-r stop &>/dev/null
/etc/init.d/shadowsocks-r start &>/dev/null
msg -bar2
echo -e "${cor[4]}  DNS REGISTRADO CON EXITO"
} 
clear
msg -bar2
msg -tit
echo -e "\033[1;93m     AGREGAR DNS PERSONAL By @mikuservices "
msg -bar2
echo -e "\033[1;39m Esta funcion es para ver Netflix en tu VPS"
msg -bar2
echo -e "\033[1;91m ¡ ATENTO, DEBES DE TENER UN DNS VALIDO!"
echo -e "\033[1;39m En APPS como HTTP Injector,KPN Rev,HTTP CUSTOM etc."
echo -e "\033[1;39m Necesitas registrar el DNS en la aplicacion."
echo -e "\033[1;39m En APPS como SS,SSR,V2RAY no sera necesario."
msg -bar2
echo -e "\033[1;93m Recuerda que el DNS debe estar registrado \n con tu VPS para garantizar."
echo ""
echo -e "\033[1;97m Introduce el DNS que usarás: \033[0;91m"; read -p "   "  dnsp
echo ""
msg -bar2
read -p " Estas seguro de continuar??  [ s | n ]: " dnsnetflix   
[[ "$dnsnetflix" = "s" || "$dnsnetflix" = "S" ]] && dnsnetflix
msg -bar2