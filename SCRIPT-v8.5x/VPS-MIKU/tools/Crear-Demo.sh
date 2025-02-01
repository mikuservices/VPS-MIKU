#!/bin/bash
 #01/02/2025
 clear
 clear
 msg -bar
 rm -rf /etc/VPS-MIKU/demo-ssh 2>/dev/null
 mkdir /etc/VPS-MIKU/demo-ssh 2>/dev/null
 SCPdir="/etc/VPS-MIKU"
 SCPusr="${SCPdir}/controller"
 
 declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
 SCPdir="/etc/VPS-MIKU"
 SCPfrm="${SCPdir}/tools" && [[ ! -d ${SCPfrm} ]] && exit
 SCPinst="${SCPdir}/protocols" && [[ ! -d ${SCPinst} ]] && exit
 
 tmpusr () {
 time="$1"
 timer=$(( $time * 60 ))
 timer2="'$timer's"
 echo "#!/bin/bash
 sleep $timer2
 kill"' $(ps -u '"$2 |awk '{print"' $1'"}') 1> /dev/null 2> /dev/null
 userdel --force $2
 rm -rf /tmp/$2
 exit" > /tmp/$2
 }
 
 tmpusr2 () {
 time="$1"
 timer=$(( $time * 60 ))
 timer2="'$timer's"
 echo "#!/bin/bash
 sleep $timer2
 kill=$(dropb | grep "$2" | awk '{print $2}')
 kill $kill
 userdel --force $2
 rm -rf /tmp/$2
 exit" > /tmp/$2
 }
 echo  -e "$(msg -tit)$(msg -bar) " 
 msg -ama "        CREAR UN USUARIO POR TIEMPO (Minutes)"
 msg -bar
 echo -e "\033[1;97m Puedes crear usuarios en esta seccion will\n que seran eliminados automaticamente una vez vencidos.\033[0m"
 msg -bar
 
 echo -e "\033[1;91m [1]-\033[1;97mUser name:\033[0;37m"; read -p " " name
 if [[ -z $name ]]
 then
 echo "El nuevo usuario no puede estar vacio"
 exit
 fi
 if cat /etc/passwd |grep $name: |grep -vi [a-z]$name |grep -v [0-9]$name > /dev/null
 then
 echo -e "\033[1;31mUser $name ya existe\033[0m"
 exit
 fi
 echo -e "\033[1;91m [2]-\033[1;97mPassword para el user $name:\033[0;37m"; read -p " " pass
 echo -e "\033[1;91m [3]-\033[1;97mDuracion de tiempo en Minutos:\033[0;37m"; read -p " " tmp
 if [ "$tmp" = "" ]; then
 tmp="30"
 echo -e "\033[1;32mSe definen 30 minutos predeterminados!\033[0m"
 msg -bar
 sleep 2s
 fi
 useradd -M -s /bin/false $name
 (echo $pass; echo $pass)|passwd $name 2>/dev/null
 touch /tmp/$name
 tmpusr $tmp $name
 chmod 777 /tmp/$name
 touch /tmp/cmd
 chmod 777 /tmp/cmd
 echo "nohup /tmp/$name & >/dev/null" > /tmp/cmd
 /tmp/cmd 2>/dev/null 1>/dev/null
 rm -rf /tmp/cmd
 touch /etc/VPS-MIKU/demo-ssh/$name
 echo "pass: $pass" >> /etc/VPS-MIKU/demo-ssh/$name
 echo "data: ($tmp)Minutes" >> /etc/VPS-MIKU/demo-ssh/$name
 msg -bar2
 echo -e "\033[1;93m ¡¡ Usuario temporal x MINUTOS (VPS-MIKU By @mikuservices) !!\033[0m"
 msg -bar2
 echo -e "\033[1;36m  >> Server IP: \033[0m$(meu_ip) " 
 echo -e "\033[1;36m  >> User: \033[0m$name"
 echo -e "\033[1;36m  >> Password: \033[0m$pass"
 echo -e "\033[1;36m  >> Duration Minutos: \033[0m$tmp"
 msg -bar2
 msg -ne " Pulsa enter para continuar" && read enter
 ${SCPusr}/usercodes
 
  