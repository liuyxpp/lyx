package generic_dialog;
import java.awt.*;
import java.awt.event.*;
import ij.*;
import ij.gui.*;
import java.util.*;
import ij.plugin.frame.Recorder;


/** create a GenericDialog that remains active to allow for repeated 
  * runs through target program, enabling the use of add-on buttons to 
  * perform different and repeatable functions.
  * See code at bottom and WindowLevelAdjuster class for implementation examples 
*/
public class GenericRecallableDialog extends GenericDialogPlus
			implements AdjustmentListener, KeyListener, FocusListener {
	private Button[] buttons = new Button[MAX_ITEMS]; 
	private boolean[] buttons_touched = new boolean[MAX_ITEMS]; 
	private int butIndex, butTot;
	Thread thread;
	public final int WEST=0, CENTER=1; // location flags

	public GenericRecallableDialog(String title) {
 		super(title);
 		setModal(false);
 	}
 	
 	public GenericRecallableDialog(String title, Frame parent) {
		super(title, parent);
 		setModal(false);
	}

	/** changes from parent showDialog(): remove accept button */
	public void showDialog() {
		nfIndex = 0;
		sfIndex = 0;
		cbIndex = 0;
		choiceIndex = 0;
		sbIndex = 0;
		butIndex = 0;
		if (macro) {
			//IJ.write("showDialog: "+macroOptions);
			dispose();
			return;
		}
		if (stringField!=null&&numberField==null) {
			TextField tf = (TextField)(stringField.elementAt(0));
			tf.selectAll();
		}
		cancel = new Button(" Done "); // changed from "Cancel"
		cancel.addActionListener(this);
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.CENTER;
		c.insets = new Insets(5, 0, 0, 0); // top,left,bot,right coords
		grid.setConstraints(cancel, c);
		add(cancel);
		if (IJ.isMacintosh())
			setResizable(false);
		pack();
		GUI.center(this);
		setVisible(true);
		IJ.wait(250); // work around for Sun/WinNT bug
	}

	/** the keyboard input (arrow keys) will be caught by whichever button 
	  * has the current focus, but will affect the scrollbar last touched	*/
	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		IJ.setKeyDown(keyCode);
		if (scrollbars[SBlastTouched] != null) {
			// left is 37, right is 39;  numpad4 is 100, numpad6 is 102
			if (keyCode == KeyEvent.VK_LEFT || keyCode == KeyEvent.VK_NUMPAD4) {
				SBcurValues[SBlastTouched] -= 
						scrollbars[SBlastTouched].getUnitIncrement()/SBscales[SBlastTouched];
				setScrollBarValue(SBlastTouched,SBcurValues[SBlastTouched]);
			}
			if (keyCode == KeyEvent.VK_RIGHT || keyCode == KeyEvent.VK_NUMPAD6) {
				SBcurValues[SBlastTouched] += 
						scrollbars[SBlastTouched].getUnitIncrement()/SBscales[SBlastTouched];
				setScrollBarValue(SBlastTouched,SBcurValues[SBlastTouched]);
			}
		}
	}

	public void actionPerformed(ActionEvent e) {
		wasCanceled = (e.getSource()==cancel);
		nfIndex = 0; // reset these so that call to getNext...() will work
		sfIndex = 0;
		cbIndex = 0;
		sbIndex = 0; 
		choiceIndex = 0;
		for (int i=0; i<butTot; i++)
			buttons_touched[i] = (e.getSource()==buttons[i]);
		butIndex = 0;
		if (wasCanceled) { setVisible(false); dispose(); }
	}

	/** Adds a button to the dialog window */
	public void addButton(String text) {
		addButton(text, WEST);
	}

	public void addButton(String text, int location) {
		if (butIndex >= MAX_ITEMS) {
			IJ.write("  cannot add another button, have maxed out at: "+butIndex);
		return;
	}
		buttons[butIndex] = new Button(text);
		buttons[butIndex].addActionListener(this);
		buttons[butIndex].addKeyListener(this); // for scrollbar keyboard control

		c.gridwidth = 1;
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.WEST;
		if (location == CENTER)
		  c.anchor = GridBagConstraints.CENTER;
		c.insets = new Insets(5, 0, 5, 0);
		grid.setConstraints(buttons[butIndex], c);
		activePanel.add(buttons[butIndex]);
		buttons_touched[butIndex] = false;
		butIndex++; butTot = butIndex; y++;
	}

	/** adds 2(3,4) buttons in a row to the dialog window. 
	* Easily extendable to add more buttons */
	public void addButtons(String text1, String text2) {
		Panel butPanel = new Panel();
		GridBagLayout butGrid = new GridBagLayout();
		butPanel.setLayout(butGrid);
		addButtonToPanel(text1, butPanel, butGrid, 0);
		addButtonToPanel(text2, butPanel, butGrid, 1);
		c.gridwidth = 2;
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.WEST;
		c.insets = new Insets(5, 0, 5, 0);
		grid.setConstraints(butPanel, c);
		activePanel.add(butPanel);
		y++;
	}

	public void addButtons(String text1, String text2, String text3) {
		Panel butPanel = new Panel();
		GridBagLayout butGrid = new GridBagLayout();
		butPanel.setLayout(butGrid);
		addButtonToPanel(text1, butPanel, butGrid, 0); // label, panel, row in grid
		addButtonToPanel(text2, butPanel, butGrid, 1);
		addButtonToPanel(text3, butPanel, butGrid, 2);
		c.gridwidth = 2;
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.WEST;
		c.insets = new Insets(5, 0, 5, 0);
		grid.setConstraints(butPanel, c);
		activePanel.add(butPanel);
		y++;
	}

	public void addButtons(String text1, String text2, String text3, String text4){
		Panel butPanel = new Panel();
		GridBagLayout butGrid = new GridBagLayout();
		butPanel.setLayout(butGrid);
		addButtonToPanel(text1, butPanel, butGrid, 0); // label, panel, row in grid
		addButtonToPanel(text2, butPanel, butGrid, 1);
		addButtonToPanel(text3, butPanel, butGrid, 2);
		addButtonToPanel(text4, butPanel, butGrid, 3);
		c.gridwidth = 1;
		c.gridx = 0; c.gridy = y;
		c.anchor = GridBagConstraints.WEST;
		c.insets = new Insets(5, 0, 5, 0);
		grid.setConstraints(butPanel, c);
		activePanel.add(butPanel);
		y++;
	}

	public void addButtonToPanel(String text, Panel panel, 
    							 GridBagLayout grid, int row) {
		if (butIndex >= MAX_ITEMS) {
			IJ.write("  cannot add another button, have maxed out at: "+butIndex);
			return;
		}
		GridBagConstraints butc  = new GridBagConstraints();
		buttons[butIndex] = new Button(text);
		buttons[butIndex].addActionListener(this);	
		buttons[butIndex].addKeyListener(this);	
		butc.gridx = row; butc.gridy = 0;
		butc.anchor = GridBagConstraints.WEST;
		butc.insets = new Insets(0, 5, 0, 10);
		grid.setConstraints(buttons[butIndex], butc);
		panel.add(buttons[butIndex]);
		buttons_touched[butIndex] = false;
		butIndex++; butTot = butIndex; 
	}

	/** Returns the contents of the next buttons_touched field. */
	public boolean getNextButton() {
		if (butIndex>=butTot)
			return false;
		if (buttons_touched[butIndex]) {
			buttons_touched[butIndex++] = false;
			return true;
		}
		butIndex++;
		return false; // else
	}

	/** Returns the contents of button 'i' field. */
	public boolean getButtonValue(int i) {
		if (i<0 || i>=butTot)
			return false;
		else if (!buttons_touched[i]) 
			return false; 
		buttons_touched[i] = false; // reset vale to false
		return true; // else
	}
}

/** example implementation for a GenericRecallableDialog
    excerpted from an InterActiveSnake program

		GenericRecallableDialog gd = new GenericRecallableDialog("Snake Attributes", IJ.getInstance());
		gd.addScrollBar("Bending Energy Coeff", curEnergy_Bend, 1, 0.0, 50.0);
													// label, 				curVal,      ndigits, min, max
		gd.addScrollBar("Stretch Energy Coeff", curEnergy_Stretch, 1, 0.0, 10.0);
		gd.addScrollBar("Snake Point Sep[mm]", cur_ptSep, 0, 1.0, 15.0);
		gd.addButtons("Screen Select Mode", "Regularize Spacing");
		gd.addButtons("Save Slice", "Save All", "Redisplay", "Help");
		gd.addButton("Recompute Snake",gd.CENTER);
		gd.addCheckbox("Show Snake Point Labels",ShowLabels);
		gd.showDialog(); 
		IJ.wait(500); // give system time to initialize GUI
		while (!(gd.wasCanceled())) { // continuously runs through loop until actively canceled
		  // if this dialog window does not have the focus, don't waste CPU time on it
		  if (gd.getFocusOwner() == null) IJ.wait(500); 
		  else {
		  	// check the "Screen Select Mode" button
				if (gd.getButtonValue(0)) Toolbar.getInstance().setTool(Toolbar.CROSSHAIR);
				
				// check for new values of the scrollbars
		  	prev_ptSep = cur_ptSep;
		  	prev_Ebend = curEnergy_Bend;
		  	prev_Estretch = curEnergy_Stretch;
		  	curEnergy_Bend = (float)(gd.getScrollBarValue(0)); 
		  	curEnergy_Stretch = (float)(gd.getScrollBarValue(1));
		  	cur_ptSep = (float)(gd.getScrollBarValue(2));
		  	
		  	// if new values were found, or if the user hits either the "Regularize Spacing"
		  	//  button or the "Recompute Snake" button, then do new calculation
				if (gd.getButtonValue(1) || gd.getButtonValue(6) || prev_ptSep!=cur_ptSep
							|| prev_Ebend!=curEnergy_Bend || prev_Estretch!=curEnergy_Stretch) {
		    	UpdateAttributes(curEnergy_Bend, curEnergy_Stretch, cur_ptSep);
			  	IJ.wait(500); // give snake time to work
		  	}

				// check the other buttons for activity
				if (gd.getButtonValue(2)) snakeStack.Write("this");
				if (gd.getButtonValue(3)) snakeStack.Write("all");
				if (gd.getButtonValue(4)) working_canvas.update(working_graphics);
				if (gd.getButtonValue(5)) showAbout();

				// check the checkbox for activity -- note the order of checking does not matter
				if (gd.getBooleanValue(0)!=ShowLabels ) {
					ShowLabels = !ShowLabels;
					working_canvas.update(working_graphics);
				}
	 	 	} 
		}	 
		// exit the dialog window cleanly
		gd.setVisible(false);   
		gd.dispose();
		
**/
