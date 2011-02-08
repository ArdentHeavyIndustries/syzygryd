#!/bin/bash

# to use this, copy to the following location on the (linux) controller
#   /home/syzygryd/syzygryd/hide-cursor.sh

if [ -d ~syzygryd/.icons.moved ]; then
  mv ~syzygryd/.icons.moved ~syzygryd/.icons
  sudo service gdm restart
fi

##
## Local Variables:
##   mode: Shell-script
##   sh-basic-offset: 2
##   indent-tabs-mode: nil
## End:
##
## ex: set softtabstop=2 tabstop=2 expandtab:
##
