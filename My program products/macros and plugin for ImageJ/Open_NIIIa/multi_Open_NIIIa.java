import java.io.*;
import javax.swing.*;//added by lyxin
import javax.swing.filechooser.*;//added by lyxin, for multiple file selection and open
import java.util.*;
import java.awt.*;

import ij.*;
import ij.plugin.*;
import ij.process.*;
import ij.io.*;
import ij.measure.*;
//Jim Hull, The University of Washington Chemical Engineering
//Authored 01/04

//**** Nanoscope IIIa raw image format by lyxin, Peking University, Beijing, China.
//****
//2007.4.13
//Add function: open mutilple files
//Using: javax.swing.jfilechooser
//****
//****
//2006.11.15
// (double)zScan:       \@Sens. Zscan: V 11.79711 nm/V
// (String)frDirection: \Frame direction: Down
// (string)lnDirection: \Line direction: Trace
// (double)zMagnify:    \@Z magnify: C [2:Z scale] 3.265289 
// (double)zScale:      \@2:Z scale: V [Sens. Zscan] (0.006713765 V/LSB) 1.557593 V
//**** Obtain User z range
// (double)zUser=zScan*zScale*zMagnify (nm)
//**** Gray scale calibration
// function: STRAIGHT_LINE(0) z=p[0]+p[1]*grayValue
// Coefficients: p[0]=0
//               p[1]=zScan*zScale/65536
//****
public class multi_Open_NIIIa implements PlugIn {

	FileInfo nFileInfo;
	FileOpener nFileOpener;
	ImagePlus nImage;
	ImageProcessor nProc;
	Calibration nCal;
	private int bufferCount=0;
	private int fileCount=0;//added by lyxin; for counting file number
	
	String buf;

	BufferedReader fileInputStream;
	File file;

	private double[] nIIIProps = new double[3];
	private double[][] buffProps = new double[5][3];
	private int colonIndex, unitSkip;
	//****by lyxin 2006-11-15
	private int ptsIndex; //Right paretheses index for CIAO parameters(Z scale)
	private int bracketIndex; //Right paretheses index for CIAO parameters(Z magnify)
	private String frDirection;
	private String lnDirection;
	private double zScan;
	private double zScale;
	private double zMagnify;
	private double zUser;
  //****
  //****by lyxin 2007.4.13
  static File dir;
  //****
	public void run(String arg) {

		//IJ.log("Entering Plugin");
		/*if (arg.equals("")) {
			OpenDialog od = new OpenDialog("Open NIII...","F:\\lyx\\data\\AFM","");
			String fileName = od.getFileName();

			if (fileName==null)
				return;

			String directory = od.getDirectory();
	        IJ.showStatus("Opening: " + directory + fileName);
	        file = new File(directory+fileName);
		}
		else {
			file = new File(arg);
		}*/
		// Above by Jim Hull, commented by lyxin
		
		//****by lyxin 2007.4.13 copied from File_opener.java by Wayne Rasband
		JFileChooser fc = null;
		try {fc = new JFileChooser();}
		catch (Throwable e) {IJ.error("This plugin requires Java 2 or Swing."); return;}
		fc.setMultiSelectionEnabled(true);
		if (dir==null) {
			String sdir = OpenDialog.getDefaultDirectory();
			if (sdir!=null)
				dir = new File(sdir);
		}
		if (dir!=null)
			fc.setCurrentDirectory(dir);
		int returnVal = fc.showOpenDialog(IJ.getInstance());
		if (returnVal!=JFileChooser.APPROVE_OPTION)
			return;
		File[] files = fc.getSelectedFiles();
		if (files.length==0) { // getSelectedFiles does not work on some JVMs
			files = new File[1];
			files[0] = fc.getSelectedFile();
		}
		String path = fc.getCurrentDirectory().getPath()+Prefs.getFileSeparator();
		dir = fc.getCurrentDirectory();
		//****

		//Open all selected files
		for (int i=0; i<files.length; i++) {
			file = new File(path+files[i].getName());
			openNIIIa(file);
		}
		
		//IJ.register(multi_Open_NIIIa .class); //added by lyxin 2007.4.13
	}	//end run


	public void openNIIIa(File fileName) {
		//IJ.log("Entering openStp");

		//int buffers=0;
		bufferCount=0; //added by lyxin. Clear bufferCount for every file
		fileCount++;
		
		double[] fileProps = new double[10];
		double[][] bufferProps = new double[10][5];

		//Create the file input stream
   		try {
			fileInputStream = new BufferedReader( new FileReader(fileName));
			IJ.showStatus("Opening Buffered Reader");
		}
		catch (FileNotFoundException exception) {
			IJ.showStatus("Buffered Reader Exception");
		}

		//Read the Header
		readHeader(fileInputStream);

		//Close the input stream
		try {
			fileInputStream.close();
			IJ.showStatus("Closing Buffered Reader");
		}
		catch (IOException exception) {
			IJ.showStatus("Buffered Reader Exception");
		}

		//Set up the images
		for(int i=0;i<bufferCount;i++) {

      //****code below added by lyxin
      double[] coef = new double[2]; //for nFileInfo.coefficients
			coef[0]=0;
			coef[1]=zScan*zScale/65536;
			if(i==0){
				zUser=zScan*zScale*zMagnify;
				IJ.log("User z range"+new Double(zUser).toString()+" nm");
			}
      //****
			//Set Parameters and open each buffer
			nFileInfo = new FileInfo();
			nFileInfo.fileType = nFileInfo.GRAY16_SIGNED;
			nFileInfo.fileName = fileName.toString();
			nFileInfo.width = (int)nIIIProps[1];
			nFileInfo.height = (int)nIIIProps[1];
			nFileInfo.offset = (int)buffProps[0][i];
			nFileInfo.intelByteOrder = true;
			//****code below added by lyxin
			nFileInfo.pixelWidth = nIIIProps[2]/nIIIProps[1];
			nFileInfo.pixelHeight = nIIIProps[2]/nIIIProps[1];
			nFileInfo.unit = "nm";
			nFileInfo.calibrationFunction = 0; //Straight Line function
			nFileInfo.coefficients = coef;
			nFileInfo.valueUnit="nm";
			//****
			
			//Open the Image
			nFileOpener = new FileOpener(nFileInfo);
			nImage = nFileOpener.open(true);


		}	//end for
	}	//end openNIII


	public void readHeader(BufferedReader in) {


		//Scan through header for file info
		for(int line = 0 ; line<290 ; line++) {
			//IJ.log("buffer count "+new Integer(bufferCount).toString());
			try {
				buf = new String(in.readLine());}
			catch (IOException exception) {
				IJ.showStatus("IO Exception");
			}

			buf=buf.substring(1);
			//IJ.log(buf);
			colonIndex=buf.indexOf(":");
			//IJ.log(new Integer(colonIndex).toString());
			ptsIndex=buf.indexOf(")"); 
			//IJ.log(new Integer(ptsIndex).toString());
			bracketIndex=buf.indexOf("]"); 
			//IJ.log(new Integer(bracketIndex).toString());
			unitSkip=buf.length()-2;
			//IJ.log(new Integer(unitSkip).toString());

			//Get the buffer info
			//Get the header size
			if (buf.startsWith("Data length:") && bufferCount==0) {
				//IJ.log(new Double(buf.substring(colonIndex+1).trim()).toString());
				nIIIProps[0] = new Double(buf.substring(colonIndex+1).trim()).doubleValue();
				IJ.log("****	"+new Integer(fileCount).toString()+" - "+new Integer(bufferCount).toString()+"	****");
				IJ.log("Header Length "+new Integer((int)nIIIProps[0]).toString());
				//bufferCount++;
				continue;
			}

			//Get the number if pixels
			if (buf.startsWith("Lines:") && bufferCount==0) {
				nIIIProps[1] = new Double(buf.substring(colonIndex+1).trim()).doubleValue();
				IJ.log("Pixels "+new Integer((int)nIIIProps[1]).toString());
				continue;
			}

			if (buf.startsWith("Scan size:") && bufferCount==0 ) {
				nIIIProps[2] = new Double(buf.substring(colonIndex+1,unitSkip).trim()).doubleValue();
				IJ.log("Scan Size "+new Double(nIIIProps[2]).toString());
				continue;
			}
			
			//***** Code below is added by lyxin 2006-11-15,2006-11-16
			//Get Frame Direction
			if (buf.startsWith("Frame direction:") && bufferCount==1 ) {
				frDirection = new String(buf.substring(colonIndex+1).trim());
				IJ.log("Frame Direction "+frDirection);
				continue;
			}
			//Get Line Direction
			if (buf.startsWith("Line direction:") && bufferCount==1 ) {
				lnDirection = new String(buf.substring(colonIndex+1).trim());
				IJ.log("Line Direction "+lnDirection);
				continue;
			}
			//Get Sens. Zscan
			if (buf.startsWith("@Sens. Zscan:") && bufferCount==0 ) {
				zScan = new Double(buf.substring(colonIndex+3,unitSkip-2).trim()).doubleValue();
				IJ.log("Sens. Zscan "+new Double(zScan).toString());
				continue;
			}
			//Get the Z magnify
			if (buf.startsWith("@Z magnify:") && bufferCount==1) {
				zMagnify=new Double(buf.substring(bracketIndex+1).trim()).doubleValue();
				IJ.log("Z magnify "+new Double(zMagnify).toString());
				continue;
			}
			//Get Z scale
			if (buf.startsWith("@2:Z scale:") && bufferCount==1) {
				zScale = new Double(buf.substring(ptsIndex+1,unitSkip+1).trim()).doubleValue();
				IJ.log("Z scale "+new Double(zScale).toString());
				continue;
			}
			//*****

			//Get the image size and offset
			if (buf.startsWith("Data offset:")) {
				buffProps[0][bufferCount] = new Integer(buf.substring(colonIndex+1).trim()).intValue();
				bufferCount+=1;
				IJ.log("Image Offset "+new Integer((int)buffProps[0][bufferCount-1]).toString());
				continue;
			}
			if (buf.startsWith("Data length:") && bufferCount>0) {
				buffProps[1][bufferCount-1] = new Integer(buf.substring(colonIndex+1).trim()).intValue();
				IJ.log("Image Sizez "+new Integer((int)buffProps[1][bufferCount-1]).toString());
				//bufferCount++;
				continue;
			}

			if (buf.endsWith("File list end")) {break;}

		}	//end for

	}	//end readHeader


}	//end class
