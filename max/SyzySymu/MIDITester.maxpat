{
	"patcher" : 	{
		"fileversion" : 1,
		"rect" : [ 49.0, 44.0, 417.0, 290.0 ],
		"bglocked" : 0,
		"defrect" : [ 49.0, 44.0, 417.0, 290.0 ],
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
					"text" : "53",
					"id" : "obj-58",
					"fontname" : "Arial",
					"patching_rect" : [ 705.0, 495.0, 32.5, 18.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "52",
					"id" : "obj-56",
					"fontname" : "Arial",
					"patching_rect" : [ 570.0, 495.0, 32.5, 18.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "pack",
					"id" : "obj-53",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 525.0, 36.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "s OutToMIDI",
					"id" : "obj-54",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 555.0, 77.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "pack",
					"id" : "obj-52",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 525.0, 36.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "s OutToMIDI",
					"id" : "obj-51",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 555.0, 77.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 128 1 127",
					"id" : "obj-50",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 450.0, 105.0, 20.0 ],
					"numinlets" : 6,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 128 1 127",
					"id" : "obj-49",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 450.0, 105.0, 20.0 ],
					"numinlets" : 6,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0 128 1 127",
					"id" : "obj-44",
					"fontname" : "Arial",
					"patching_rect" : [ 765.0, 360.0, 105.0, 20.0 ],
					"numinlets" : 6,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"id" : "obj-41",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 420.0, 50.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "maximum 0",
					"id" : "obj-42",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 390.0, 73.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "minimum 128",
					"id" : "obj-43",
					"fontname" : "Arial",
					"patching_rect" : [ 675.0, 360.0, 83.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"id" : "obj-40",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 420.0, 50.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack",
					"id" : "obj-36",
					"fontname" : "Arial",
					"patching_rect" : [ 615.0, 315.0, 49.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "maximum 0",
					"id" : "obj-25",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 390.0, 73.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "minimum 128",
					"id" : "obj-24",
					"fontname" : "Arial",
					"patching_rect" : [ 540.0, 360.0, 83.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "loadbang",
					"id" : "obj-250",
					"fontname" : "Arial",
					"patching_rect" : [ 668.0, 25.0, 60.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "recordsprite, pensize 1 1, frameoval -4 -4 4 4 0 0 0, closesprite circle",
					"id" : "obj-249",
					"fontname" : "Arial",
					"patching_rect" : [ 668.0, 48.0, 376.0, 18.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "lcd",
					"id" : "obj-7",
					"patching_rect" : [ 661.0, 136.0, 128.0, 128.0 ],
					"presentation" : 1,
					"enablesprites" : 1,
					"numinlets" : 1,
					"idle" : 1,
					"numoutlets" : 4,
					"outlettype" : [ "list", "list", "int", "" ],
					"presentation_rect" : [ 255.0, 105.0, 128.0, 128.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "prepend drawsprite circle",
					"id" : "obj-226",
					"fontname" : "Arial",
					"patching_rect" : [ 653.0, 273.0, 145.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "button",
					"id" : "obj-227",
					"patching_rect" : [ 711.0, 294.0, 20.0, 20.0 ],
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "clear",
					"id" : "obj-228",
					"fontname" : "Arial",
					"patching_rect" : [ 752.0, 310.0, 37.0, 18.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"id" : "obj-19",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 345.0, 480.0, 53.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"presentation_rect" : [ 348.0, 256.0, 53.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "y:",
					"id" : "obj-21",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 330.0, 480.0, 19.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 330.0, 255.0, 19.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"id" : "obj-9",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 270.0, 480.0, 53.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"presentation_rect" : [ 273.0, 256.0, 53.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "x:",
					"id" : "obj-6",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 255.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 255.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "p sliderMatrix",
					"id" : "obj-4",
					"fontname" : "Arial",
					"patching_rect" : [ 15.0, 570.0, 113.5, 20.0 ],
					"numinlets" : 8,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"patcher" : 					{
						"fileversion" : 1,
						"rect" : [ 215.0, 44.0, 520.0, 276.0 ],
						"bglocked" : 0,
						"defrect" : [ 215.0, 44.0, 520.0, 276.0 ],
						"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
						"openinpresentation" : 0,
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
						"boxes" : [ 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-73",
									"fontname" : "Arial",
									"patching_rect" : [ 435.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-72",
									"fontname" : "Arial",
									"patching_rect" : [ 375.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-71",
									"fontname" : "Arial",
									"patching_rect" : [ 315.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-70",
									"fontname" : "Arial",
									"patching_rect" : [ 255.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-69",
									"fontname" : "Arial",
									"patching_rect" : [ 195.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-68",
									"fontname" : "Arial",
									"patching_rect" : [ 135.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-67",
									"fontname" : "Arial",
									"patching_rect" : [ 75.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "pack",
									"id" : "obj-66",
									"fontname" : "Arial",
									"patching_rect" : [ 15.0, 135.0, 36.0, 20.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "newobj",
									"text" : "s OutToMIDI",
									"id" : "obj-65",
									"fontname" : "Arial",
									"patching_rect" : [ 15.0, 225.0, 77.0, 20.0 ],
									"numinlets" : 1,
									"fontsize" : 12.0,
									"numoutlets" : 0
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "51",
									"id" : "obj-56",
									"fontname" : "Arial",
									"patching_rect" : [ 450.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "50",
									"id" : "obj-54",
									"fontname" : "Arial",
									"patching_rect" : [ 390.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "49",
									"id" : "obj-52",
									"fontname" : "Arial",
									"patching_rect" : [ 330.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "48",
									"id" : "obj-50",
									"fontname" : "Arial",
									"patching_rect" : [ 270.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "47",
									"id" : "obj-48",
									"fontname" : "Arial",
									"patching_rect" : [ 210.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "46",
									"id" : "obj-46",
									"fontname" : "Arial",
									"patching_rect" : [ 150.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "45",
									"id" : "obj-44",
									"fontname" : "Arial",
									"patching_rect" : [ 90.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "message",
									"text" : "44",
									"id" : "obj-42",
									"fontname" : "Arial",
									"patching_rect" : [ 30.0, 75.0, 32.5, 18.0 ],
									"numinlets" : 2,
									"fontsize" : 12.0,
									"numoutlets" : 1,
									"outlettype" : [ "" ]
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-7",
									"patching_rect" : [ 435.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-8",
									"patching_rect" : [ 375.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-9",
									"patching_rect" : [ 315.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-10",
									"patching_rect" : [ 255.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-5",
									"patching_rect" : [ 195.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-6",
									"patching_rect" : [ 135.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-4",
									"patching_rect" : [ 75.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
, 							{
								"box" : 								{
									"maxclass" : "inlet",
									"id" : "obj-3",
									"patching_rect" : [ 15.0, 15.0, 25.0, 25.0 ],
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"comment" : ""
								}

							}
 ],
						"lines" : [ 							{
								"patchline" : 								{
									"source" : [ "obj-73", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-72", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-71", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-70", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-69", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-68", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-67", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-66", 0 ],
									"destination" : [ "obj-65", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-56", 0 ],
									"destination" : [ "obj-73", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-7", 0 ],
									"destination" : [ "obj-73", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-54", 0 ],
									"destination" : [ "obj-72", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-8", 0 ],
									"destination" : [ "obj-72", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-52", 0 ],
									"destination" : [ "obj-71", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-9", 0 ],
									"destination" : [ "obj-71", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-50", 0 ],
									"destination" : [ "obj-70", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-10", 0 ],
									"destination" : [ "obj-70", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-48", 0 ],
									"destination" : [ "obj-69", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-5", 0 ],
									"destination" : [ "obj-69", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-46", 0 ],
									"destination" : [ "obj-68", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-6", 0 ],
									"destination" : [ "obj-68", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-44", 0 ],
									"destination" : [ "obj-67", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-4", 0 ],
									"destination" : [ "obj-67", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-42", 0 ],
									"destination" : [ "obj-66", 1 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-3", 0 ],
									"destination" : [ "obj-66", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-7", 0 ],
									"destination" : [ "obj-56", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-8", 0 ],
									"destination" : [ "obj-54", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-9", 0 ],
									"destination" : [ "obj-52", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-10", 0 ],
									"destination" : [ "obj-50", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-5", 0 ],
									"destination" : [ "obj-48", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-6", 0 ],
									"destination" : [ "obj-46", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-4", 0 ],
									"destination" : [ "obj-44", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
, 							{
								"patchline" : 								{
									"source" : [ "obj-3", 0 ],
									"destination" : [ "obj-42", 0 ],
									"hidden" : 0,
									"midpoints" : [  ]
								}

							}
 ]
					}
,
					"saved_object_attributes" : 					{
						"fontname" : "Arial",
						"globalpatchername" : "",
						"default_fontface" : 0,
						"fontface" : 0,
						"fontsize" : 12.0,
						"default_fontname" : "Arial",
						"default_fontsize" : 12.0
					}

				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack",
					"id" : "obj-48",
					"fontname" : "Arial",
					"patching_rect" : [ 120.0, 165.0, 49.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "int" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "r OutToMIDI",
					"id" : "obj-47",
					"fontname" : "Arial",
					"patching_rect" : [ 105.0, 135.0, 75.0, 20.0 ],
					"numinlets" : 0,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "ctlout",
					"id" : "obj-46",
					"fontname" : "Arial",
					"patching_rect" : [ 90.0, 195.0, 78.0, 20.0 ],
					"numinlets" : 3,
					"fontsize" : 12.0,
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "prepend port",
					"id" : "obj-45",
					"fontname" : "Arial",
					"patching_rect" : [ 90.0, 120.0, 79.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "8",
					"id" : "obj-32",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 225.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 225.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "7",
					"id" : "obj-33",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 195.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 195.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "6",
					"id" : "obj-34",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 165.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 165.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "5",
					"id" : "obj-35",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 135.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 135.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "4",
					"id" : "obj-30",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 105.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 105.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "3",
					"id" : "obj-29",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 75.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 75.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "2",
					"id" : "obj-28",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 45.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 45.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "1",
					"id" : "obj-27",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 15.0, 480.0, 20.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 15.0, 255.0, 20.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Select Controller",
					"id" : "obj-20",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 15.0, 225.0, 163.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 15.0, 56.0, 163.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "umenu",
					"types" : [  ],
					"id" : "obj-18",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 15.0, 240.0, 168.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"items" : [ 1, ",", 2, ",", 3, ",", 4 ],
					"outlettype" : [ "int", "", "" ],
					"presentation_rect" : [ 15.0, 75.0, 168.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-14",
					"patching_rect" : [ 225.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 225.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-15",
					"patching_rect" : [ 195.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 195.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-16",
					"patching_rect" : [ 165.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 165.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-17",
					"patching_rect" : [ 135.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 135.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-13",
					"patching_rect" : [ 105.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 105.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-12",
					"patching_rect" : [ 75.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 75.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-11",
					"patching_rect" : [ 45.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 45.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "slider",
					"id" : "obj-10",
					"patching_rect" : [ 15.0, 330.0, 20.0, 140.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"presentation_rect" : [ 15.0, 105.0, 20.0, 140.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Select MIDI Output",
					"id" : "obj-8",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 15.0, 75.0, 160.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"presentation_rect" : [ 15.0, 11.0, 160.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "umenu",
					"types" : [  ],
					"id" : "obj-3",
					"fontname" : "Lucida Grande",
					"patching_rect" : [ 15.0, 90.0, 167.0, 21.0 ],
					"presentation" : 1,
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"items" : [ "AU DLS Synth 1", ",", "IAC Driver GridSequencer", ",", "from MaxMSP 1", ",", "from MaxMSP 2" ],
					"outlettype" : [ "int", "", "" ],
					"presentation_rect" : [ 15.0, 30.0, 167.0, 21.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "loadmess",
					"id" : "obj-2",
					"fontname" : "Arial",
					"patching_rect" : [ 15.0, 15.0, 62.0, 20.0 ],
					"numinlets" : 1,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"hidden" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "midiinfo",
					"id" : "obj-1",
					"fontname" : "Arial",
					"patching_rect" : [ 15.0, 45.0, 52.0, 20.0 ],
					"numinlets" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"hidden" : 1
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"source" : [ "obj-14", 0 ],
					"destination" : [ "obj-4", 7 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-15", 0 ],
					"destination" : [ "obj-4", 6 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-16", 0 ],
					"destination" : [ "obj-4", 5 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-17", 0 ],
					"destination" : [ "obj-4", 4 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-13", 0 ],
					"destination" : [ "obj-4", 3 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-12", 0 ],
					"destination" : [ "obj-4", 2 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-11", 0 ],
					"destination" : [ "obj-4", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-10", 0 ],
					"destination" : [ "obj-4", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-1", 0 ],
					"destination" : [ "obj-3", 0 ],
					"hidden" : 1,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-2", 0 ],
					"destination" : [ "obj-1", 0 ],
					"hidden" : 1,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-3", 1 ],
					"destination" : [ "obj-45", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-45", 0 ],
					"destination" : [ "obj-46", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-18", 1 ],
					"destination" : [ "obj-46", 2 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-48", 1 ],
					"destination" : [ "obj-46", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-48", 0 ],
					"destination" : [ "obj-46", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-47", 0 ],
					"destination" : [ "obj-48", 0 ],
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
					"source" : [ "obj-226", 0 ],
					"destination" : [ "obj-7", 0 ],
					"hidden" : 0,
					"midpoints" : [ 662.5, 302.0, 636.5, 302.0, 636.5, 117.0, 670.5, 117.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-228", 0 ],
					"destination" : [ "obj-7", 0 ],
					"hidden" : 0,
					"midpoints" : [ 761.5, 337.0, 809.0, 337.0, 809.0, 103.0, 670.5, 103.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 0 ],
					"destination" : [ "obj-226", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 0 ],
					"destination" : [ "obj-227", 0 ],
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
					"destination" : [ "obj-7", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 0 ],
					"destination" : [ "obj-36", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-36", 0 ],
					"destination" : [ "obj-24", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-24", 0 ],
					"destination" : [ "obj-25", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-25", 0 ],
					"destination" : [ "obj-40", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-42", 0 ],
					"destination" : [ "obj-41", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-43", 0 ],
					"destination" : [ "obj-42", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-36", 1 ],
					"destination" : [ "obj-43", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-41", 0 ],
					"destination" : [ "obj-50", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-40", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-56", 0 ],
					"destination" : [ "obj-52", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-52", 0 ],
					"destination" : [ "obj-51", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-49", 0 ],
					"destination" : [ "obj-52", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-49", 0 ],
					"destination" : [ "obj-56", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-58", 0 ],
					"destination" : [ "obj-53", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-50", 0 ],
					"destination" : [ "obj-58", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-50", 0 ],
					"destination" : [ "obj-53", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-53", 0 ],
					"destination" : [ "obj-54", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-49", 0 ],
					"destination" : [ "obj-9", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-50", 0 ],
					"destination" : [ "obj-19", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
 ]
	}

}
