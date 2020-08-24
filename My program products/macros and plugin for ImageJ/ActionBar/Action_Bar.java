import ij.*;
import ij.plugin.*;
import ij.macro.*;
import ij.Prefs;

import javax.swing.JToolBar;
import javax.swing.JButton;
import javax.swing.ImageIcon;

import javax.swing.JFrame;
import javax.swing.JPanel;

import java.net.URL;
import java.io.*;
import java.awt.Frame;
import java.awt.GridLayout;

import java.awt.Insets;
import java.awt.event.*;

/**
 * @author Jerome Mutterer jerome.mutterer(at)ibmp-ulp.u-strasbg.fr
 * 
 */

public class Action_Bar extends JPanel implements PlugIn, ActionListener {

	private static final long serialVersionUID = 7436194992984622141L;

	String macrodir = IJ.getDirectory("macros");

	String name, title, path;

	String separator = System.getProperty("file.separator");

	JFrame frame = new JFrame(name);

	JToolBar toolBar = null;

	boolean tbOpenned = false;

	JButton button = null;

	public void run(String s) {

		// get the right config file from arguments
		// s used if called from another plugin, or from an installed  command.
		// arg used when called from a run("command", arg) macro function
		// if both are empty, we choose the demo actionbar "ActionBarDemo.txt"

		String arg = Macro.getOptions();

		if (arg == null && s.equals("")) { // simple call, get the demo bar
			try {
				/*path = Action_Bar.class.getResource("ActionBarDemo.txt")
						.getFile();
				name = path.substring(path.lastIndexOf(separator) + 1);*/
				File macro = new File(Action_Bar.class.getResource("createAB.txt")
						.getFile());
				new MacroRunner(macro);
				return;
				
			} catch (Exception e) {
				IJ.error("Demo ActionBarDemo.txt file not found");
			}

		} else if (arg == null) { // call from an installed command
			path = IJ.getDirectory("startup") + s;
			try {
				name = path.substring(path.lastIndexOf("/") + 1);
			} catch (Exception e) {
			}
		} else { // called from a macro
			path = IJ.getDirectory("startup") + arg;
			try {
				path = path.substring(0, path.indexOf(".txt") + 4);
				name = path.substring(path.lastIndexOf("/") + 1);
			} catch (Exception e) {
			}

		}

		title = name.substring(0, name.indexOf("."));
		frame.setTitle(title);

		if (WindowManager.getFrame(title)!=null) {
		WindowManager.getFrame(title).toFront();
		return;	
		}
		else { WindowManager.addWindow(frame);
		}

		// this listener will save the bar's position and close it.
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				rememberXYlocation();
				e.getWindow().dispose();
				WindowManager.removeWindow(frame);
			}
		});

		frame.getContentPane().setLayout(new GridLayout(0, 1));

		// read the config file, and add toolbars to the frame
		designPanel();

		// setup the frame, and display it
		frame.setResizable(false);
		frame.pack();
		frame.setLocation((int) Prefs.get("actionbar" + title + ".xloc", 10),
				(int) Prefs.get("actionbar" + title + ".yloc", 10));
		frame.setVisible(true);
	}

	private void designPanel() {
		try {
			File file = new File(path);
			if (!file.exists())
				IJ.error("Config File not found");
			BufferedReader r = new BufferedReader(new FileReader(file));
			while (true) {
				String s = r.readLine();
				if (s.equals(null)) {
					closeToolBar();
					break;
				}

				else if (s.startsWith("<line>") && tbOpenned == false) {
					toolBar = new JToolBar();
					tbOpenned = true;
				} else if (s.startsWith("</line>") && tbOpenned == true) {
					closeToolBar();
					tbOpenned = false;

				}

				else if (s.startsWith("<button>") && tbOpenned == true) {
					String label = r.readLine().substring(6);
					String icon = r.readLine().substring(5);
					String action = r.readLine().substring(7);
					String arg = r.readLine().substring(4);
					button = makeNavigationButton(icon, action + ";" + arg,
							label, label);
					toolBar.add(button);
				} else if (s.startsWith("<hide>")) {
					button = makeNavigationButton("IJ.gif", "IJ",
							"Show Hide IJ", "IJ");
					toolBar.add(button);

				} else if (s.startsWith("<main>")) {
					setABasMain();
					hideIJ();

				}
			}
			r.close();
		} catch (Exception e) {

		}

	}

	private void closeToolBar() {
		toolBar.setFloatable(false);
		frame.getContentPane().add(toolBar);
		tbOpenned = false;
	}

	protected JButton makeNavigationButton(String imageName,
			String actionCommand, String toolTipText, String altText) {

		String imgLocation = "icons/" + imageName;
		URL imageURL = Action_Bar.class.getResource(imgLocation);
		JButton button = new JButton();
		button.setActionCommand(actionCommand);
		button.setToolTipText(toolTipText);
		button.setMargin(new Insets(3, 3, 3, 3));
		button.addActionListener(this);
		if (imageURL != null) {
			button.setIcon(new ImageIcon(imageURL, altText));
		} else {
			button.setText(altText);
		}
		return button;
	}

	public void actionPerformed(ActionEvent e) {
		String cmd = e.getActionCommand();

		if (cmd.startsWith("run_macro_file")) {
			// run the specified macro file in a new thread 
			try {
				File macro = new File(macrodir + "/"
						+ cmd.substring(cmd.indexOf(";") + 1));
				new MacroRunner(macro);
			} catch (Exception fe) {
				IJ.error("Error in macro file name");
			}

		} else if (cmd.startsWith("install_macro")) {
			IJ.run("Install...", "install=[" + macrodir + "/"
					+ cmd.substring(cmd.indexOf(";") + 1) + "]");
		} else if (cmd.startsWith("run_macro_string")) {
//			 run the specified macro string in a new thread 
			try {
				String macro = cmd.substring(cmd.indexOf(";") + 1);
				new MacroRunner(macro);
			} catch (Exception fe) {
				IJ.error("Error in macro command");
			}

		} else if (cmd.startsWith("IJ")) {
			toggleIJ();

		}
	}

	private void toggleIJ() {
		Frame[] f = Frame.getFrames();
		for (int i = 0; i < f.length; i++)
			if (f[i].getTitle().equals("ImageJ"))
				f[i].setVisible(!f[i].isVisible());
	}

	private void hideIJ() {
		Frame[] f = Frame.getFrames();
		for (int i = 0; i < f.length; i++)
			if (f[i].getTitle().equals("ImageJ"))
				f[i].setVisible(false);
	}

	protected void rememberXYlocation() {
		Prefs.set("actionbar" + title + ".xloc", frame.getLocation().x);
		Prefs.set("actionbar" + title + ".yloc", frame.getLocation().y);
	}

	private void setABasMain() {
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				rememberXYlocation();
				e.getWindow().dispose();
				IJ.run("Quit");

			}
		});
	}

}
