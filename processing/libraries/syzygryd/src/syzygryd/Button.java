/*
Syzygryd Button state class.

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
 * The Button class encapsulates the state of a single Syzygryd
 * button on a tab.
 * 
 * @author Daniel C. Silverstein
 */
public abstract class Button {
	public GridPatternTab tab;
	public Panel panel;

	/**
	 * Button constructor
	 * 
	 * @param tab int, the tab this button resides in
	 */
	public Button(GridPatternTab _tab) {
		tab = _tab;
		panel = _tab.panel;
	}
		
	public abstract OscMessage serializeToOsc();
	public abstract String getOscAddress();
}
