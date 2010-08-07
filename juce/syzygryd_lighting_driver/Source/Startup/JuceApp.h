/*
 *  JuceApp.h
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef JUCE_APP_H
#define JUCE_APP_H

class MainWindow;

#include "JuceHeader.h"

class JuceApp : public JUCEApplication
{
public:
	JuceApp();
	~JuceApp();
	void initialise (const String& commandLine);
	void shutdown();
	const String getApplicationName();
	const String getApplicationVersion();
	bool moreThanOneInstanceAllowed();
	void anotherInstanceStarted (const String& commandLine);

private:
	MainWindow* mainWindow;
};

#endif
