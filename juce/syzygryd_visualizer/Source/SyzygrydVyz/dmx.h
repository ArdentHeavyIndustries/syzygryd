/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#define DMX_COUNT 513

//#include <pthread.h>

#include "color.h"

#include "JuceHeader.h"

#ifdef JUCE_WINDOWS
   #include "stdint.h"
#else
   #include <stdint.h>
#endif

class DMX : public Thread
{
public:
	DMX();
	~DMX();
	
	const String& getLastData();
	
	// Thread methods
	virtual void run();
	
	void Start( const char* path );
	void Close();
	void Stop();

	bool IsRunning();
	void SetColorForLight(hsv_t hsv, int index);
	void Animate( float tdelta );
	
	CriticalSection cs;
	uint8_t world2[DMX_COUNT];
	uint8_t world[DMX_COUNT];
	//pthread_mutex_t _mutex;

private:
	//pthread_t _thread;
	char* _path;
	int _dmxFd;
	
	String lastData;
	
	StreamingSocket socket;
	StreamingSocket* listenSocket;
};
