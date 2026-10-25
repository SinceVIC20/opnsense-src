#!/bin/sh
# TEST: how full dtsec3's receive FIFO, tasks and DMAs get. For each level,
# the share of one second spent at or above it (hundredths of a percent).
#   sh util-sweep.sh [port]   (run while traffic flows; about 30 s)
N=${1:-3}
S=dev.dtsec.${N}
echo "level  fifo_bytes>=  tasks>=  dmas>=   share_fifo share_tasks share_dmas"
set -- "4096 2 1" "8192 4 2" "16384 8 4" "24576 12 6" "32768 14 8" \
    "40960 16 10" "49152 20 12" "57344 24 14" "65536 26 15" "73728 28 16"
for lv in "$@"; do
	sysctl -q ${S}.rx_util_cmp="${lv}" > /dev/null || { echo "refused: ${lv}"; continue; }
	set -- ${lv}
	u=$(sysctl -n ${S}.rx_util)
	set -- $1 $2 $3 ${u}
	printf "%-6s %-13s %-8s %-8s %5d.%02d%% %5d.%02d%% %5d.%02d%%\n" "" $1 $2 $3 \
	    $(($4 / 100)) $(($4 % 100)) $(($5 / 100)) $(($5 % 100)) $(($6 / 100)) $(($6 % 100))
done
