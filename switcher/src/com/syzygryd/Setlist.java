package com.syzygryd;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.ListIterator;
import java.util.Vector;

/**
 * An ordered list of Live sets that can be advanced forward and
 * backwards linearly, or specifically chosen.  Instantiated with
 * a configuration file.  Creates child Set objects upon instantiation
 *
 */
public class Setlist {
	private Vector<Set> list = null;
	private ListIterator<Set> it = null;
	private static final int PARAM_NAME = 0;
	private static final int PARAM_LEN_IN_SECS = 1;
	
	/**
	 * creates a new setlist from a file containing lines with comma-separated set filename & length in seconds
	 * @param fileName
	 * @throws FileNotFoundException if file is missing or can't be read
	 * @throws Exception if a line doesn't contain 1 & only 1 comma
	 * @throws NumberFormatException if the second parameter isn't an integer
	 */
	public Setlist(String fileName) throws Exception {
		if (fileName == null) {
			throw new FileNotFoundException("Must specify set list");
		}
		
		list = new Vector<Set>();
		
		File f = new File(fileName);
		
		if (!f.canRead()) {
			throw new FileNotFoundException("Can't open set list " + fileName);
		}
		
		BufferedReader reader = new BufferedReader(new FileReader(f));
		
		String line = null;
		while ((line = reader.readLine()) != null) {
			String[] params = line.split(",");
			
			if (params.length != 2) {
				reader.close();
				throw new Exception("Invalid line: \n"+ line + "\nEach line must contain only the file name, a comma, and the length of the set in seconds.");
			}
			
			try {
				list.add(new Set(params[PARAM_NAME], Integer.valueOf(params[PARAM_LEN_IN_SECS])));
			} catch (NumberFormatException e) {
				reader.close();
				throw new NumberFormatException("invalid number for length (in whole seconds) " + params[PARAM_LEN_IN_SECS] + " on line\n" + line);
			}
		}
		
		if (list.size() == 0) {
			throw new Exception("file was empty. try again with a file that has songs listed.");
		}
		
		it = list.listIterator();
	}
	
	public Set getNext() {
		if (!it.hasNext()) {
			it = list.listIterator();
		}
		return it.next();
	}
	
	public Set getPrev() {
		if (!it.hasPrevious()) {
			it = list.listIterator(list.size()-1);
		}
	
		return it.previous();
	}
	
	public Set getSet(int s) {
		if (s > list.size()) {
			s = 0;
		}
		it = list.listIterator(s);
		
		return it.next();
	}
}
