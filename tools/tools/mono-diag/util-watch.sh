#!/bin/sh
# TEST: every second, the share of that second dtsec3's receive port spent at
# or above fixed levels (hundredths of a percent), next to its MAC input
# errors, to see whether the FIFO is full when frames are lost.
#   sh util-watch.sh start [log] | stop
PIDF=/tmp/util-watch.pid
S=dev.dtsec.3
case "$1" in
start)
	LOG=${2:-/root/util-watch.log}
	[ -f ${PIDF} ] && kill $(cat ${PIDF}) 2> /dev/null
	sysctl -q ${S}.rx_util_cmp="65536 24 16" > /dev/null || { echo "levels refused"; exit 1; }
	(
		echo "time fifo>=64K tasks>=24 dmas>=16 ierrs"
		while :; do
			u=$(sysctl -n ${S}.rx_util)
			echo "$(date +%T) ${u} $(netstat -I dtsec3 -n | awk '/Link/ {print $6}')"
		done
	) > ${LOG} 2>&1 &
	echo $! > ${PIDF}
	echo "watching to ${LOG}"
	;;
stop)
	[ -f ${PIDF} ] && kill $(cat ${PIDF}) 2> /dev/null && rm -f ${PIDF} && echo stopped || echo "not running"
	;;
*)
	echo "usage: sh util-watch.sh start [log] | stop"
	;;
esac
