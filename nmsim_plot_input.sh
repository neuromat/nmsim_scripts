#! /bin/bash
# Last edited on 2021-01-11 07:51:00 by jstolfi

# Reads the trace of a set of consecutive neurons in an elem_level simulation.
# Plots external, synaptic, or total input as a function of time.
# The vertical axis is in mV.

cmd="$0"; cmd="${cmd##*/}"

show=$1; shift     # 1 to display the plot
fname="$1"; shift  # Trace file name 
ineLo="$1"; shift  # Index of first neuron.
ineHi="$1"; shift  # Index of last neuron.
tLo="$1"; shift;   # First time to plot.
tHi="$1"; shift;   # Last time to plot.
vLo="$1"; shift   # Min voltage to plot, as integer number of mV.
vHi="$1"; shift   # Max voltage to plot, as integer number of mV.
which="$1"; shift  # "I" for external, "S" for synaptic, or "J" for total.

# END COMMAND LINE PARSING
# ----------------------------------------------------------------------

# Prefix for temporary file names
tmp="/tmp/$$"

# Decide the column of the trace file to plot:
if [[ "/${which}" == "/I" ]]; then
  pltexpr="(column(7))"
  varname="External"
elif [[ "/${which}" == "/S" ]]; then
  pltexpr="(column(8)-column(7))"
  varname="Synaptic"
elif [[ "/${which}" == "/J" ]]; then
  pltexpr="(column(8))"
  varname="Total"
else
  echo "{${cmd}}: ** invalid variable name \"${which}\"" 1>&2; exit 1
fi

# Decide the title:
if [[ ${ineLo} -lt ${ineHi} ]]; then
  title="Neurons ${ineLo} .. ${ineHi} - ${varname} input ${which}[t] (mV)"
else
  title="Neuron ${ineLo} - ${varname} input ${which}[t] (mV)"
fi

hPix=1800
vPix=400
hTics=( `nmsim_choose_plot_tics.gawk -v vLo=${tLo} -v vHi=${tHi} -v nPix=${hPix}` )
vTics=( `nmsim_choose_plot_tics.gawk -v vLo=${vLo} -v vHi=${vHi} -v nPix=${vPix}` )

echo "{${cmd}}: title = ${title}" 1>&2

tfile="${tmp}_${which}.png"

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
  
  # set bmargin 0.5
  set lmargin 8; set rmargin 8
  set title "${title}"
  set nokey

  plot \
    "< egrep -e '^[ ]*[0-9]' ${fname}" \
      using 1:${pltexpr} title "${which}[t]" with impulses lt 1 lw 1 lc rgb '#0022cc', \
    "" using 1:${pltexpr} title "${which}[t]" with points pt 7 ps 0.75 lc rgb '#0022cc'
EOF

if [[ -s ${tfile} ]]; then
  pfile="${fname%.*}_${which}.png"
  convert ${tfile} -resize '50%' ${pfile}
  if [[ ${show} -ne 0 ]]; then display ${pfile}; fi
  rm ${tfile}
fi
