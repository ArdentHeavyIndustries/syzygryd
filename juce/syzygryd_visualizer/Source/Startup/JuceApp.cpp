/*
 *  JuceApp.cpp
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "MainWindow.h"

#include "JuceApp.h"

JuceApp::JuceApp() :
mainWindow (0)
{
}

JuceApp::~JuceApp()
{
}

void JuceApp::initialise (const String& commandLine)
{
	mainWindow = new MainWindow();
}

void JuceApp::shutdown()
{
	if (mainWindow != 0) delete mainWindow;
}

const String JuceApp::getApplicationName()
{
	return T("Syzygryd Visualizer");
}

const String JuceApp::getApplicationVersion()
{
	return T("1.0");
}

bool JuceApp::moreThanOneInstanceAllowed()
{
	return true;
}

void JuceApp::anotherInstanceStarted (const String& commandLine)
{
}
