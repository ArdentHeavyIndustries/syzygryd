/*
Syzygryd Toggle Button state class.

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

import oscP5.OscMessage;

/**
 * The ToggleButton class represents a button that can be in one of two
 * states, either on or off.
 * 
 * @author Daniel C. Silverstein
 */
public class ToggleButton extends Button {
	public boolean isOn;
	public static final float ON = (float) 1.0;
	public static final float OFF = (float) 0.0;

	/**
	 * ToggleButton constructor
	 * 
	 * @param _col int, the column this button resides in
	 * @param _row int, the row this button resides in
	 * @param _tab int, the tab this button resides in
	 */
	public ToggleButton(int _col, int _row, GridPatternTab _tab) {
		super(_col, _row, _tab);
		isOn = false;
	}
	
	/**
	 * toggle toggles this button into the opposite state from which it
	 * was in.
	 */
	public void toggle() {
		isOn = !isOn;
	}
	
	public OscMessage serializeToOsc() {
		OscMessage res = new OscMessage(getOscAddress());
		res.add(isOn ? ON : OFF);
		return res;
	}
}
