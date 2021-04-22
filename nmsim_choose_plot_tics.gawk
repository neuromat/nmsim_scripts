#! /usr/bin/gawk -f
# Last edited on 2020-12-25 20:31:48 by jstolfi

BEGIN {
  # User must define with "-v" the the range of data values {vLo,vHi} and
  # the approximate size of the plot in pixels {nPix} (before the 50%
  # reduction).
  #
  # The program outputs four float numbers: the min and max values to use
  # in the plot, a suitable major tic spacing, and the number of minor tic
  # intervals per major tic interval.

  if (vLo == "") { arg_error("must define {vLo}"); } vLo += 0;
  if (vHi == "") { arg_error("must define {vHi}"); } vHi += 0;
  if (nPix == "") { arg_error("must define {nPix}"); } nPix += 0;
  
  # Compute the plot range {pLo,pHi}:
  vDel = vHi - vLo;
  vEps = 0.02*vDel;
  
  pLo = vLo - vEps;
  pHi = vHi + vEps;

  # Choose the tic spacings:
  ups = vDel/nPix*64; # Data units per 64 pixels.
  if (ups < 0.001) {
    vTic = 0.001
  } else if (ups < 0.0035) {
    vTic = 0.005
  } else if (ups < 0.01) {
    vTic = 0.01
  } else if (ups < .035) {
    vTic = 0.05
  } else if (ups < 0.1) {
    vTic = 0.1
  } else if (ups < 0.35) {
    vTic = 0.5
  } else if (ups < 1.0) {
    vTic = 1.0
  } else if (ups < 3.5) {
    vTic = 5.0
  } else if (ups < 10.0) {
    vTic = 10
  } else if (ups < 35.0) {
    vTic = 50
  } else if (ups < 100) {
    vTic = 100
  } else if (ups < 350) {
    vTic = 500
  } else if (ups < 1000) {
    vTic = 1000
  } else {
    vTic = 5000
  }
  mTics = 5

  printf "%.5f %.5f %.5f %d\n", pLo, pHi, vTic, mTics
}
