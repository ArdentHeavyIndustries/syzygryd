/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#define DMX_COUNT 513

#include <pthread.h>
#include <stdint.h>
#include <color.h>


struct DMX
{
private:
	pthread_t _thread;
	char* _path;
	int _dmxFd;
	
public:
	pthread_mutex_t _mutex;
	uint8_t world[DMX_COUNT];
	
	DMX();
	~DMX();
	
	void Start( const char* path );
	void Close();
	void Stop();

	bool IsRunning();
	void SetColorForLight(hsv_t hsv, int index);
	void Animate( float tdelta );
	
	void ReadThread();
};
