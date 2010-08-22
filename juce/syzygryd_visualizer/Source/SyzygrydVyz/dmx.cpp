/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

#include <stdlib.h>
#include <string.h>
#include <ctype.h>	// for isupper, etc.
#include <math.h>	// for pow, sqrt, etc.
#include <stdio.h>	// for printf
#include <stdint.h>	// for uint8_t

/*
#include <termios.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
*/
#include <time.h>
#include <math.h>
//#include <IOKit/serial/ioss.h>  // for IOSSIOSPEED
#include <errno.h>

//#include <unistd.h>

#include "dmx.h"
#include "color.h"

#define bzero(b,len) (memset((b), '\0', (len)), (void) 0)
#define MIN(a, b)  (((a) < (b)) ? (a) : (b))

const int kTimeoutMs = 1000;
const int kPortNumber = 3333;
const int kInputBufferSize = 1000;

void send_message( int fd, uint8_t command, uint8_t *data, int dataSize )
{
	uint8_t DMX_PRO_MESSAGE_START = 0x7E;
	uint8_t DMX_PRO_MESSAGE_END = 0xE7;
	
	uint8_t *msg = (uint8_t*)malloc(dataSize + 5);
	msg[0] = DMX_PRO_MESSAGE_START;
	msg[1] = command;
	msg[2] = (uint8_t)(dataSize & 255); 
	msg[3] = (uint8_t)((dataSize >> 8) & 255);
	memcpy(msg+4, data, dataSize);
	msg[dataSize + 4] = DMX_PRO_MESSAGE_END;
}


void recv_new_message(StreamingSocket& socket, uint8_t start, uint8_t *command, 
					  uint8_t **data, int *dataSize, uint8_t *armNum)
{
	// param check and init
	if( command && data && dataSize )
		*command = 0, *data = NULL, *dataSize = 0;
	else
		return;
	
	/*
	// loop and wait for start of message, but only for a second or so
	uint8_t start;
	do {
		if( socket.read(&start, 1, false) != 0 )
			break;
	} while( start!=0x7E );
	*/
	
	*armNum = start;
	
	socket.read(&start, 1, false);
	
	// got the start byte? read the header
	if( start == 0x7E )
	{
		uint8_t header[3];
		if( socket.read(header, sizeof(header), false) == sizeof(header) )
		{
			// replace command byte
			*command = header[0];
			*dataSize = (header[2]<<8) | header[1];
			if( *dataSize > 0 && *dataSize <= 600 )
			{
				// now read in the data
				*data = (uint8_t*)malloc(*dataSize);
				if( socket.read(*data, *dataSize, false) == *dataSize )
				{
				}
			}
		}
		
		// read the footer
		socket.read(&start, 1, false);
		if( start!=0xE7 )
		{
			printf ("Failed to read the packet footer.\n");
			// failed
			free(*data);
			*data = NULL;
			*dataSize = 0;
			*command = -1;
		}
	}
}





DMX::DMX() : 
Thread ("DMX"),
//_thread(NULL), 
_path(NULL), 
_dmxFd(-1),
listenSocket (0)
{
	bzero(world, DMX_COUNT);
	bzero(world2, DMX_COUNT);

	socket.createListener (kPortNumber);
}


DMX::~DMX()
{
	Stop();
	
	if (listenSocket != 0) {
		listenSocket->close();
	}
	socket.close();
}

const String& DMX::getLastData()
{
	return lastData;
}

// Thread methods
void DMX::run()
{
	//File f("MyLog.txt");
	//f.appendText ("DMX::run()\n");
/*
	// open the device
	if( _path && (_dmxFd=open(_path, O_RDWR | O_NOCTTY ))>=0 )
	{
		int ret;
*/		
		/*// options???
		 termios options;
		 ret = tcgetattr(_dmxFd, &options);
		 cfsetispeed(&options, B230400);
		 options.c_cflag |= (CLOCAL | CREAD);
		 
		 options.c_cflag &= ~PARENB;
		 options.c_cflag &= ~CSTOPB;
		 options.c_cflag &= ~CSIZE;
		 options.c_cflag |= CS8;
		 
		 ret = tcsetattr(_dmxFd, TCSANOW, &options);*/
		
		// set the speed
		//speed_t speed = 250000;
		//ret = ioctl(_dmxFd, IOSSIOSPEED, &speed);
		//if( ret )
		//	fprintf(stderr, "error setting speed: %i, %i", ret, errno);
		
		// set IO mode to RX
		//uint8_t data = 0;
		//send_message(_dmxFd, 3, &data, 1);
		
		//data = 1;
		//send_message(_dmxFd, 8, &data, 1);
		
		// loop and read
		clock_t start = clock();
		clock_t last = clock();
		int frame_count = 0;
		int error_count = 0;
		
		//f.appendText ("before threadShouldExit\n");
		while (!threadShouldExit())
		{
			//f.appendText ("before create socket\n");
			if (listenSocket == 0) {
				listenSocket = socket.waitForNextConnection();
			}
			
			//f.appendText ("before read\n");
			uint8_t start = 0;
			if (listenSocket->read (&start, 1, false) < 1) {
				DBG ("Could not read from socket")
				deleteAndZero (listenSocket);
				continue;
			}	
			
			//char buffer[kInputBufferSize];
			//int bytesRead = 0;
			//if (!(bytesRead = socket.read (buffer, kInputBufferSize, false))) {
			//	continue;
			//}	
			
			//if( pthread_mutex_lock(&_mutex)==0 )
			{
				ScopedLock lock (cs);
				// read
				uint8_t command;
				uint8_t *data;
				int dataSize;
				uint8_t armNum;
				//f.appendText ("before receive new message\n");
				recv_new_message(*listenSocket, start, &command, &data, &dataSize, &armNum);
				printf ("command: %d dataSize: %d\n", command, dataSize);
				if( data )
				{
					// Preprocess J's DMX data from the socket
					if (command == 6) {
						command = 5;
					}
					// dmx receive
					if( command == 5)
					{
						//String dbg;
						//dbg << "DATA: ";
						//lastData = String::empty;
						for (int i = 0; i < dataSize; i++) {
							printf ("%02X", data[i]);
							//String newData = String::toHexString (data[i]);
							//newData = newData.paddedLeft ('0', 2).toUpperCase();
							//lastData << newData << " ";
						}
						//dbg << "\n";
						printf ("\n");
						if( dataSize <= 1 )
							error_count++;
						
						else
						{
							//f.appendText (dbg);
							// copy to output world
							memcpy(world, data, MIN(DMX_COUNT,dataSize-1));
							//memcpy(world2, data, MIN(DMX_COUNT,dataSize));

							int numLights = 36;
							int worldLightOffset = numLights*3*(armNum);
							// Copy lights
							for (int i = 0; i <= numLights*3; i++) {
								world2[i+worldLightOffset] = data[i];
							}
							
							// Copy flames
							int numFlames = 24;
							int numControlCubes = 9;
							int worldFlameOffset = (numLights*3*3)+numControlCubes; // won't change
							int dataOffset = (numLights*3)+numControlCubes; // won't change
							for (int i = 0; i < numFlames; i++) {
								world2[i+worldFlameOffset] = data[i+dataOffset];
							}
							
							frame_count++;
						}
					}
					
					else if( command == 9 ) {
						int first = data[0];
						uint8_t *bits = data+1;
						uint8_t *regs = data+6;
						int changed = 0;
						for( int bit=0; bit<=39; bit++ )
						{
							uint8_t ch = bits[bit/8];
							if( ch >> (bit%8) & 0x1 )
								world[first * 8 + bit] = regs[changed];
							
							changed ++;
						}
						
						frame_count++;
					}
					
					else {
						printf("dmx: %i", command);
					}
					
					// cleanup
					free(data);
				}
				//pthread_mutex_unlock(&_mutex);
			}
			
			
			float t = (clock() - last) / (float)CLOCKS_PER_SEC;
			printf("t: %f\n", t);
			last = clock();
			
			// frame rate testing
			clock_t delta = clock() - start;
			if( delta >= CLOCKS_PER_SEC )
			{
				float elapsed = delta/(float)CLOCKS_PER_SEC;
				printf("elapsed: %f dmx fps: %f error rate: %f\n", elapsed, frame_count / elapsed, error_count / elapsed);
				frame_count = 0;
				error_count = 0;
				start = clock();
			}
			
			//pthread_testcancel();
		}
		/*
		if (listenSocket != 0) {
			listenSocket->close();
			deleteAndZero (listenSocket);
		}
		 */
/*	
}
	else
	{
		fprintf(stderr, "error opening: %s\n", _path);
	}
	*/
}

void DMX::Close()
{
	
	// close the device
	if( _dmxFd != -1 )
	{
		fprintf(stderr, "closing serial port");
		
		//close(_dmxFd);
		_dmxFd = -1;
	}
	
	// free the path
	if( _path )
	{
		delete[] _path;
		_path = NULL;
	}
}


void DMX::Start( const char *path )
{
	if( !isThreadRunning() && !_path && _dmxFd==-1 && path )
	{
		// copy device path
		_path = new char[strlen(path)];
		strcpy(_path, path);
		
		// create thread and run
		startThread();
		//int ret = pthread_create(&_thread, NULL, _dmx_read_thread, this);
		//if( ret != 0 )
		//	fprintf(stderr, "error creating read thread: %i", ret);
	}
	else {
		fprintf(stderr, "start: read thread already started.");
	}

}


void DMX::Stop()
{
	// kill the thread
	if( isThreadRunning() )
	{
		//pthread_cancel(_thread);
		stopThread (3000);
		
		//void *status = 0;
		//pthread_join(_thread, &status);
		Close();
	}
}


#pragma mark -

bool DMX::IsRunning()
{
	//return (_thread != NULL) && (_dmxFd != -1);
	return (isThreadRunning()) && (_dmxFd != -1);
}

void DMX::SetColorForLight( hsv_t hsv, int index )
{
	rgb_t rgb;
	HSVtoRGB(hsv, &rgb);
	int i = index * 3;
	world[i  ] = rgb.r;
	world[i+1] = rgb.g;
	world[i+2] = rgb.b;
}

// canned animation for running the visualizer without a DMX interface
float hue_phase = 0;
float step_phase = 0;
float adsr[108];
hsv_t cubes[108];
float bpm = 120.0;
void DMX::Animate( float tdelta )
{
	// syzygryd arm hue cycling
	hue_phase += tdelta/60.0;	// 10 seconds rotate
	if( hue_phase > 1.0 )
		hue_phase -= 1.0;
	
	// step sequencer phase
	int prev_step = step_phase * 36.0;
	step_phase += tdelta * (60.0/bpm);	// 80bpm
	if( step_phase > 1.0 )
		step_phase -= 1.0;
	int step = step_phase * 108.0;
	
	// retrigger adsr on step change
	if( prev_step != step )
	{
		adsr[step/3] = 1.0;
		adsr[step/3 + 18] = 1.0;
//		adsr[step/3 + 12] = 1.0;
		
		adsr[step/3 + 36] = 1.0;
		adsr[step/3 + 36 + 18] = 1.0;
//		adsr[step/3 + 36 + 6] = 1.0;
		
		adsr[step/3 + 72] = 1.0;
		adsr[step/3 + 72 + 18] = 1.0;
//		adsr[step/3 + 72 + 12] = 1.0;
	}
	
	// hue rotate
	for( int i=0; i<36; i++ )
	{
		// base hue
		hsv_t hsv1 = { hue_phase*HUE_MAX, 255, 255 };	// leg1
		hsv_t hsv2 = hsv1; hsv2.h += HUE_MAX/3;			// leg2
		hsv_t hsv3 = hsv1; hsv3.h += HUE_MAX/3 * 2;		// leg3
		
		cubes[i] = hsv1;
		cubes[i+36] = hsv2;
		cubes[i+72] = hsv3;
	}
	
	for( int n=0, i=0; n<108; i+=3, n++ )
	{
		hsv_t hsv = cubes[n]; //{ f/108.0 * HUE_MAX, 255, 255 };
		
		// adsr brightness adjust
		hsv.v *= adsr[n];
		
		rgb_t rgb;
		HSVtoRGB(hsv, &rgb);
		world[i  ] = rgb.r;
		world[i+1] = rgb.g;
		world[i+2] = rgb.b;
	}
	
	// adsr decay
	for( int i=0; i<108; i++ )
	{
		adsr[i] -= tdelta * 2.0;	// linear decay
		if( adsr[i] < 0.0 )
			adsr[i] = 0.0;	// pin at zero
	}
}
