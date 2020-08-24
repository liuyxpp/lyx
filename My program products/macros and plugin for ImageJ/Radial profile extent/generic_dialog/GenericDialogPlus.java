package generic_dialog;
import java.awt.*;
import java.awt.event.*;
import ij.*;
import ij.gui.*;
import java.util.*;
import ij.plugin.frame.Recorder;


/** Walter O'Dell PhD,  wodell@rochester.edu,   11/6/02
  * Overview of GenericDialogPlus and GenericRecallableDialog classes:
  * these classes enable the specification of scrollbars, buttons, and
  * the objects available in the GenericDialog class that remain active 
  * until the dialog window is actively closed.
  *
  * Attributes:
  *	Scrollbars: enables scrollbars for integer, float and/or double values.
  *	float/double values are facilitated by maintaining a scaling factor 
  *	for each scrollbar, and an Ndigits parameter.
  *	Keyboard arrow keys adjust values of most recently mouse-activated scrollbar.
  *	Buttons: enables buttons that perform actions (besides 'exit')
  *
  *	rowOfItems(): enables placement of multiple objects in a row, 
  *	e.g. the scrollbar title, current value and the scrollbar itsself.
  *	addButtons(): enables easy specification of multiple buttons across a row
  *	getBooleanValue(int index_to_list); getNumericValue(); getButtonValue(); getScrollbarValue()
  *	enables access to the value of any individual object without having to go 
  *	through the entire list of like-objects with getNext...() functions.
  *
  * minor changes to the parent GenericDialog were needed, as described in the header 
  * for the temporary GenericDialog2 class, namely:
  *   1. Changed 'private' attribute to 'protected' for several variables in parent 
  *		 class to facilitate use of these variables by GenericDialogPlus class
  *   2. Added variables (int) x; // GridBagConstraints height variable
  *		and  (Container) activePanel; // facilitates row of items option
  *		and code altered to initialize and update these new variables.
  * It is hoped that these modifications will be made to the parent GenericDialog class
  * in future versions of ImageJ, negating the need for the GenericDialog2 class
  **/
class GenericDialogPlus extends GenericDialog2 
					implements AdjustmentListener, KeyListener, FocusListener {
	/** Maximum number of each component (numeric field, checkbox, etc). */
	public static final int MAX_ITEMS = 20;
	protected Scrollbar[] scrollbars;
	protected double[] SBscales; 
	protected double[] SBcurValues; 
	private Label[] SBcurValueLabels; 
	protected int sbIndex, SBtotal;
	private int[] SBdigits; // Ndigits to right of decimal pt (0==integer)
	protected int x;
	protected int SBlastTouched; // last scrollbar touched; needed for arrow key usage

	// second panel(s) enables placement of multiple items on same line (row)
	private Panel twoPanel;
	private GridBagConstraints tmpc;
	private GridBagLayout tmpgrid;
	private int tmpy;

	public GenericDialogPlus(String title) {
		super(title);
	}

	/** Creates a new GenericDialog using the specified title and parent frame. */
	public GenericDialogPlus(String title, Frame parent) {
		super(title, parent);
	}

	/** access the value of the i'th checkbox */
	public boolean getBooleanValue(int i) {
		if (checkbox==null)
			return false;
		// else
		Checkbox cb = (Checkbox)(checkbox.elementAt(i));
		return cb.getState();
	}

	/** access the value of the i'th numeric field */
	public double getNumericValue(int i) {
		if (numberField==null)
			return 0;
		// else
		TextField tf = (TextField)numberField.elementAt(i);
		String theText = tf.getText();
		String originalText = (String)defaultText.elementAt(i);
		double defaultValue = ((Double)(defaultValues.elementAt(i))).doubleValue();
		double value;
		if (theText.equals(originalText))
			value = defaultValue;
		else {
			Double d = getValue(theText);
			if (d!=null)
				value = d.doubleValue();
			else {
				// invalidNumber = true;
				value = 0.0;
			}
		}
		return value;
	}

	public void beginRowOfItems() {
		tmpc = c; tmpgrid = grid;  tmpy = y;
		twoPanel = new Panel();
		activePanel = twoPanel;
		grid = new GridBagLayout();
		twoPanel.setLayout(grid);
		c = new GridBagConstraints();
		x = y = 0;
	}

	public void endRowOfItems() {
		activePanel = this;
		c = tmpc;  grid = tmpgrid;  y = tmpy;
		c.gridwidth = 1;
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.WEST;
		c.insets = new Insets(0, 0, 0, 0);
		grid.setConstraints(twoPanel, c);
		add(twoPanel);
		x = 0;
		y++;
	}

	/** Adds adjustable scrollbar field.
	* param label	the label
	* param defaultValue	initial state
	* param digits	the number of digits to the right of the decimal place
	* param minval	the range minimum (left side value of slider)
	* param maxval	the range maximum (right side value of slider)
	*/    
	public void addScrollBar(String label, double defaultValue, int digits,
   					double minval, double maxval) {
   	// use default 100 clicks
		addScrollBar(label, defaultValue, digits, minval, maxval, 100);
	}

	public void addScrollBar(String label, double defaultValue, int digits,
   					double minval, double maxval, int maxClicks) {
		if (sbIndex >= MAX_ITEMS) {
			IJ.write("  cannot add another slider, have maxed out at: "+sbIndex);
			return;
		}
		if (scrollbars==null) {
			scrollbars = new Scrollbar[MAX_ITEMS]; 
			SBscales = new double[MAX_ITEMS]; 
			SBcurValues = new double[MAX_ITEMS]; 
			SBcurValueLabels = new Label[MAX_ITEMS]; 
			SBdigits = new int[MAX_ITEMS];
		}    		
		// create new panel that is 3 cells wide for SBlabel, SB, SBcurVal
		Panel sbPanel = new Panel();
		GridBagLayout sbGrid = new GridBagLayout();
		GridBagConstraints sbc  = new GridBagConstraints();
		sbPanel.setLayout(sbGrid);

		// label
		Label theLabel = new Label(label);
		sbc.insets = new Insets(5, 0, 0, 0);
		sbc.gridx = 0; sbc.gridy = 0;
		sbc.anchor = GridBagConstraints.WEST;
		sbGrid.setConstraints(theLabel, sbc);
		sbPanel.add(theLabel);
		
		// scrollbar: only works with integer values so use scaling to mimic float/double
		SBscales[sbIndex] = Math.pow(10.0, digits);
		SBcurValues[sbIndex] = defaultValue;
		int visible = (int)Math.round((maxval-minval)* SBscales[sbIndex]/10.0);
		scrollbars[sbIndex] = new Scrollbar(Scrollbar.HORIZONTAL, 
		(int)Math.round(defaultValue*SBscales[sbIndex]), 
		visible, /* 'visible' == width of bar inside slider == 
		increment taken when click inside slider window */
		(int)Math.round(minval*SBscales[sbIndex]), 
		(int)Math.round(maxval*SBscales[sbIndex] + visible) );
		/* Note that the actual maximum value of the scroll bar is 
		the maximum minus the visible. The left side of the bubble 
		indicates the value of the scroll bar. */
		scrollbars[sbIndex].addAdjustmentListener(this);
		scrollbars[sbIndex].setUnitIncrement(Math.max(1,
		(int)Math.round((maxval-minval)*SBscales[sbIndex]/maxClicks)));
		sbc.gridx = 1;
		sbc.ipadx = 75; // set the scrollbar width (internal padding) to 75 pixels
		sbGrid.setConstraints(scrollbars[sbIndex], sbc);
		sbPanel.add(scrollbars[sbIndex]);
		sbc.ipadx = 0;  // reset
		
		// current value label
		SBdigits[sbIndex] = digits;
		SBcurValueLabels[sbIndex] = new Label(IJ.d2s(SBcurValues[sbIndex], digits));

		sbc.gridx = 2;
		sbc.insets = new Insets(5, 5, 0, 0);
		sbc.anchor = GridBagConstraints.EAST;
		sbGrid.setConstraints(SBcurValueLabels[sbIndex], sbc);
		sbPanel.add(SBcurValueLabels[sbIndex]);
		
		c.gridwidth = 2; // this panel will take up one grid in overall GUI
		c.gridx = x; c.gridy = y;
		c.insets = new Insets(0, 0, 0, 0);
		c.anchor = GridBagConstraints.CENTER;
		grid.setConstraints(sbPanel, c);
		activePanel.add(sbPanel);

		sbIndex++; 
		if (activePanel == this) { x=0; y++; }
		else x++;
		SBtotal = sbIndex;
	} // end scrollbar field

	public void setScrollBarUnitIncrement(int inc) {
		scrollbars[sbIndex-1].setUnitIncrement(inc);
	}
	
	/** Returns the contents of the next scrollbar field. */
	public double getNextScrollBar() {
		if (scrollbars[sbIndex]==null)
			return -1.0;
		else return SBcurValues[sbIndex++];
	}

	/** Returns the contents of scrollbar field 'i' */
	public double getScrollBarValue(int i) {
		if (i<0 || i>=SBtotal || scrollbars[i]==null)
			return -1.0;
		else return SBcurValues[i];
	}

	/** Sets the contents of scrollbar field 'i' to 'value' */
	public void setScrollBarValue(int i, double value) {
		if (i<0 || i>=SBtotal || scrollbars[i]==null)  return;
		scrollbars[i].setValue((int)Math.round(value*SBscales[i]));
		SBcurValues[i] = value;
		SBcurValueLabels[i].setText(IJ.d2s(SBcurValues[i], SBdigits[i]));
	}

	public synchronized void adjustmentValueChanged(AdjustmentEvent e) {
		for (int i=0; i<SBtotal; i++) {
			if (e.getSource()==scrollbars[i]) {
				SBcurValues[i] = scrollbars[i].getValue()/ SBscales[i];
				setScrollBarValue(i,SBcurValues[i]);
				SBlastTouched = i; // set keyboard input to be directed to this scrollbar
			}
		}
		sbIndex = 0; // reset for next call to getNextScrollBar()
	}
	 
	/** Displays this dialog box. */
	public void showDialog() {
		sbIndex = 0; 
		super.showDialog();
	}

}
