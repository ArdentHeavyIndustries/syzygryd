#!/usr/bin/env perl

use warnings;
use strict;
use English;

# copy this to /opt/syzygryd/bin/logRoll.pl
# (on both the syzyputer, and all of the controllers)

# usage: logRoll.pl <logBase>

# XXX could have an option to roll all of the logs if no logBase specified

my $LOGDIR = "/opt/syzygryd/log";

sub safeSystem($) {
   my ($cmd) = @_;
   chomp $cmd;
   print $cmd, "\n";
   my $returnValue = system($cmd);
   if ($returnValue != 0) {
      die "System call \"$cmd\" failed";
   }
}

# early declaration necessary for recursion
sub doRoll($$);

sub doRoll($$) {
   my ($logbase, $n) = @_;
   my $src;
   my $dest;

   if ($n == 0) {
      $src = $LOGDIR . '/' . $logbase . '.log';
   } else {
      $src = $LOGDIR . '/' . $logbase . '.' . $n . '.log';
   }
   if (!-e $src) {
      return;
   }

   $dest = $LOGDIR . '/' . $logbase . '.' . ($n + 1) . '.log';
   # if the dest file exists, first roll that by calling recursively
   # XXX no recursion limit check implemented
   if (-e $dest) {
      doRoll($logbase, $n + 1);
   }

   safeSystem("mv $src $dest");
}

if ($#ARGV != 0) {
   print "Rolls logs for a given program in $LOGDIR\n";
   print "The <logBase> is the base name of the log files.\n";
   print "For example, to roll all switcher logs (named switcher*log), use <logBase>=\"switcher\"\n";
   print "\n";
   print "usage: $PROGRAM_NAME <logBase>\n";
   exit (0);
} else {
   my $logbase = $ARGV[0];
   doRoll($logbase, 0);
}

##
## Local Variables:
##   mode: Perl
##   perl-indent-level: 3
##   indent-tabs-mode: nil
## End:
##
## ex: set softtabstop=3 tabstop=3 expandtab sw=3:
##
