/*
Syzygryd GridPatternTab state class.

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
 * The GridPatternTab class represents a tab containing a grid
 * of buttons.
 *  
 * @author Daniel C. Silverstein
 */
public class GridPatternTab extends Tab {
	public Button[][] buttons;
	public int gridWidth;
	public int gridHeight;
	
	/**
	 * GridPatternTab constructor
	 * 
	 * @param _id int, numeric id of this tab, unique within a panel
	 * @param _panel Panel, the panel where this tab resides
	 * @param _gridWidth int, number of columns wide the grid is
	 * @param _gridHeight int, number of rows tall the grid is
	 */
	public GridPatternTab(int _id, Panel _panel, int _gridWidth, int _gridHeight) {
		super(_id, _panel);
		gridWidth = _gridWidth;
		gridHeight = _gridHeight;
		buttons = new Button[gridWidth][gridHeight];
	}
	
	public OscBundle serializeToOsc() {
		OscBundle res = new OscBundle();
		for (int i = 0; i < gridWidth; i++) {
			for (int j = 0; j < gridHeight; j++) {
				res.add(buttons[i][j].serializeToOsc());
			}
		}
		
		return res;
	}
}
