{
	"patcher" : 	{
		"fileversion" : 1,
		"rect" : [ 23.0, 71.0, 1133.0, 556.0 ],
		"bglocked" : 0,
		"defrect" : [ 23.0, 71.0, 1133.0, 556.0 ],
		"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
		"openinpresentation" : 1,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 0,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"boxes" : [ 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "size 128 128",
					"patching_rect" : [ 594.0, 63.0, 79.0, 18.0 ],
					"id" : "obj-3",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "standalone",
					"patching_rect" : [ 209.0, 55.0, 69.0, 20.0 ],
					"id" : "obj-1",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 1,
					"saved_object_attributes" : 					{
						"preffilename" : "Max 5 Preferences",
						"cantclosetoplevelpatchers" : 1,
						"statusvisible" : 1,
						"allwindowsactive" : 0,
						"usesearchpath" : 0,
						"audiosupport" : 0,
						"midisupport" : 1,
						"noloadbangdefeating" : 0,
						"searchformissingfiles" : 1,
						"overdrive" : 0
					}

				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Sending to Local host by default but use this to reset",
					"linecount" : 3,
					"presentation_linecount" : 2,
					"patching_rect" : [ 806.0, 284.0, 150.0, 48.0 ],
					"presentation" : 1,
					"id" : "obj-284",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 812.0, 175.0, 164.0, 34.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "enter IP to send too then click >",
					"patching_rect" : [ 1038.0, 457.0, 179.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-280",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 775.0, 68.0, 179.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "button",
					"patching_rect" : [ 997.0, 475.0, 20.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-278",
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"presentation_rect" : [ 959.0, 69.0, 20.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "toggle debug print",
					"patching_rect" : [ 776.0, 511.0, 106.0, 20.0 ],
					"id" : "obj-276",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "host 90.78.0.33",
					"patching_rect" : [ 930.0, 509.0, 120.0, 18.0 ],
					"id" : "obj-274",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "sprintf host %ld.%ld.%ld.%ld",
					"patching_rect" : [ 1053.0, 508.0, 163.0, 20.0 ],
					"id" : "obj-272",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 4
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 1196.0, 483.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-271",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"minimum" : 0,
					"presentation_rect" : [ 957.0, 98.0, 50.0, 20.0 ],
					"maximum" : 255,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 1147.0, 482.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-270",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"minimum" : 0,
					"presentation_rect" : [ 908.0, 97.0, 50.0, 20.0 ],
					"maximum" : 255,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 1096.0, 482.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-269",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"minimum" : 0,
					"presentation_rect" : [ 857.0, 96.0, 50.0, 20.0 ],
					"maximum" : 255,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 1046.0, 481.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-266",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"minimum" : 0,
					"presentation_rect" : [ 807.0, 96.0, 50.0, 20.0 ],
					"maximum" : 255,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "host localhost",
					"patching_rect" : [ 918.0, 531.0, 84.0, 18.0 ],
					"presentation" : 1,
					"id" : "obj-258",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 846.0, 214.0, 84.0, 18.0 ],
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "loadbang",
					"patching_rect" : [ 573.0, 7.0, 60.0, 20.0 ],
					"id" : "obj-250",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "recordsprite, pensize 1 1, frameoval -4 -4 4 4 0 0 0, closesprite circle",
					"patching_rect" : [ 573.0, 30.0, 376.0, 18.0 ],
					"id" : "obj-249",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "lcd",
					"patching_rect" : [ 586.0, 257.0, 128.0, 128.0 ],
					"idle" : 1,
					"presentation" : 1,
					"id" : "obj-236",
					"numoutlets" : 4,
					"outlettype" : [ "list", "list", "int", "" ],
					"enablesprites" : 1,
					"presentation_rect" : [ 309.0, 216.0, 128.0, 128.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "prepend drawsprite circle",
					"patching_rect" : [ 587.0, 393.0, 145.0, 20.0 ],
					"id" : "obj-237",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "button",
					"patching_rect" : [ 645.0, 414.0, 20.0, 20.0 ],
					"id" : "obj-238",
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "clear",
					"patching_rect" : [ 686.0, 430.0, 37.0, 18.0 ],
					"id" : "obj-239",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 127 127 0",
					"patching_rect" : [ 658.0, 465.0, 105.0, 20.0 ],
					"id" : "obj-240",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 6
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "y pos",
					"patching_rect" : [ 640.0, 496.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-242",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 121.0, 360.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "x pos",
					"patching_rect" : [ 578.0, 492.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-243",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 343.0, 356.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 625.0, 518.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-244",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 388.0, 383.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 560.0, 515.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-245",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 329.0, 382.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack 0 0",
					"patching_rect" : [ 575.0, 441.0, 77.0, 20.0 ],
					"id" : "obj-246",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "lcd",
					"patching_rect" : [ 215.0, 270.0, 128.0, 128.0 ],
					"idle" : 1,
					"presentation" : 1,
					"id" : "obj-225",
					"numoutlets" : 4,
					"outlettype" : [ "list", "list", "int", "" ],
					"enablesprites" : 1,
					"presentation_rect" : [ 35.0, 226.0, 128.0, 128.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "prepend drawsprite circle",
					"patching_rect" : [ 217.0, 404.0, 145.0, 20.0 ],
					"id" : "obj-226",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "button",
					"patching_rect" : [ 275.0, 425.0, 20.0, 20.0 ],
					"id" : "obj-227",
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "clear",
					"patching_rect" : [ 316.0, 441.0, 37.0, 18.0 ],
					"id" : "obj-228",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 127 127 0",
					"patching_rect" : [ 288.0, 476.0, 105.0, 20.0 ],
					"id" : "obj-229",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 6
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "y pos",
					"patching_rect" : [ 304.0, 502.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-231",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 390.0, 357.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "x pos",
					"patching_rect" : [ 208.0, 503.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-232",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 621.0, 355.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 289.0, 524.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-233",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 114.0, 384.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 190.0, 526.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-234",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 51.0, 385.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack 0 0",
					"patching_rect" : [ 209.0, 452.0, 77.0, 20.0 ],
					"id" : "obj-235",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "lcd",
					"patching_rect" : [ 994.0, 58.0, 128.0, 128.0 ],
					"idle" : 1,
					"presentation" : 1,
					"id" : "obj-220",
					"numoutlets" : 4,
					"outlettype" : [ "list", "list", "int", "" ],
					"enablesprites" : 1,
					"presentation_rect" : [ 612.0, 220.0, 128.0, 128.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "prepend drawsprite circle",
					"patching_rect" : [ 1003.0, 198.0, 145.0, 20.0 ],
					"id" : "obj-219",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "button",
					"patching_rect" : [ 1061.0, 219.0, 20.0, 20.0 ],
					"id" : "obj-192",
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "clear",
					"patching_rect" : [ 1102.0, 235.0, 37.0, 18.0 ],
					"id" : "obj-190",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 127 127 0",
					"patching_rect" : [ 1074.0, 271.0, 105.0, 20.0 ],
					"id" : "obj-161",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 6
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "y pos",
					"patching_rect" : [ 1090.0, 296.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-163",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 677.0, 356.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "x pos",
					"patching_rect" : [ 994.0, 297.0, 38.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-164",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 59.0, 362.0, 38.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 1075.0, 318.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-165",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 674.0, 384.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"patching_rect" : [ 976.0, 320.0, 50.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-166",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"fontsize" : 12.0,
					"presentation_rect" : [ 615.0, 384.0, 50.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack 0 0",
					"patching_rect" : [ 995.0, 246.0, 77.0, 20.0 ],
					"id" : "obj-167",
					"fontname" : "Arial",
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ],
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "8",
					"patching_rect" : [ 884.0, 76.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-121",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 726.0, 41.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "7",
					"patching_rect" : [ 866.0, 77.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-122",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 708.0, 42.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "6",
					"patching_rect" : [ 846.0, 76.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-123",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 688.0, 41.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "5",
					"patching_rect" : [ 827.0, 77.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-124",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 669.0, 42.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "4",
					"patching_rect" : [ 809.0, 77.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-125",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 651.0, 42.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "3",
					"patching_rect" : [ 790.0, 76.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-126",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 632.0, 41.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "2",
					"patching_rect" : [ 770.0, 77.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-127",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 612.0, 42.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "1",
					"patching_rect" : [ 749.0, 78.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-128",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 591.0, 43.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Controller #3",
					"patching_rect" : [ 787.0, 53.0, 84.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-129",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 631.0, 19.0, 84.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "8",
					"patching_rect" : [ 510.0, 51.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-112",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 437.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "7",
					"patching_rect" : [ 492.0, 52.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-113",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 419.0, 37.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "6",
					"patching_rect" : [ 472.0, 51.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-114",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 399.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "5",
					"patching_rect" : [ 453.0, 52.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-115",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 380.0, 37.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "4",
					"patching_rect" : [ 435.0, 52.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-116",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 362.0, 37.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "3",
					"patching_rect" : [ 416.0, 51.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-117",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 343.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "2",
					"patching_rect" : [ 396.0, 49.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-118",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 324.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "1",
					"patching_rect" : [ 377.0, 49.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-119",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 304.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Controller #2",
					"patching_rect" : [ 413.0, 28.0, 84.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-120",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 344.0, 14.0, 84.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "8",
					"patching_rect" : [ 158.0, 35.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-110",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 155.0, 35.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "7",
					"patching_rect" : [ 140.0, 36.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-109",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 137.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "6",
					"patching_rect" : [ 120.0, 35.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-108",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 117.0, 35.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "5",
					"patching_rect" : [ 101.0, 36.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-107",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 98.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "4",
					"patching_rect" : [ 83.0, 36.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-106",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 80.0, 36.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "3",
					"patching_rect" : [ 64.0, 35.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-105",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 61.0, 35.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "2",
					"patching_rect" : [ 44.0, 33.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-104",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 41.0, 33.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "1",
					"patching_rect" : [ 25.0, 33.0, 22.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-101",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 22.0, 33.0, 22.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Controller #1",
					"patching_rect" : [ 55.0, 16.0, 80.0, 20.0 ],
					"presentation" : 1,
					"id" : "obj-99",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"presentation_rect" : [ 52.0, 16.0, 80.0, 20.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "toggle",
					"patching_rect" : [ 816.0, 533.0, 20.0, 20.0 ],
					"id" : "obj-97",
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "gate",
					"patching_rect" : [ 816.0, 559.0, 34.0, 20.0 ],
					"id" : "obj-95",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 750.0, 103.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-94",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 722.0, 67.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 769.0, 102.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-93",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 703.0, 67.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 788.0, 101.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-92",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 684.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 807.0, 100.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-91",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 665.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 826.0, 100.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-90",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 647.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 845.0, 101.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-89",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 629.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 864.0, 101.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-88",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 610.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 883.0, 102.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-87",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 592.0, 68.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 375.0, 69.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-86",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 431.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 395.0, 70.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-85",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 413.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 413.0, 70.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-84",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 394.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 431.0, 70.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-83",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 376.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 451.0, 71.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-82",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 357.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 469.0, 71.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-81",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 339.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 486.0, 70.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-80",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 321.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 505.0, 70.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-78",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 303.0, 63.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 25.0, 54.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-77",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 155.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 44.0, 54.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-76",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 135.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 63.0, 55.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-75",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 115.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 82.0, 55.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-74",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 95.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 101.0, 56.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-73",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 76.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 120.0, 56.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-72",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 56.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 140.0, 56.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-71",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 37.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"patching_rect" : [ 157.0, 56.0, 20.0, 140.0 ],
					"presentation" : 1,
					"id" : "obj-70",
					"numoutlets" : 1,
					"size" : 1.0,
					"outlettype" : [ "" ],
					"floatoutput" : 1,
					"presentation_rect" : [ 18.0, 60.0, 20.0, 140.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "print",
					"patching_rect" : [ 816.0, 584.0, 34.0, 20.0 ],
					"id" : "obj-69",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "r OSC_out",
					"patching_rect" : [ 848.0, 529.0, 67.0, 20.0 ],
					"id" : "obj-68",
					"fontname" : "Arial",
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"fontsize" : 12.0,
					"numinlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 10",
					"patching_rect" : [ 1126.0, 320.0, 99.0, 20.0 ],
					"id" : "obj-58",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 9",
					"patching_rect" : [ 963.0, 346.0, 92.0, 20.0 ],
					"id" : "obj-59",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 8",
					"patching_rect" : [ 749.0, 380.0, 92.0, 20.0 ],
					"id" : "obj-60",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 7",
					"patching_rect" : [ 769.0, 363.0, 92.0, 20.0 ],
					"id" : "obj-61",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 6",
					"patching_rect" : [ 786.0, 347.0, 92.0, 20.0 ],
					"id" : "obj-62",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 5",
					"patching_rect" : [ 807.0, 328.0, 92.0, 20.0 ],
					"id" : "obj-63",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 4",
					"patching_rect" : [ 826.0, 314.0, 92.0, 20.0 ],
					"id" : "obj-64",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 3",
					"patching_rect" : [ 846.0, 298.0, 92.0, 20.0 ],
					"id" : "obj-65",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 2",
					"patching_rect" : [ 864.0, 284.0, 92.0, 20.0 ],
					"id" : "obj-66",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 3 1",
					"patching_rect" : [ 883.0, 265.0, 92.0, 20.0 ],
					"id" : "obj-67",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 10",
					"patching_rect" : [ 680.0, 521.0, 99.0, 20.0 ],
					"id" : "obj-48",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 9",
					"patching_rect" : [ 468.0, 495.0, 92.0, 20.0 ],
					"id" : "obj-49",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 8",
					"patching_rect" : [ 377.0, 354.0, 92.0, 20.0 ],
					"id" : "obj-50",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 7",
					"patching_rect" : [ 397.0, 336.0, 92.0, 20.0 ],
					"id" : "obj-51",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 6",
					"patching_rect" : [ 415.0, 316.0, 92.0, 20.0 ],
					"id" : "obj-52",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 5",
					"patching_rect" : [ 433.0, 297.0, 92.0, 20.0 ],
					"id" : "obj-53",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 4",
					"patching_rect" : [ 453.0, 278.0, 92.0, 20.0 ],
					"id" : "obj-54",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 3",
					"patching_rect" : [ 470.0, 258.0, 92.0, 20.0 ],
					"id" : "obj-55",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 2",
					"patching_rect" : [ 487.0, 238.0, 92.0, 20.0 ],
					"id" : "obj-56",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 2 1",
					"patching_rect" : [ 504.0, 219.0, 92.0, 20.0 ],
					"id" : "obj-57",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 10",
					"patching_rect" : [ 359.0, 541.0, 99.0, 20.0 ],
					"id" : "obj-47",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 9",
					"patching_rect" : [ 89.0, 509.0, 92.0, 20.0 ],
					"id" : "obj-46",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 8",
					"patching_rect" : [ 33.0, 330.0, 92.0, 20.0 ],
					"id" : "obj-45",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 7",
					"patching_rect" : [ 52.0, 312.0, 92.0, 20.0 ],
					"id" : "obj-44",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 6",
					"patching_rect" : [ 70.0, 292.0, 92.0, 20.0 ],
					"id" : "obj-43",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 5",
					"patching_rect" : [ 86.0, 272.0, 92.0, 20.0 ],
					"id" : "obj-42",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 4",
					"patching_rect" : [ 105.0, 254.0, 92.0, 20.0 ],
					"id" : "obj-41",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 3",
					"patching_rect" : [ 124.0, 235.0, 92.0, 20.0 ],
					"id" : "obj-40",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 2",
					"patching_rect" : [ 142.0, 217.0, 92.0, 20.0 ],
					"id" : "obj-39",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "OSC_slider 1 1",
					"patching_rect" : [ 158.0, 199.0, 92.0, 20.0 ],
					"id" : "obj-35",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "udpsend 127.0.0.1 8000",
					"patching_rect" : [ 938.0, 561.0, 140.0, 20.0 ],
					"id" : "obj-9",
					"fontname" : "Arial",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"numinlets" : 1
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"source" : [ "obj-250", 0 ],
					"destination" : [ "obj-3", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-161", 0 ],
					"destination" : [ "obj-58", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-167", 0 ],
					"destination" : [ "obj-166", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-161", 0 ],
					"destination" : [ "obj-165", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-167", 1 ],
					"destination" : [ "obj-161", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-167", 0 ],
					"destination" : [ "obj-59", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-240", 0 ],
					"destination" : [ "obj-48", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-246", 0 ],
					"destination" : [ "obj-49", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-229", 0 ],
					"destination" : [ "obj-47", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-235", 0 ],
					"destination" : [ "obj-46", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-70", 0 ],
					"destination" : [ "obj-35", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-71", 0 ],
					"destination" : [ "obj-39", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-72", 0 ],
					"destination" : [ "obj-40", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-73", 0 ],
					"destination" : [ "obj-41", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-74", 0 ],
					"destination" : [ "obj-42", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-75", 0 ],
					"destination" : [ "obj-43", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-76", 0 ],
					"destination" : [ "obj-44", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-77", 0 ],
					"destination" : [ "obj-45", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-78", 0 ],
					"destination" : [ "obj-57", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-80", 0 ],
					"destination" : [ "obj-56", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-81", 0 ],
					"destination" : [ "obj-55", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-82", 0 ],
					"destination" : [ "obj-54", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-83", 0 ],
					"destination" : [ "obj-53", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-84", 0 ],
					"destination" : [ "obj-52", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-85", 0 ],
					"destination" : [ "obj-51", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-86", 0 ],
					"destination" : [ "obj-50", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-87", 0 ],
					"destination" : [ "obj-67", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-88", 0 ],
					"destination" : [ "obj-66", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-89", 0 ],
					"destination" : [ "obj-65", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-90", 0 ],
					"destination" : [ "obj-64", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-91", 0 ],
					"destination" : [ "obj-63", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-92", 0 ],
					"destination" : [ "obj-62", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-93", 0 ],
					"destination" : [ "obj-61", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-94", 0 ],
					"destination" : [ "obj-60", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-246", 1 ],
					"destination" : [ "obj-240", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-240", 0 ],
					"destination" : [ "obj-244", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-246", 0 ],
					"destination" : [ "obj-245", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-229", 0 ],
					"destination" : [ "obj-233", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-235", 1 ],
					"destination" : [ "obj-229", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-235", 0 ],
					"destination" : [ "obj-234", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-3", 0 ],
					"destination" : [ "obj-220", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-3", 0 ],
					"destination" : [ "obj-236", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-3", 0 ],
					"destination" : [ "obj-225", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-68", 0 ],
					"destination" : [ "obj-9", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-68", 0 ],
					"destination" : [ "obj-95", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-95", 0 ],
					"destination" : [ "obj-69", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-97", 0 ],
					"destination" : [ "obj-95", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-192", 0 ],
					"destination" : [ "obj-190", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-220", 0 ],
					"destination" : [ "obj-167", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-219", 0 ],
					"destination" : [ "obj-220", 0 ],
					"hidden" : 0,
					"midpoints" : [ 1012.5, 227.0, 986.5, 227.0, 986.5, 54.0, 1003.5, 54.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-190", 0 ],
					"destination" : [ "obj-220", 0 ],
					"hidden" : 0,
					"midpoints" : [ 1111.5, 262.0, 1159.0, 262.0, 1159.0, 54.0, 1003.5, 54.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-220", 0 ],
					"destination" : [ "obj-219", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-220", 0 ],
					"destination" : [ "obj-192", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-225", 0 ],
					"destination" : [ "obj-227", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-225", 0 ],
					"destination" : [ "obj-226", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-228", 0 ],
					"destination" : [ "obj-225", 0 ],
					"hidden" : 0,
					"midpoints" : [ 325.5, 468.0, 373.0, 468.0, 373.0, 260.0, 224.5, 260.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-226", 0 ],
					"destination" : [ "obj-225", 0 ],
					"hidden" : 0,
					"midpoints" : [ 226.5, 433.0, 200.5, 433.0, 200.5, 260.0, 224.5, 260.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-225", 0 ],
					"destination" : [ "obj-235", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-227", 0 ],
					"destination" : [ "obj-228", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-236", 0 ],
					"destination" : [ "obj-238", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-236", 0 ],
					"destination" : [ "obj-237", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-239", 0 ],
					"destination" : [ "obj-236", 0 ],
					"hidden" : 0,
					"midpoints" : [ 695.5, 457.0, 743.0, 457.0, 743.0, 249.0, 595.5, 249.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-237", 0 ],
					"destination" : [ "obj-236", 0 ],
					"hidden" : 0,
					"midpoints" : [ 596.5, 422.0, 570.5, 422.0, 570.5, 249.0, 595.5, 249.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-238", 0 ],
					"destination" : [ "obj-239", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-250", 0 ],
					"destination" : [ "obj-249", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-249", 0 ],
					"destination" : [ "obj-236", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-249", 0 ],
					"destination" : [ "obj-220", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-249", 0 ],
					"destination" : [ "obj-225", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-236", 0 ],
					"destination" : [ "obj-246", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-258", 0 ],
					"destination" : [ "obj-9", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-278", 0 ],
					"destination" : [ "obj-274", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-274", 0 ],
					"destination" : [ "obj-9", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-274", 0 ],
					"destination" : [ "obj-258", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-278", 0 ],
					"destination" : [ "obj-272", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-272", 0 ],
					"destination" : [ "obj-274", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-271", 0 ],
					"destination" : [ "obj-272", 3 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-270", 0 ],
					"destination" : [ "obj-272", 2 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-269", 0 ],
					"destination" : [ "obj-272", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-266", 0 ],
					"destination" : [ "obj-272", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
 ]
	}

}
