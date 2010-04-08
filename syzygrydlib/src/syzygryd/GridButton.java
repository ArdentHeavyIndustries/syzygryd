/*
Syzygryd Grid Button state class.

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
 * The GridButton class encapsulates the state of a single
 * Syzygryd button on laid out on a grid on a tab.
 * 
 * @author Daniel C. Silverstein
 */
public abstract class GridButton extends Button {
	public int col;
	public int row;
	
	/**
	 * GridButton constructor
	 * 
	 * @param _col int, the column this button resides in
	 * @param _row int, the row this button resides in
	 * @param _tab int, the tab this button resides in
	 */
	public GridButton(int _col, int _row, GridPatternTab _tab) {
		super(_tab);
		col = _col;
		row = _row;
	}

	/**
	 * getLeftSibling
	 * 
	 * @return the corresponding button on the panel to the left of
	 * this one.
	 */
	public Button getLeftSibling() {
		Panel leftPanel = panel.getPrevPanel();
		return ((GridPatternTab) leftPanel.selectedTab).buttons[col][row];
	}

	/**
	 * getRightSibling
	 * 
	 * @return the corresponding button on the panel to the right of
	 * this one.
	 */	
	public Button getRightSibling() {
		Panel rightPanel = panel.getNextPanel();
		return ((GridPatternTab) rightPanel.selectedTab).buttons[col][row];
	}
	
	/**
	 * getOscRow handles the fact that OSC is indexed from 1 not 0,
	 * and has an inverted y-axis vs. processing.
	 * 
	 * @return this button's row for use in an OSC address
	 */
	public int getOscRow() {
		return (row * -1) + tab.gridHeight;
	}

	/**
	 * getOscCol Handles the fact that OSC is indexed from 1 not 0.
	 * 
	 * @return this button's column for use in an OSC address
	 */
	public int getOscCol() {
		return col + 1;
	}

	public String getOscAddress() {
		return "/" + panel.getOscId() + "_" + tab.getOscId() + "/panel/" + getOscRow() + "/" + getOscCol(); // e.g. /1_tab1/panel/1/1
	}
}
