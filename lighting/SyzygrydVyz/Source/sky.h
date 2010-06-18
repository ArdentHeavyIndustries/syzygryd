/*
 *  Created by Michael Estee on 4/5/10.
 *  Copyright 2010 Mike Estee. All rights reserved.
 */

struct Sky
{
	float timer, flash;
	float duration, delay;
	int flashes;

	GLuint light;
	float* top_color, *bot_color;

	Sky( float* tc, float* bc );
	~Sky();

	void Draw();
	void Animate( float tdelta );
};