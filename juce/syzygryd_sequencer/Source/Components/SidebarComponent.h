/*
 *  SidebarComponent.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 6/20/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef SidebarComponent_H
#define SidebarComponent_H

#include "JuceHeader.h"

class Sequencer;
class PanelComponent;

class SidebarComponent : public Component
{
public:
	SidebarComponent (Sequencer* sequencer_);
	~SidebarComponent();
	
	// Component methods
	virtual void paint (Graphics& g);
	virtual void resized();

private:
	Sequencer* sequencer;
	Array<PanelComponent*> panelComponents;
};

#endif
