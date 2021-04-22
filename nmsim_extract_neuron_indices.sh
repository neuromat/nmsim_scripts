#! /bin/bash
# Last edited on 2020-12-17 23:21:46 by jstolfi

# Takes a file name that includes the substring "ne{ILO}--{IHI}"
# surrounded by "_" or ".", where {ILO} and {IHI} are the indices
# {ineLo,ineHi} of two neurons, possibly zero-padded. Writes to stdout
# the two indices.

fname="$1"; shift

ines="${fname##*[_.]ne}"
ines="${ines%%[_.]*}"
ineLo="${ines%--*}"; 
ineLo=$(( 0 + 10#${ineLo} )) # To get rid of leading zeros.
ineHi="${ines#*--}"; 
ineHi=$(( 0 + 10#${ineHi} )) # To get rid of leading zeros.
if [[ ${ineLo} -gt ${ineHi} ]]; then 
  echo "${cmd}: ** invalid neuron indices ${ineLo}..${ineHi}" 1>&2; exit 1
fi
printf "%d %d\n" "${ineLo}" "${ineHi}"
