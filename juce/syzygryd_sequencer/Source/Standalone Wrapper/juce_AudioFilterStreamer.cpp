/*
  ==============================================================================

   This file is part of the JUCE library - "Jules' Utility Class Extensions"
   Copyright 2004-10 by Raw Material Software Ltd.

  ------------------------------------------------------------------------------

   JUCE can be redistributed and/or modified under the terms of the GNU General
   Public License (Version 2), as published by the Free Software Foundation.
   A copy of the license is included in the JUCE distribution, or can be found
   online at www.gnu.org/licenses.

   JUCE is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
   A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

  ------------------------------------------------------------------------------

   To release a closed-source product which uses JUCE, commercial licenses are
   available: visit www.rawmaterialsoftware.com/juce for more information.

  ==============================================================================
*/

#include "CustomPlayHead.h"
#include "PluginAudioProcessor.h"

#include "juce_AudioFilterStreamer.h"
#include "JucePluginCharacteristics.h"


//==============================================================================
AudioFilterStreamingDeviceManager::AudioFilterStreamingDeviceManager() :
customPlayHead (0)
{
    player = new AudioProcessorPlayer();

    addAudioCallback (player);
    addMidiInputCallback (String::empty, player);
}

AudioFilterStreamingDeviceManager::~AudioFilterStreamingDeviceManager()
{
    setFilter (0);
	
    removeMidiInputCallback (String::empty, player);
    removeAudioCallback (player);

	if (customPlayHead != 0) delete customPlayHead;
	
    clearSingletonInstance();
}

void AudioFilterStreamingDeviceManager::setFilter (AudioProcessor* filterToStream)
{
    player->setProcessor (filterToStream);

	if (filterToStream != 0) {
		customPlayHead = new CustomPlayHead (filterToStream);
		filterToStream->setPlayHead (customPlayHead);
		PluginAudioProcessor* pluginAudioProcessor = dynamic_cast<PluginAudioProcessor*> (filterToStream);
		if (pluginAudioProcessor != 0) {
			pluginAudioProcessor->setCustomPlayHead (customPlayHead);
		}
	}
}

juce_ImplementSingleton (AudioFilterStreamingDeviceManager);
