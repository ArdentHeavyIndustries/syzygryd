/*
 *  MainWindow.h
 *  syzygryd_visualizer2
 *
 *  Created by Matt Sonic on 3/27/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include "JuceHeader.h"

class MainWindow : public DocumentWindow
{
public:
	MainWindow();
	~MainWindow();
	void closeButtonPressed();
};

#endif
