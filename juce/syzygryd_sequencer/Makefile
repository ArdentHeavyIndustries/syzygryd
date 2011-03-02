.PHONY: default debug release version

default: release

# XXX this currently needs to be run from the dir that the Makefile is located in
# XXX cmd line build only supported on OSX, not Windows

VERSION	:= $(shell svnversion | sed -r -e 's/^[[:digit:]]+:([[:digit:]]+).*$$/\1/')

debug:
	cd Builds/MacOSX && xcodebuild -configuration Debug -target Plugin && cd ../..

release:
	cd Builds/MacOSX && xcodebuild -configuration Release -target Plugin && cd ../..

version:
	@echo "The current svn repo version is $(VERSION)"
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
