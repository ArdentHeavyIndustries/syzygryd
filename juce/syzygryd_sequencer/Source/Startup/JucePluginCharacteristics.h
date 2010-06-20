/*
 *  JucePluginCharacteristics.h
 *  syzygryd_sequencer
 *
 *  Created by Matt Sonic on 5/2/10.
 *  Copyright 2010 SonicTransfer. All rights reserved.
 *
 */

#ifndef JUCE_PLUGIN_CHARACTERISTICS_H
#define JUCE_PLUGIN_CHARACTERISTICS_H

#define JucePlugin_Build_VST    1
#define JucePlugin_Build_AU     0
#define JucePlugin_Build_RTAS   0

#define JucePlugin_Name                 "syzygryd_sequencer"
#define JucePlugin_Desc                 "syzygryd_sequencer"
#define JucePlugin_Manufacturer         "SonicTransfer"
#define JucePlugin_ManufacturerCode     'stpt'
#define JucePlugin_PluginCode           'Stpt'
#define JucePlugin_MaxNumInputChannels  2
#define JucePlugin_MaxNumOutputChannels 2
#define JucePlugin_PreferredChannelConfigurations   {1, 1}, {2, 2}
#define JucePlugin_IsSynth              1
#define JucePlugin_WantsMidiInput       1
#define JucePlugin_ProducesMidiOutput   1
#define JucePlugin_SilenceInProducesSilenceOut  0
#define JucePlugin_TailLengthSeconds    0
#define JucePlugin_EditorRequiresKeyboardFocus  1
#define JucePlugin_VersionCode          0x10000
#define JucePlugin_VersionString        "1.0.0"
#define JucePlugin_VSTUniqueID          JucePlugin_PluginCode
#define JucePlugin_VSTCategory          kPlugCategSynth
#define JucePlugin_AUMainType           kAudioUnitType_MusicDevice
#define JucePlugin_AUSubType            JucePlugin_PluginCode
#define JucePlugin_AUExportPrefix       JuceProjectAU
#define JucePlugin_AUExportPrefixQuoted "JuceProjectAU"
#define JucePlugin_AUManufacturerCode   JucePlugin_ManufacturerCode
#define JucePlugin_CFBundleIdentifier   com.SonicTransfer.PluginTemplate1
#define JucePlugin_AUCocoaViewClassName JuceProjectAU_V1
#define JucePlugin_RTASCategory         ePlugInCategory_SWGenerators
#define JucePlugin_RTASManufacturerCode JucePlugin_ManufacturerCode
#define JucePlugin_RTASProductId        JucePlugin_PluginCode
#define JUCE_USE_VSTSDK_2_4             1
#ifndef JUCE_ObjCExtraSuffix
	#define JUCE_ObjCExtraSuffix            "sttp"
#endif

#endif   
