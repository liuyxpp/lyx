import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;
import ij.gui.*;
import ij.measure.Calibration;
import java.awt.*;
import java.util.*;
import multi_plot.*;


/** This plugin is an update of the Radial Profile plugin from Paul Baggethun.
 *  http://rsb.info.nih.gov/ij/plugins/radial-profile.html
 *  This plugin lets you choose the integration height or integration angle
 *  over which the integration on the defined circle is done.
 *  The integration will be done only on the left side of the circle over
 *  an area defined by : +/- integration angle or +/- integration angle.
 *  Last updated: 1-6-2005
 *  author : Philippe Carl (philippe.carl@mpikg.mpg.de)
*/

public class Radial_Profile_Height implements PlugInFilter {

	ImagePlus imp;
	boolean canceled=false;
	double X0;	// X center in pixels of the circle over which the calculation is done
	double Y0;	// Y center in pixels of the circle over which the calculation is done
	double mR;	// Radius in pixels of the circle over which the calculation is done
	double Ih;	// Integration height in pixels over which the calculation is done
	double Ia;	// Integration angle in degree over which the calculation is done
	Rectangle rct;
	int nBins=100;
	//static boolean doNormalize = true;
	static boolean useCalibration = false;
	static boolean integrateHeight = true;
//	PlotWindow pw;
	MultyPlotExt plot;
	TextField t1 = new TextField( "" );
	TextField t2 = new TextField( "" );
	CheckboxGroup cbg = new CheckboxGroup();
	Checkbox cb1 = new Checkbox("height:", cbg, integrateHeight);
	Checkbox cb2 = new Checkbox("angle:", cbg, !integrateHeight);


	public int setup(String arg, ImagePlus imp) {
		this.imp = imp;
		return DOES_ALL+NO_UNDO+ROI_REQUIRED;
	}

	public void run(ImageProcessor ip) {
		setXYcenter();
		IJ.makeOval((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR));
		doDialog();
//		IJ.makeOval((int)(X0-mR), (int)(Y0-mR), (int)(2*mR), (int)(2*mR));
		imp.startTiming();
		if (canceled) return;
		doRadialDistribution(ip);
	}
	
	private void setXYcenter() {
		rct = imp.getRoi().getBoundingRect();
		X0 = (double) rct.x + (double) rct.width / 2;
		Y0 = (double) rct.y + (double) rct.height / 2;
		mR = (rct.width + rct.height) / 4.0;
		Ih = mR;
		Ia = 90;
	}

	private void doRadialDistribution(ImageProcessor ip) {
	        String[] headings = new String[2];
		int i;
		double a, b;
		nBins = (int) (3*mR/4);
		int thisBin;
		float[][] Accumulator = new float[2][nBins];
		double R;
		double xmin = X0 - mR, xmax, ymin, ymax;
//		double xmin = X0 - mR, xmax = X0 + mR, ymin = Y0 - Ih, ymax = Y0 + Ih;
//		double xmin = X0 - mR, xmax = X0 + mR, ymin = Y0 - mR, ymax = Y0 + mR;
//		for (a = xmin; a <= xmax; a++) {
		for (a = xmin; a <= X0; a++) {
			if(integrateHeight) {
				ymin = Y0 - Ih; ymax = Y0 + Ih;
				for (b = ymin; b <= ymax; b++) {
					R = Math.sqrt((a - X0) * (a - X0) + (b - Y0) * (b - Y0));
					thisBin = (int) Math.floor((R/mR) * (double) nBins);
					if (thisBin == 0) thisBin = 1;
					thisBin = thisBin - 1;
					if (thisBin > nBins - 1) thisBin = nBins - 1;
					Accumulator[0][thisBin] = Accumulator[0][thisBin] + 1;
					Accumulator[1][thisBin] = Accumulator[1][thisBin] + ip.getPixelValue((int) a, (int) b);
				}
			}
			else {
				ymin = Y0 - mR; ymax = Y0 + mR;
				for (b = ymin; b <= ymax; b++) {
					R = Math.sqrt((a - X0) * (a - X0) + (b - Y0) * (b - Y0));
					if( (Math.abs(b - Y0) / R) <= Math.sin(Ia * Math.PI / 180)) {
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
			for (i=0; i<nBins;i++) {
				Accumulator[1][i] =  Accumulator[1][i] / Accumulator[0][i];
				Accumulator[0][i] = (float) (cal.pixelWidth*mR*((double)(i + 1) / nBins));
			}
//			pw = new PlotWindow("Radial Profile Plot", "Radius ["+cal.getUnits()+"]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			plot = new MultyPlotExt("Radial Profile Plot", "Radius ["+cal.getUnits()+"]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			headings[0] = "Radius ["+cal.getUnits()+"]";
		} else {
			for (i=0; i<nBins;i++) {
				Accumulator[1][i] = Accumulator[1][i] / Accumulator[0][i];
				Accumulator[0][i] = (float) (mR * ((double) (i + 1) / nBins));
			}
//			pw = new PlotWindow("Radial Profile Plot", "Radius [pixels]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			plot = new MultyPlotExt("Radial Profile Plot", "Radius [pixels]", "Normalized Integrated Intensity",  Accumulator[0], Accumulator[1]);
			headings[0] = "Radius [pixels]";
		}
//		pw.draw();
		headings[1] = "Normalized Integrated Intensity";
	        MultyPlotWindowExt wnd = plot.show();
        	wnd.setLineHeadings(headings, false);
	}

	private void doDialog() {
		canceled=false;
		GenericDialog gd = new GenericDialog("Radial Profile Height...", IJ.getInstance());
		gd.addNumericField("X center (pixels):", X0, 2);
		gd.addNumericField("Y center (pixels):", Y0, 2);
		gd.addNumericField("Radius (pixels):", mR, 2);
		t1.setText(""+Ih);
		t2.setText(""+Ia);
		gd.addPanel(makePanel());

		//gd.addCheckbox("Normalize", doNormalize);
		gd.addCheckbox("Use Spatial Calibration", useCalibration);
		gd.showDialog();
		if (gd.wasCanceled()) {
			canceled = true;
			return;
		}
		X0=gd.getNextNumber();
		Y0=gd.getNextNumber();
		mR=gd.getNextNumber();
		Ih=Double.valueOf(t1.getText()).doubleValue();
		Ia=Double.valueOf(t2.getText()).doubleValue();
		integrateHeight	= cb1.getState();
		//doNormalize = gd.getNextBoolean();
		useCalibration = gd.getNextBoolean();
		if(gd.invalidNumber()) {
			IJ.showMessage("Error", "Invalid input Number");
			canceled=true;
			return;
		}
	}

	private Panel makePanel() {
		Panel panel = new Panel();
		panel.setLayout(new GridLayout(2, 3));

		panel.add( cb1 );
		panel.add( t1 );
		panel.add( new Label(" (pixels)") );

		panel.add( cb2 );
		panel.add( t2 );
		panel.add( new Label(" (degree)") );

		return panel;
	}

}
