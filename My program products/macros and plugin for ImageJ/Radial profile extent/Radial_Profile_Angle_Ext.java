import ij.*;
import ij.gui.*;
import ij.util.*;
import ij.plugin.filter.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;
import ij.measure.*;
import ij.measure.Calibration;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import ij.text.*;
import multi_plot.*;
import generic_dialog.*;


/** This plugin is an update of the Radial Profile plugin from Paul Baggethun.
 *  http://rsb.info.nih.gov/ij/plugins/radial-profile.html
 *  This plugin lets you choose the starting angle and integration angle
 *  over which the integration on the defined circle is done.
 *  The integration will be done over an area defined by :
 *  starting angle +/- integration angle.
 *  The size and the position of the Roi can be defined and modified by
 *  either using the plugin menu or shortkeys on keyboard.
 *  Additionnally, the integration calculation can be done over a whole stack.
 *
 *  The plugin is implementing the GenericRecallableDialog developped in the
 *  Contour_Plotter routine by Walter O'Dell PhD (wodell@rochester.edu) as
 *  well as extending the MultyPlotWindow developped in the Color_Profiler
 *  routine by Dimiter Prodanov (University of Leiden).
 *
 *  The plugin includes also a routine abling the calculation of the radius
 *  of the generated Roi and saving the data in a result panel.
 *
 *  Last updated: 4-20-2005
 *  author : Philippe Carl (philippe.carl@mpikg.mpg.de)
*/

public class Radial_Profile_Angle_Ext implements PlugInFilter, ActionListener, ItemListener, KeyListener, Measurements {

	ImagePlus imp;
	ImageProcessor ip2;
	ImageCanvas canvas;
	Rectangle rct;
//	PlotWindowExt pw;
	MultyPlotExt plot;
	static boolean useCalibration = true;
	int nBins=100;
	int[] xPoint = new int[3];
	int[] yPoint = new int[3];
	int Sa;		// Starting angle in degree over which the calculation is done
	int Ia;		// Integration angle in degree over which the calculation is done
	double X0;	// X center in pixels of the circle over which the calculation is done
	double Y0;	// Y center in pixels of the circle over which the calculation is done
	double mR;	// Radius in pixels of the circle over which the calculation is done
	double cosMin, cosMax, sinMin, sinMax;
	Button button1, button2, button3, button4, button5;
	Checkbox cb;
	TextField t1 = new TextField( "" );
	TextField t2 = new TextField( "" );
	TextField t3 = new TextField( "" );
	TextField t4 = new TextField( "" );
	TextField t5 = new TextField( "" );

	public int setup(String arg, ImagePlus imp) {
		if (arg.equals("about"))
			{showAbout(); return DONE;}
		this.imp = imp;
		return DOES_ALL+NO_UNDO+ROI_REQUIRED;
	}

	public void run(ImageProcessor ip) {
		imp.unlock();
		ip2 = ip;
		Sa = 180;
		Ia = 40;
		ImageWindow win = imp.getWindow();
		canvas = win.getCanvas();
		canvas.addKeyListener(this);
		setXYcenter();
		IJ.makeOval((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR));
		doDialog();
	}

	public void setXYcenter() {
		rct = imp.getRoi().getBoundingRect();
		X0 = (double) rct.x + (double) rct.width / 2;
		Y0 = (double) rct.y + (double) rct.height / 2;
		mR = (rct.width + rct.height) / 4.0;
	}

	public void updateXY() {
		X0=Double.valueOf(t1.getText()).doubleValue();
		Y0=Double.valueOf(t2.getText()).doubleValue();
		mR=Double.valueOf(t3.getText()).doubleValue();
		Sa=Double.valueOf(t4.getText()).intValue();
		Ia=Double.valueOf(t5.getText()).intValue();
	}

	private void setValues() {
		t1.setText(""+X0);
		t2.setText(""+Y0);
		t3.setText(""+mR);
		t4.setText(""+Sa);
		t5.setText(""+Ia);
	}

	public double cos(double val) {
		if(Math.IEEEremainder(val, 2.0 * Math.PI) == 0.0)
			return 1.0;
		else if(Math.IEEEremainder(val, Math.PI) == 0.0)
			return -1.0;
		else if(Math.IEEEremainder(val, Math.PI / 2.0) == 0.0)
			return 0.0;
		else
			return Math.cos(val);
	}

	public int colorX(int val) {
		if(Math.IEEEremainder((double) (val-1), 4.0) == 0.0)
			return 1;
		else
			return 0;
	}

	public int colorY(int val) {
		if(Math.IEEEremainder((double) (val-2), 4.0) == 0.0)
			return 1;
		else
			return 0;
	}

	public int colorZ(int val) {
		if(Math.IEEEremainder((double) (val-3), 4.0) == 0.0)
			return 1;
		else
			return 0;
	}

	public double sin(double val) {
		if(Math.IEEEremainder(val, Math.PI) == 0.0)
			return 0.0;
		else
			return Math.sin(val);
	}

	private void setCosSin() {
		int i;
		double tmpVal;
		cosMin = cos(Math.PI * (Sa - Ia) / 180.0);
		cosMax = cosMin;
		sinMin = sin(Math.PI * (Sa - Ia) / 180.0);
		sinMax = sinMin;
		for(i = 1; i <= 2*Ia; i++) {
			tmpVal = cos(Math.PI * (Sa - Ia + i) / 180);
			if(tmpVal > cosMax)
				cosMax = tmpVal;
			else if(tmpVal < cosMin)
				cosMin = tmpVal;
			tmpVal = sin(Math.PI * (Sa - Ia + i) / 180);
			if(tmpVal > sinMax)
				sinMax = tmpVal;
			else if(tmpVal < sinMin)
				sinMin = tmpVal;
		}
	}

	public void doRadialDistribution(ImageProcessor ip) {
	        String[] headings = new String[2];
		int i;
		int thisBin;
		nBins = (int) (3*mR/4);
		float[][] Accumulator = new float[2][nBins];
		double a, b;
		double R;
		double xmin = X0 - mR, xmax = X0 + mR, ymin = Y0 - mR, ymax = Y0 + mR;
		setCosSin();
		for (a = xmin; a <= xmax; a++) {
			for (b = ymin; b <= ymax; b++) {
				R = Math.sqrt((a - X0) * (a - X0) + (b - Y0) * (b - Y0));
				if( (a - X0) / R >= cosMin && (a - X0) / R <= cosMax ) {
					if( (Y0 - b) / R >= sinMin && (Y0 - b) / R <= sinMax ) {
						thisBin = (int) Math.floor((R/mR) * (double) nBins);
						if (thisBin == 0) thisBin = 1;
						thisBin = thisBin - 1;
						if (thisBin > nBins - 1) thisBin = nBins - 1;
						Accumulator[0][thisBin] = Accumulator[0][thisBin] + 1;
						Accumulator[1][thisBin] = Accumulator[1][thisBin] + ip.getPixelValue((int) a, (int) b);
					}
				}
			}
		}
		Calibration cal = imp.getCalibration();
		if (cal.getUnit() == "pixel") useCalibration=false;
		if (useCalibration) {
			for (i = 0; i < nBins; i++) {
				Accumulator[1][i] = Accumulator[1][i] / Accumulator[0][i];
				Accumulator[0][i] = (float) (cal.pixelWidth*mR*((double)(i + 1) / nBins));
			}
//			pw = new PlotWindowExt("Radial Profile Plot - "+getImageTitle(), "Radius ["+cal.getUnits()+"]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			plot = new MultyPlotExt(getImageTitle(), "Radius ["+cal.getUnits()+"]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			headings[0] = "Radius ["+cal.getUnits()+"]";
		} else {
			for (i = 0; i < nBins; i++) {
				Accumulator[1][i] = Accumulator[1][i] / Accumulator[0][i];
				Accumulator[0][i] = (float) (mR * ((double) (i + 1) / nBins));
			}
//			pw = new PlotWindowExt("Radial Profile Plot - "+getImageTitle(), "Radius [pixels]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			plot = new MultyPlotExt(getImageTitle(), "Radius [pixels]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			headings[0] = "Radius [pixels]\t";
		}
//		pw.draw();
		headings[1] = "Normalized Integrated Intensity";
	        MultyPlotWindowExt wnd = plot.show();
        	wnd.setLineHeadings(headings, false);
	}

	public void doStackRadialDistribution() {
		int i, j;
		int thisBin;
		nBins = (int) (3*mR/4);
	        String[] headings = new String[imp.getStackSize()+1];
		float[]   dataX = new float[nBins];
		float[][] dataY = new float[imp.getStackSize()][nBins];
		float minY, maxY;
		double[] extrema;
		double a, b;
		double R;
		double xmin = X0 - mR, xmax = X0 + mR, ymin = Y0 - mR, ymax = Y0 + mR;
		setCosSin();
		Calibration cal = imp.getCalibration();
		if (cal.getUnit() == "pixel") useCalibration=false;

		for (j = 0; j <= imp.getStackSize()-1; j++) {
			imp.setSlice(j+1);
			headings[j+1] = getImageTitle();
			for (a = xmin; a <= xmax; a++) {
				for (b = ymin; b <= ymax; b++) {
					R = Math.sqrt((a - X0) * (a - X0) + (b - Y0) * (b - Y0));
					if( (a - X0) / R >= cosMin && (a - X0) / R <= cosMax ) {
						if( (Y0 - b) / R >= sinMin && (Y0 - b) / R <= sinMax ) {
							thisBin = (int) Math.floor((R/mR) * (double) nBins);
							if (thisBin == 0) thisBin = 1;
							thisBin = thisBin - 1;
							if (thisBin > nBins - 1) thisBin = nBins - 1;
							dataX[thisBin] = dataX[thisBin] + 1;
							dataY[j][thisBin] = dataY[j][thisBin] + ip2.getPixelValue((int) a, (int) b);
						}
					}
				}
			}
			for (i = 0; i < nBins; i++) {
				dataY[j][i] =  dataY[j][i] / dataX[i];
				dataX[i] = 0;
			}
		}
		minY = dataY[0][0];
		maxY = dataY[0][0];
		for (j = 0; j <= imp.getStackSize()-1; j++) {
			extrema = Tools.getMinMax(dataY[j]);
			if (extrema[0] < minY)
				minY = (float) extrema[0];
			else if (extrema[1] > maxY)
				maxY = (float) extrema[1];
		}
		if (useCalibration) {
			for (i = 0; i < nBins; i++)
				dataX[i] = (float) (cal.pixelWidth*mR*((double)(i + 1) / nBins));
			plot = new MultyPlotExt("Radial Profile Plot", "Radius ["+cal.getUnits()+"]", "Normalized Integrated Intensity", dataX, minY, maxY);
			headings[0] = "Radius ["+cal.getUnits()+"]";
		} else {
			for (i = 0; i < nBins; i++)
				dataX[i] = (float) (mR * ((double) (i + 1) / nBins));
			plot = new MultyPlotExt("Radial Profile Plot", "Radius [pixels]", "Normalized Integrated Intensity", dataX, minY, maxY);
			headings[0] = "Radius [pixels]";
		}
		for (j = 0; j <= imp.getStackSize()-1; j++) {
			plot.setColor(new Color(colorX(j) * 0xff, colorY(j) * 0xff, colorZ(j) * 0xff));
			plot.addPoints(dataX,dataY[j],2);
		}
		plot.setLimits(dataX[0], dataX[nBins-1], minY, maxY);
		MultyPlotWindowExt wnd = plot.show();
		wnd.setLineHeadings(headings, false);
//		wnd.setPrecision(3,3);
	}

	public String getImageTitle() {
		String str;
		if (imp.getStackSize()>1) {
			ImageStack stack = imp.getStack();
			return stack.getShortSliceLabel(imp.getCurrentSlice());
		}
		else {
			str = imp.getTitle();
			int len = str.length();
			if (len>4 && str.charAt(len-4)=='.' && !Character.isDigit(str.charAt(len-1)))
			return str.substring(0,len-4);  
		}
		return "";
	}

	public void calculateRoiRadius(ImageProcessor ip) {
		String title;
		Calibration cal = imp.getCalibration();
		int measurements = Analyzer.getMeasurements();			// defined in Set Measurements dialog
		Analyzer.setMeasurements(measurements);
		Analyzer a = new Analyzer();
		ImageStatistics stats = imp.getStatistics(measurements);
		Roi roi = imp.getRoi();
		title = getImageTitle();
		a.saveResults(stats, roi);					// store in system results table
		ResultsTable rt = Analyzer.getResultsTable();			// get the system results table
		rt.addLabel("Label", title);
		if (useCalibration) {
			rt.addValue("Radius ["+cal.getUnits()+"]", cal.pixelWidth*mR);
			rt.addValue("Radius [pixels]", mR);
		}
		else
			rt.addValue("Radius [pixels]", mR);
//		rt.addValue("X Center [pixels]", X0);
//		rt.addValue("Y Center [pixels]", Y0);
//		rt.addValue("Starting Angle [°]", Sa);
//		rt.addValue("Integration Angle [°]", Ia);
		a.displayResults();						//display the results in the worksheet
		a.updateHeadings();						// update the worksheet headings
	}

	private void doDialog() {
		GenericRecallableDialog gd = new GenericRecallableDialog("Radial Profile Angle...", IJ.getInstance());
		gd.addPanel(addPanel());
		gd.showDialog();
		while (!(gd.wasCanceled())) {
		}
		canvas.removeKeyListener(this);
	}

	private Panel smallPanel(String str, TextField tf) {
		Panel spanel = new Panel();
//		spanel.setLayout(new GridLayout(1, 2));
		spanel.add( new Label(str) );
		spanel.add( tf );
		return spanel;
	}

	private Panel addPanel() {
		Panel panel = new Panel();
		panel.setLayout(new GridLayout(11, 1));
		panel.add(smallPanel("X center (pixels):", t1));
		panel.add(smallPanel("Y center (pixels):", t2));
		panel.add(smallPanel("Radius (pixels):  ", t3));
		button1 = new Button("Plot Droplet ROI (t)");
		button1.addActionListener(this);
		panel.add(button1);
		panel.add(smallPanel("Starting angle (°):     ", t4));
		panel.add(smallPanel("Integration angle (°):", t5));
		button2 = new Button("Plot Integration Area (b)");
		button2.addActionListener(this);
		panel.add(button2);
		button3 = new Button("Calculate ROI Radius (g)");
		button3.addActionListener(this);
		panel.add(button3);
		button4 = new Button("Calculate Radial Profile (q)");
		button4.addActionListener(this);
		panel.add(button4);
		button5 = new Button("Calculate Stack Radial Profile (u)");
		button5.addActionListener(this);
		panel.add(button5);
		cb = new Checkbox("Use Spatial Calibration"); 
		cb.setState(useCalibration);
		cb.addItemListener (this);
		panel.add(cb);
		setValues();

		return panel;
	}

	public synchronized void itemStateChanged(ItemEvent e) {
	}

	public void actionPerformed(ActionEvent e) {
		Object b = e.getSource();

		if (b==button1) {
			updateXY();
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();
		}
		if (b==button2) {
			updateXY();
			xPoint[0] = (int) ( X0 + mR * cos(Math.PI * (Sa - Ia) / 180) );
			xPoint[1] = (int) ( X0 );
			xPoint[2] = (int) ( X0 + mR * cos(Math.PI * (Sa + Ia) / 180) );
			yPoint[0] = (int) ( Y0 - mR * sin(Math.PI * (Sa - Ia) / 180) );
			yPoint[1] = (int) ( Y0 );
			yPoint[2] = (int) ( Y0 - mR * sin(Math.PI * (Sa + Ia) / 180) );
			imp.setRoi(new PolygonRoi(xPoint, yPoint, 3,  Roi.ANGLE));
			imp.repaintWindow();
		}
		if (b==button3) {
			useCalibration = cb.getState();
			updateXY();
			calculateRoiRadius(ip2);
		}
		if (b==button4) {
			useCalibration = cb.getState();
			updateXY();
			doRadialDistribution(ip2);
		}
		if (b==button5) {
			if (imp.getStackSize()>1) {
				useCalibration = cb.getState();
				updateXY();
				doStackRadialDistribution();
			}
			else
				IJ.showMessage("Error", "Stack required");
		}
	}

	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		int flags = e.getModifiers();

		if (keyCode == KeyEvent.VK_RIGHT || keyCode == KeyEvent.VK_NUMPAD6) { 
			if (flags==KeyEvent.ALT_MASK)
				X0+=5;
			else if (flags==KeyEvent.CTRL_MASK)
				X0+=10;
			else
				X0++;
			t1.setText(""+X0);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();			
		}
		if (keyCode == KeyEvent.VK_LEFT || keyCode == KeyEvent.VK_NUMPAD4) { 
			if (flags==KeyEvent.ALT_MASK)
				X0-=5;
			else if (flags==KeyEvent.CTRL_MASK)
				X0-=10;
			else
				X0--;
			t1.setText(""+X0);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();			
		}
		if (keyCode == KeyEvent.VK_DOWN || keyCode == KeyEvent.VK_NUMPAD2) { 
			if (flags==KeyEvent.ALT_MASK)
				Y0+=5;
			else if (flags==KeyEvent.CTRL_MASK)
				Y0+=10;
			else
				Y0++;
			t2.setText(""+Y0);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();			
		}
		if (keyCode == KeyEvent.VK_UP || keyCode == KeyEvent.VK_NUMPAD8) { 
			if (flags==KeyEvent.ALT_MASK)
				Y0-=5;
			else if (flags==KeyEvent.CTRL_MASK)
				Y0-=10;
			else
				Y0--;
			t2.setText(""+Y0);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();			
		}

		if (keyCode== KeyEvent.VK_PAGE_UP || keyCode==e.VK_ADD) {
			if (flags==KeyEvent.ALT_MASK)
				mR+=5;
			else if (flags==KeyEvent.CTRL_MASK)
				mR+=10;
			else
				mR++;
			t3.setText(""+mR);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();
		}
		if (keyCode== KeyEvent.VK_PAGE_DOWN || keyCode==e.VK_SUBTRACT) {
			if (flags==KeyEvent.ALT_MASK) {
				if(mR >= 5)
					mR-=5;
			}
			else if (flags==KeyEvent.CTRL_MASK) {
				if(mR >= 5)
					mR-=10;
			}
			else {
				if(mR >= 1)
					mR--;
			}
			t3.setText(""+mR);
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();
		}
		if (keyCode==e.VK_T) {
			updateXY();
			imp.setRoi(new OvalRoi((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR)));
			imp.repaintWindow();
		}
		if (keyCode==e.VK_B) {
			updateXY();
			xPoint[0] = (int) ( X0 + mR * cos(Math.PI * (Sa - Ia) / 180) );
			xPoint[1] = (int) ( X0 );
			xPoint[2] = (int) ( X0 + mR * cos(Math.PI * (Sa + Ia) / 180) );
			yPoint[0] = (int) ( Y0 - mR * sin(Math.PI * (Sa - Ia) / 180) );
			yPoint[1] = (int) ( Y0 );
			yPoint[2] = (int) ( Y0 - mR * sin(Math.PI * (Sa + Ia) / 180) );
			imp.setRoi(new PolygonRoi(xPoint, yPoint, 3,  Roi.ANGLE));
			imp.repaintWindow();
		}
		if (keyCode==e.VK_G) {
			useCalibration = cb.getState();
			updateXY();
			calculateRoiRadius(ip2);
		}
		if (keyCode==e.VK_Q) {
			useCalibration = cb.getState();
			updateXY();
			doRadialDistribution(ip2);
		}
		if (keyCode==e.VK_U) {
			if (imp.getStackSize()>1) {
				useCalibration = cb.getState();
				updateXY();
				doStackRadialDistribution();
			}
			else
				IJ.showMessage("Error", "Stack required");
		}
	}

	public void keyReleased(KeyEvent e) {
	}

	public void keyTyped(KeyEvent e) {
	}

	public void showAbout() {
		IJ.showMessage("Radial Profile Angle...",
			"This plugin is an update of the Radial Profile plugin from Paul Baggethun:\n" +
			"http://rsb.info.nih.gov/ij/plugins/radial-profile.html.\n" +
			"The plugin lets you choose the starting angle and integration angle over\n" +
			"which the integration on the defined Roi is done.\n" +
			"The integration will be done over an area defined by :\n" +
			"starting angle +/- integration angle.\n" +
			"The size and the position of the Roi can be defined and modified by\n" +
			"either using the plugin menu or shortkeys on keyboard.\n" +
			"Additionnally, the integration calculation can be done over a whole stack.\n" +
			"                                                                                                                                               \n" +
			"The plugin is implementing the GenericRecallableDialog developped in the\n" +
			"Contour_Plotter routine from Walter O'Dell PhD (wodell@rochester.edu) as\n" +
			"well as extending the MultyPlotWindow developped in the Color_Profiler\n" +
			"routine by Dimiter Prodanov (University of Leiden).\n" +
			"                                                                                                                                               \n" +
			"The plugin includes also a routine abling the calculation of the radius\n" +
			"of the generated Roi and saving the data in a result panel.\n" +
			"                                                                                                                                               \n" +
			"Last updated: 4-20-2005\n\n" +
			"Author : Philippe Carl (philippe.carl@mpikg.mpg.de)"
		);
	}

}

