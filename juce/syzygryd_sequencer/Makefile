.PHONY: default debug release version

default: release

# XXX this currently needs to be run from the dir that the Makefile is located in
# XXX cmd line build only supported on OSX, not Windows

# GNU sed uses -r for extended regexp's
# BSD sed uses -E for extended regexp's
# force native OSX sed so as not to get macports version
# XXX dammit, this doesn't work.  it did (at least the GNU form) for something like "726:802M", but it's not for something like "804M"
#VERSION	:= $(shell svnversion | sed -r -e 's/^[[:digit:]]+:([[:digit:]]+).*$$/\1/')
#VERSION	:= $(shell svnversion | /usr/bin/sed -E -e 's/^[[:digit:]]+:([[:digit:]]+).*$$/\1/')

debug:
	cd Builds/MacOSX && xcodebuild -configuration Debug -target Plugin && cd ../..

release:
	cd Builds/MacOSX && xcodebuild -configuration Release -target Plugin && cd ../..

version:
	@echo "The current svn repo version is given by the last number in \"`svnversion`\""
	@echo "BUT THIS IS PROBABLY ONLY VALID IF YOU FIRST RUN \"svn update\" from this directory"
	@echo "Add one to that and edit the String in MainComponent::paint() in Source/Components/MainComponent.cpp if you are ready to check in"

clean:
	rm -f -r Builds/MacOSX/build

##
## Local Variables:
##   mode: Makefile
##   tab-width: 3
## End:
##
## vim: tabstop=3 shiftwidth=3
##
