/*
  Syzygryd Panel state class.
  
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


/**
 * The Panel class encapsulates the state of a single Syzygryd
 * control panel.
 * 
 * @author Daniel C. Silverstein
 */
public class Panel {
	public int id;
	Panel[] allPanels;
	
	public Tab[] tabs;
	public Tab selectedTab;

	public final String VERSION = "0.1.0";

	/**
	 * Panel constructor
	 * 
	 * @param _id int, unique numeric id of this panel
	 * @param _allPanels Panel[], array that will contain references to
	 * all panels
	 * @param _ntabs int, number of tabs this panel contains
	 */
	public Panel(int _id, Panel[] _allPanels, int _ntabs) {
		id = _id;
		allPanels = _allPanels;
		tabs = new Tab[_ntabs];
	}
	
	public void selectTab(int id) {
		selectedTab = tabs[id];
	}
	
	public Panel getNextPanel() {
		return allPanels[(id + 1) % allPanels.length];
	}
	
	public Panel getPrevPanel() {
		int prevId = (id - 1) % allPanels.length;
		if (prevId < 0) {
			// Fuck you java.  This is why we can't have nice things!
			prevId = prevId + allPanels.length;
		}
		
		return allPanels[prevId];
	}
	
	/**
	 * getOscId
	 * 
	 * @return the OSC id of this panel
	 */
	public int getOscId() {
		return id + 1;
	}

	/**
	 * return the version of the library.
	 * 
	 * @return String
	 */
	public String version() {
		return VERSION;
	}
}
