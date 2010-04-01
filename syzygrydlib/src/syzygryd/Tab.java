/*
  Syzygryd Tab state class.
  
  (c) copyright 2010 Ardent Heavy Industries
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
 */

package syzygryd;

import oscP5.OscBundle;

/**
 * The Tab class encapsulates the state of a single Syzygryd
 * tab on a control panel.
 * 
 * @author Daniel C. Silverstein
 */
public abstract class Tab {
	public int id;
	public Panel panel;
	
	/**
	 * Tab constructor
	 * 
	 * @param _id int, numeric id of this tab, unique within a panel
	 * @param _panel Panel, the panel where this tab resides
	 */
	public Tab(int _id, Panel _panel) {
		id = _id;
		panel = _panel;
	}
	
	/**
	 * serializeToOsc
	 * 
	 * @return the state of this tab serialized as an OscBundle
	 */
	public abstract OscBundle serializeToOsc();
	
	/**
	 * getOscId
	 * 
	 * @return the OSC id of this tab
	 */
	public String getOscId() {
		return "tab" + (id + 1);
	}
}
