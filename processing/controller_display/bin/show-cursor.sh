#!/bin/bash

# to use this, copy to the following location on the (linux) controller
#   /home/syzygryd/syzygryd/show-cursor.sh

if [ -d ~syzygryd/.icons ]; then
  mv ~syzygryd/.icons ~syzygryd/.icons.moved
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
