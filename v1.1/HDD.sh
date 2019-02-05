#!/bin/bash
LANG=ja_JP.UTF-8

disknameln=17

mystrln() {
    local dn=0 mb=0
    for ((j = 0; j < $((${#1})); ++j))
    do
        [ `echo -n ${1:$j:1} | wc -c` -le 1 ] && fd=1 || fd=2
        dn=$(($dn+$fd))
        if ((dn > $2)); then
            break
        else
            [ $fd -eq 2 ] && mb=$(($mb+1))
        fi
    done
    printf -v $3 "%s" "`echo -n ${1:0:$j}`"
    printf -v $4 "%d" $(($mb+$2))
} 

printf '\033[4m%-*s%5s%7s%7s%17s\033[0m\n' $disknameln "Drive" "Size" "Used" "Avail" "Capacity"
_IFS="$IFS";IFS=$'\n'
dfdata=`df -h | grep '/dev/disk\|/Volumes/' | grep -v 'private/var/vm\|firmwaresyncd\|com.apple.TimeMachine.localsnapshots'`
diskdata=(`echo "$dfdata" | awk '{print $2,$3,$4}' | sed -e 's/Mi/MB/g' -e 's/Gi/GB/g' -e 's/Ti/TB/g'`)
diskcapa=(`echo "$dfdata" | awk '{print $5}' | sed -e 's/\%//g'`)
diskname=(`echo "$dfdata" | awk '{for(i=9;i<=NF;i++)printf $i" ";print ""}' | sed -e 's/\/Volumes\///g' -e '1s/\//Macintosh HD/' -e 's/[ ]*$//'`)
IFS="$_IFS"
for (( i = 0; i < ${#diskdata[@]}; ++i ))
do
    mystrln "${diskname[$i]}" $disknameln s1 s2
    printf "%-*s" $s2 "$s1"
    printf "%5s%7s%7s  " ${diskdata[$i]}
    typeset -i b=4
    while [ $b -lt ${diskcapa[$i]} ]
    do
        printf "\033[0;37m▇\033[0m"
   	    b=$(($b+10))
    done
    while [ $b -lt 100 ]
    do
        printf "\033[0;30m▇\033[0m"
        b=$(($b+10))
    done
    printf "%4s%%\n" ${diskcapa[$i]}
done 