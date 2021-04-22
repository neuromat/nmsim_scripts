#! /bin/bash
# Last edited on 2021-01-11 07:51:15 by jstolfi

# Reads the trace of a set of consecutive neurons in an elem_level simulation.
# Plots the average potential those neurons as a function of time.

# If there is only one neuron, also plots the firings as dots on an horizontal line.

cmd="$0"; cmd="${cmd##*/}"

show=$1; shift     # 1 to display the plot
fname="$1"; shift  # Trace file name.
ineLo="$1"; shift  # Index of first neuron.
ineHi="$1"; shift  # Index of last neuron.
tLo="$1"; shift    # Min time to plot, as integer number of ms, or ''.
tHi="$1"; shift    # Max time to plot, as integer number of ms, or ''.
vLo="$1"; shift    # Min voltage to plot, as integer number of mV.
vHi="$1"; shift    # Max voltage to plot, as integer number of mV.
vX="$1"; shift     # Voltage where to plot the firing dots.

# END COMMAND LINE PARSING
# ----------------------------------------------------------------------

# Prefix for temporary file names
tmp="/tmp/$$"

# Decide the title and ordinate of the spike dots:
if [[ ${ineLo} -lt ${ineHi} ]]; then
  title="Neurons ${ineLo} .. ${ineHi} - Potential V[t] (mV)"
  plotX=""
  keyopt=""
else
  title="Neuron ${ineLo} - Potential V[t] (mV) and firings X[t]"
  # Choose the ordinate ${vX} where to show the firings:
  plotX=", '' using 1:(dot(6)) title 'X[t]' with points pt 7 ps 1.25 lc rgb '#003399' "
  keyopt="set key top right"
fi

hPix=1800
vPix=600
hTics=( `nmsim_choose_plot_tics.gawk -v vLo=${tLo} -v vHi=${tHi} -v nPix=${hPix}` )
vTics=( `nmsim_choose_plot_tics.gawk -v vLo=${vLo} -v vHi=${vHi} -v nPix=${vPix}` )

echo "{${cmd}}: title = ${title} vX = ${vX}" 1>&2

tfile="${tmp}.png"

export GDFONTPATH="."

gnuplot <<EOF
  set terminal png truecolor size ${hPix},${vPix} font "arial,18"
  set output "${tfile}"

  set grid xtics ytics mxtics lt 3 lw 2 lc rgb '#ffddaa', lt 0 lw 1 lc rgb '#ccbb88'

  # Choose horizontal range and tics:
  set xrange [(${hTics[0]}):(${hTics[1]})]
  set xtics ${hTics[2]}
  set mxtics ${hTics[3]}
  set xzeroaxis 

  # Choose vertical range and tics:
  set yrange [(${vTics[0]}):(${vTics[1]})]
  set ytics ${vTics[2]}
  set mytics ${vTics[3]}
  set yzeroaxis 
  
  set lmargin 8; set rmargin 8
  set title "${title}"
  ${keyopt}

  # Returns ${vX} if (column(k)) is 1, undef if it is 0:
  dot(k) = (column(k) == 0 ? 0/0 : ${vX})
  plot \
    "< egrep -e '^[ ]*[0-9]' ${fname}" using 1:2 title "V[t]" \
      with linespoints pt 7 ps 1 lt 1 lw 2 lc rgb '#008800' \
      ${plotX}
EOF

# color=( "ff0000" "996600" "338800" "008800" "007755" "0033ff" "5500ff" "aa0066" "aa2200" "557700" "117700" "007722" "005588" "2222ff" "880088" )

if [[ -s ${tfile} ]]; then
  pfile="${fname%.*}_VX.png"
  convert ${tfile} -resize '50%' ${pfile}
  if [[ ${show} -ne 0 ]]; then display ${pfile}; fi
  rm ${tfile}
fi
