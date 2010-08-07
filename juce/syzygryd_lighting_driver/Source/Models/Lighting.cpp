/*
 *  Lighting.cpp
 *  syzygryd_lighting_driver2
 *
 *  Created by Matt Sonic on 8/5/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#include <fcntl.h>
#include "Light.h"

#include "Lighting.h"

const int kNumLights = 36;

const String kRemoteHost = "127.0.0.1";
const int kRemotePort = 3333;
const int kOutputBufferSize = 1024;
const int kTimeoutMs = 20;

Lighting::Lighting() : 
Thread ("Lighting"),
motionIndex (0)
{
	for (int i = 0; i < kNumLights; i++) {
		Light* light = new Light (Colours::black);
		lights.add (light);
	}

	socket.connect (kRemoteHost, kRemotePort, kTimeoutMs);
}

Lighting::~Lighting()
{
	socket.close();
}

void Lighting::send()
{
	
	String frameStart ("7E05");

	//String channelSize ("6C00");
	int channelSize = kNumLights * 3; // 108
	String channelSizeHex = String::toHexString (channelSize);
	String channelSizeString;
	channelSizeString << channelSizeHex << "00";

	String data;
	String frameEnd ("E7");
	
	String message;

	for (int i = 0; i < kNumLights; i++) {
		Light* light = lights[i];
		int r = light->getColor().getRed();
		int g = light->getColor().getGreen();
		int b = light->getColor().getBlue();
		String red = String::toHexString (r);
		String green = String::toHexString (g);
		String blue = String::toHexString (b);
		red = red.paddedLeft ('0', 2);
		green = green.paddedLeft ('0', 2);
		blue = blue.paddedLeft ('0', 2);
		
		data << red << green << blue;
	}

	message << frameStart << channelSizeString << data << frameEnd;
	
	DBG (message)
	
	MemoryBlock memory;
	memory.loadFromHexString (message);
	
	/*
	String pipePath ("/Users/matt/Desktop/my_pipe");
	int fd = open (pipePath.toUTF8(), O_RDWR);
	write (fd, memory.getData(), memory.getSize());	
	 */
	if (socket.isConnected()) {
		socket.write (memory.getData(), memory.getSize());
	} else {
		DBG ("Could not connect")
		socket.close();
		socket.connect (kRemoteHost, kRemotePort, kTimeoutMs);
	}
}

// Thread methods
void Lighting::run()
{
	Random rand (1000);

	while (! threadShouldExit()) {
		Thread::sleep (100);
		
		for (int i = 0; i < kNumLights; i++) {
			//data << "FF";
			Light* light = lights[i];
			
			/*
			int r = rand.nextFloat() * 55;
			int g = rand.nextFloat() * 55;
			int b = rand.nextFloat() * 55;
			
			Colour color = Colour::fromRGB (r, g, b);
			light->setColor (color);
			*/
			if (i == motionIndex) {
				light->setColor (Colour::fromRGB (255, 0, 0));
			} else {
				light->setColor (Colour::fromRGB (0, 0, 0));
			}
		}
		
		motionIndex = (motionIndex + 1) % kNumLights;
		
		if (socket.isConnected()) {
			send();
		}
	}
}


