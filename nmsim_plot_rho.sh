#! /bin/bash
# Last edited on 2021-01-11 07:51:21 by jstolfi

# Reads the trace of a set of consecutive neurons in an elem_level simulation.
# Plots the activity {rho[t]} (average of {X[t]} over those neurons)
# The vertical axis is in mV.

cmd="$0"; cmd="${cmd##*/}"

show=$1; shift     # 1 to display the plot
fname="$1"; shift  # Trace file name 
ineLo="$1"; shift  # Index of first neuron.
ineHi="$1"; shift  # Index of last neuron.
tLo="$1"; shift;   # First time to plot.
tHi="$1"; shift;   # Last time to plot.
rhoMax="$1"; shift  # Max activity to plot, fractional in [0 _ 1].

# END COMMAND LINE PARSING
# ----------------------------------------------------------------------

# Prefix for temporary file names
tmp="/tmp/$$"

hPix=1800
hTics=( `nmsim_choose_plot_tics.gawk -v vLo=${tLo} -v vHi=${tHi}    -v nPix=${hPix}` )

# Decide the title and plotting range:
if [[ ${ineLo} -lt ${ineHi} ]]; then
  title="Neurons ${ineLo} .. ${ineHi} - Activity rho[t]"
  vPix=600
  vTics=( -0.04 1.04 0.1 2 )
else
  title="Neuron ${ineLo} - Firings X[t]"
  vPix=400
  vTics=( -0.08 1.08 0.2 2 )
fi

echo "{${cmd}}: title = \"${title}\"" 1>&2

which="rho"

tfile="${tmp}_${which}.png"

export GDFONTPATH="."

gnuplot <<EOF
  set terminal png truecolor size ${hPix},${vPix} font "arial,18"
  set output "${tfile}"
  
  ineLo = ${ineLo}
  ineHi = ${ineHi}

  set grid x2tics ytics mx2tics lt 3 lw 2 lc rgb '#ffddaa', lt 0 lw 1 lc rgb '#ccbb88'

  # Choose horizontal range and tics:
  set xrange [(${hTics[0]}):(${hTics[1]})]
  set x2tics ${hTics[2]}
  set mx2tics ${hTics[3]}
  set xzeroaxis 

  # Choose vertical range and tics:
  set yrange [(${vTics[0]}):(${vTics[1]})]
  set ytics ${vTics[2]}
  set mytics ${vTics[3]}
  set yzeroaxis 
   
  # set bmargin 0.5
  set lmargin 8; set rmargin 8
  set title "${title}"
  set nokey
  
  if (ineLo < ineHi) {
    plot \
      "< egrep -e '^[ ]*[0-9]' ${fname}" \
        using 1:6 title "${which}[t]" with linespoints pt 7 ps 1 lt 1 lw 2 lc rgb '#0022cc'
  } else {
    plot \
      "< egrep -e '^[ ]*[0-9]' ${fname}" \
        using 1:6 title "${which}[t]" with impulses lt 1 lw 1 lc rgb '#0022cc', \
      "" using 1:6 notitle with points pt 7 ps 1 lc rgb '#0022cc'
  }
EOF


if [[ -s ${tfile} ]]; then
  pfile="${fname%.*}_${which}.png"
  convert ${tfile} -resize '50%' ${pfile}
  if [[ ${show} -ne 0 ]]; then display ${pfile}; fi
  rm ${tfile}
fi
