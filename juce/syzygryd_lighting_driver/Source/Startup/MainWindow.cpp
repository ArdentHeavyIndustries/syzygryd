/*
 *  MainWindow.cpp
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include "MainComponent.h"

#include "MainWindow.h"

MainWindow::MainWindow() :
DocumentWindow (T("Syzygryd Test"),
				Colours::lightgrey,
				DocumentWindow::allButtons,
				true)
{
	MainComponent* const mainComponent = new MainComponent();
	setContentComponent (mainComponent, true, true);
	centreWithSize (getWidth(), getHeight());
	setVisible (true);
	setResizable (true, true);
}

MainWindow::~MainWindow()
{
}

void MainWindow::closeButtonPressed()
{
	JUCEApplication::quit();
}

