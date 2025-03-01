#!/bin/bash
#01/02/2025
clear
clear
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/VPS-MIKU" && [[ ! -d ${SCPdir} ]] && exit 1
SCPusr="${SCPdir}/controller" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="${SCPdir}/tools" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="${SCPdir}/protocols" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
port() {
    local portas
    local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    i=0
    while read port; do
        var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
        [[ "$(echo -e ${portas} | grep -w "$var1 $var2")" ]] || {
            portas+="$var1 $var2 $portas"
            echo "$var1 $var2"
            let i++
        }
    done <<<"$portas_var"
}
verify_port() {
    local SERVICE="$1"
    local PORTENTRY="$2"
    [[ ! $(echo -e $(port | grep -v ${SERVICE}) | grep -w "$PORTENTRY") ]] && return 0 || return 1
}
edit_squid() {

    msg -ama "$(fun_trans "REDEFINE PUERTOS SQUID")"
    msg -bar
    if [[ -e /etc/squid/squid.conf ]]; then
        local CONF="/etc/squid/squid.conf"
    elif [[ -e /etc/squid3/squid.conf ]]; then
        local CONF="/etc/squid3/squid.conf"
    fi
    NEWCONF="$(cat ${CONF} | grep -v "http_port")"
    msg -ne "$(fun_trans "Nuevos puertos"): "
    read -p "" newports
    for PTS in $(echo ${newports}); do
        verify_port squid "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
            echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
            return 1
        }
    done
    rm ${CONF}
    while read varline; do
        echo -e "${varline}" >>${CONF}
        if [[ "${varline}" = "#portas" ]]; then
            for NPT in $(echo ${newports}); do
                echo -e "http_port ${NPT}" >>${CONF}
            done
        fi
    done <<<"${NEWCONF}"
    msg -azu "$(fun_trans "WAIT")"
    service squid restart &>/dev/null
    service squid3 restart &>/dev/null
    sleep 1s
    msg -bar
    msg -azu "$(fun_trans "PORTS REDEFINIDOS")"
    msg -bar
}
edit_apache() {
    msg -azu "$(fun_trans "REDEFINE APACHE PORTS")"
    msg -bar
    local CONF="/etc/apache2/ports.conf"
    local NEWCONF="$(cat ${CONF})"
    msg -ne "$(fun_trans "Nuevos puertos"): "
    read -p "" newports
    for PTS in $(echo ${newports}); do
        verify_port apache "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
            echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
            return 1
        }
    done
    rm ${CONF}
    while read varline; do
        if [[ $(echo ${varline} | grep -w "Listen") ]]; then
            if [[ -z ${END} ]]; then
                echo -e "Listen ${newports}" >>${CONF}
                END="True"
            else
                echo -e "${varline}" >>${CONF}
            fi
        else
            echo -e "${varline}" >>${CONF}
        fi
    done <<<"${NEWCONF}"
    msg -azu "$(fun_trans "WAIT")"
    service apache2 restart &>/dev/null
    sleep 1s
    msg -bar
    msg -azu "$(fun_trans "PORTS REDEFINED")"
    msg -bar
}
edit_openvpn() {
    msg -azu "$(fun_trans "REDEFINE OPENVPN PORTS")"
    msg -bar
    local CONF="/etc/openvpn/server.conf"
    local CONF2="/etc/openvpn/client-common.txt"
    local NEWCONF="$(cat ${CONF} | grep -v [Pp]ort)"
    local NEWCONF2="$(cat ${CONF2})"
    msg -ne "$(fun_trans "Nuevos puertos"): "
    read -p "" newports
    for PTS in $(echo ${newports}); do
        verify_port openvpn "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
            echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
            return 1
        }
    done
    rm ${CONF}
    while read varline; do
        echo -e "${varline}" >>${CONF}
        if [[ ${varline} = "proto tcp" ]]; then
            echo -e "port ${newports}" >>${CONF}
        fi
    done <<<"${NEWCONF}"
    rm ${CONF2}
    while read varline; do
        if [[ $(echo ${varline} | grep -v "remote-random" | grep "remote") ]]; then
            echo -e "$(echo ${varline} | cut -d' ' -f1,2) ${newports} $(echo ${varline} | cut -d' ' -f4)" >>${CONF2}
        else
            echo -e "${varline}" >>${CONF2}
        fi
    done <<<"${NEWCONF2}"
    msg -azu "$(fun_trans "WAIT")"
    service openvpn restart &>/dev/null
    /etc/init.d/openvpn restart &>/dev/null
    sleep 1s
    msg -bar
    msg -azu "$(fun_trans "PORTS REDEFINIDOS")"
    msg -bar
}
edit_dropbear() {
    msg -bar
    msg -azu "$(fun_trans "REDEFINE DROPBEAR PORTS")"
    msg -bar
    local CONF="/etc/default/dropbear"
    local NEWCONF="$(cat ${CONF} | grep -v "DROPBEAR_EXTRA_ARGS")"
    msg -ne "$(fun_trans "Nuevos puertos"): "
    read -p "" newports
    for PTS in $(echo ${newports}); do
        verify_port dropbear "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
            echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
            return 1
        }
    done
    rm ${CONF}
    while read varline; do
        echo -e "${varline}" >>${CONF}
        if [[ ${varline} = "NO_START=0" ]]; then
            echo -e 'DROPBEAR_EXTRA_ARGS="VAR"' >>${CONF}
            for NPT in $(echo ${newports}); do
                sed -i "s/VAR/-p ${NPT} VAR/g" ${CONF}
            done
            sed -i "s/VAR//g" ${CONF}
        fi
    done <<<"${NEWCONF}"
    msg -azu "$(fun_trans "WAIT")"
    service dropbear restart &>/dev/null
    sleep 1s
    msg -bar
    msg -azu "$(fun_trans "PORTS REDEFINIDOS")"
    msg -bar
}
edit_openssh() {
    msg -azu "$(fun_trans "REDEFINIR PUERTOS OPENSSH")"
    msg -bar
    local CONF="/etc/ssh/sshd_config"
    local NEWCONF="$(cat ${CONF} | grep -v [Pp]ort)"
    msg -ne "$(fun_trans "New Ports"): "
    read -p "" newports
    for PTS in $(echo ${newports}); do
        verify_port sshd "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
            echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
            return 1
        }
    done
    rm ${CONF}
    for NPT in $(echo ${newports}); do
        echo -e "Port ${NPT}" >>${CONF}
    done
    while read varline; do
        echo -e "${varline}" >>${CONF}
    done <<<"${NEWCONF}"
    msg -azu "$(fun_trans "WAIT")"
    service ssh restart &>/dev/null
    service sshd restart &>/dev/null
    sleep 1s
    msg -bar
    msg -azu "$(fun_trans "PORTS REDEFINIDOS")"
    msg -bar
}

main_fun() {
    msg -bar2
    msg -tit ""
    msg -ama "                EDITAR PORTS ACTIVOS "
    msg -bar
    lacasita
    msg -bar2
    unset newports
    i=0
    while read line; do
        let i++
        case $line in
        squid | squid3) squid=$i ;;
        apache | apache2) apache=$i ;;
        openvpn) openvpn=$i ;;
        dropbear) dropbear=$i ;;
        sshd) ssh=$i ;;
        esac
    done <<<"$(port | cut -d' ' -f1 | sort -u)"
    for ((a = 1; a <= $i; a++)); do
        [[ $squid = $a ]] && echo -ne "\033[1;32m [$squid] > " && msg -azu "$(fun_trans "REDEFINE SQUID PORTS")"
        [[ $apache = $a ]] && echo -ne "\033[1;32m [$apache] > " && msg -azu "$(fun_trans "REDEFINE APACHE PORTS")"
        [[ $openvpn = $a ]] && echo -ne "\033[1;32m [$openvpn] > " && msg -azu "$(fun_trans "REDEFINE OPENVPN PORTS")"
        [[ $dropbear = $a ]] && echo -ne "\033[1;32m [$dropbear] > " && msg -azu "$(fun_trans "REDEFINE DROPBEAR PORTS")"
        [[ $ssh = $a ]] && echo -ne "\033[1;32m [$ssh] > " && msg -azu "$(fun_trans "REDEFINE SSH PORTS")"
    done
    echo -ne "$(msg -bar)\n\033[1;32m [0] > " && msg -azu "\e[97m\033[1;41m RETURN \033[1;37m"
    msg -bar
    while true; do
        echo -ne "\033[1;37m$(fun_trans "Select"): " && read selection
        tput cuu1 && tput dl1
        [[ ! -z $squid ]] && [[ $squid = $selection ]] && edit_squid && break
        [[ ! -z $apache ]] && [[ $apache = $selection ]] && edit_apache && break
        [[ ! -z $openvpn ]] && [[ $openvpn = $selection ]] && edit_openvpn && break
        [[ ! -z $dropbear ]] && [[ $dropbear = $selection ]] && edit_dropbear && break
        [[ ! -z $ssh ]] && [[ $ssh = $selection ]] && edit_openssh && break
        [[ "0" = $selection ]] && break
    done
    #exit 0
}
main_fun
