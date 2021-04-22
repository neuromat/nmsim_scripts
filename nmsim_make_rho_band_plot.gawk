#! /usr/bin/gawk -f
# Last edited on 2020-12-18 00:28:30 by jstolfi

# Reads from {stdin} the trace file of a set of neurons 
# and writes to {stdout} a single-row PPM image with 
# one column for each sampling time, whose value is
# the activity {rho} at that times  color-mapped from 
# {[0 _ rhomax]} to {0 .. 65535}.

BEGIN { 

  # User must define with "-v" the variables:
  #   {nTimes} expected number of data samples.
  #   {rhoMax} max value of {rho} for color mapping.
  #   {color}  the color to use for {rho = rhoMax}, a string of three nums in {0..65535}.
  
  nTimes += 0;
  rhoMax += 0;
  printf "nTimes = %d rhoMax = %.5f color = '%s'\n", nTimes, rhoMax, color > "/dev/stderr"
 
  maxval = 65535;
  printf "P3\n";
  printf "%d 1\n", nTimes;
  printf "%d\n", maxval;
  nBig = 0;  # Number of data values above {rhoMax}.
  nData = 0; # Number of lines processed.
  nSkip = 0; # Number of lines skipped.
  
  # Extremes of the color scale:
  split("65535 65535 65535", rgbMin); # Pixel sample values for {rho = 0}.
  split(color, rgbMax); # Pixel sample values for {rho = rhoMax}.
  
}

/^[ ]*[0-9]/ { 
  nData++;
  rho = $6 + 0;
  r = rho/rhoMax;
  if ((rho < 0) || (rho > 1)) {
    printf "** line count mismatch %d %d\n", nTimes, nData > "/dev/stderr"; 
    exit(1);
  }  
  if (rho > rhoMax) { nBig++; r = 1.0 }
  s = 1 - r;
  for (ich = 1; ich <= 3; ich++)
    { val = int(s*rgbMin[ich] + r*rgbMax[ich] + 0.5);
      if (val < 0) { val = 0; }
      if (val > maxval) { val = maxval; }
      printf " %d", val;
    }
  printf "\n"
  next;
}

// { 
  nSkip++;
  next;
}

END { 
  fflush()
  printf "processed %d lines\n", nData > "/dev/stderr"; 
  printf "skipped %d lines\n", nSkip > "/dev/stderr"; 
  if (nBig > 0) {
    printf "!! warning - %d rho values over %.5f\n", nBig, rhoMax > "/dev/stderr"; 
  }
  if (nData != nTimes) {
    printf "** line count mismatch %d %d\n", nTimes, nData > "/dev/stderr"; 
    exit(1);
  }
}

