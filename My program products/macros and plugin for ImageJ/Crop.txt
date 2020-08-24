//Crop
//2006-10-20
//Duplicate a selection(roi) of an image and save it to a file or a stack.
//  The selection is specified as 5 typess, flat, bear-scan, bear-hist, sect-ana, sect-img.
//  The meaning of these types is as follows:
//      (1)flat: the image box of an flattened AFM image exported from Nanoscope software.
//      (2)bear-scan: the image box of an bearing AFM image.
//      (3)bear-hist: the histogram box of an bearing AFM image.
//      (4)sect-ana: the analysis box of an sectional AFM image.    
//      (5)sect-img: the image box of an sectional AFM image.
//2006-11-10
//   Add 2 new types, height, phase.
//      (6)height: the left image box of an original view exported from Nanoscope software
//      (7)phase: the right image box of an original view.


setBatchMode(true);
var ioPath="F:\\lyx\\ImageJ\\job\\";
var saveAsFiles=true;
var saveAsStack=false;
var jobModeItems=newArray("flat","bear-scan","bear-hist","sect-ana","sect-img","height","phase");
var jobMode="flat";
var roix=0;
var roiy=0;
var roiw=0;
var roih=0;

getSettings();
flist=getFileList(ioPath);
sortFileList(flist);//sort file list. The order is from a to z, 0 to 9.
flen=flist.length-1;
assignJobMode();
for(i=0;i<flen;i++)
{
	showProgress(i/flen);
	if(flist[i]!="thumbs.db")
	{
		open(ioPath+flist[i]);
		makeRectangle(roix,roiy,roiw,roih);
		run("Crop");
		fname=replace(flist[i],".tif","");
		if(saveAsFiles) saveAs("tiff",ioPath+fname+"-"+jobMode+".tif");
	}
}
if(saveAsStack) 
{
	run("Convert Images to Stack");
	ffirst=replace(flist[0],".tif","");
	flast=replace(flist[flen-1],".tif","");
	run("Save", "save="+ioPath+ffirst+"-"+flast+"-"+jobMode+".tif");
}
closeAll();
setBatchMode(false);

/////////////////////////////
//
//FUNCTION STARTS FROM HERE!
//
/////////////////////////////
function getSettings()
{
	Dialog.create("Configure Settings");
	Dialog.addString("The path to open/save images:",ioPath);
	Dialog.addCheckbox("Save as files",saveAsFiles);
	Dialog.addCheckbox("Save as stack",saveAsStack);
	Dialog.addChoice("Please choose the crop mode:",jobModeItems);
	Dialog.show();
	ioPath=Dialog.getString();
	saveAsFiles=Dialog.getCheckbox();
	saveAsStack=Dialog.getCheckbox();
	jobMode=Dialog.getChoice();
}
function sortFileList(a) 
{
	quickSort(a, 0, lengthOf(a)-1);
}
function quickSort(a, from, to) 
{
	i = from; j = to;
  center = a[(from+to)/2];
  do 
  {
  	while (i<to && center>a[i]) i++;
    while (j>from && center<a[j]) j--;
    if (i<j) {temp=a[i]; a[i]=a[j]; a[j]=temp;}
    if (i<=j) {i++; j--;}
  }while(i<=j);
  if (from<j) quickSort(a, from, j);
  if (i<to) quickSort(a, i, to);
}
function assignJobMode()
{
	if(jobMode=="flat")
		{roix=48;roiy=81;roiw=512;roih=512;}
	else if(jobMode=="bear-scan")
		{roix=3;roiy=27;roiw=256;roih=256;}
	else if(jobMode=="bear-hist")
		{roix=370;roiy=128;roiw=325;roih=550;}
	else if(jobMode=="sect-ana")
		{roix=29;roiy=75;roiw=514;roih=258;}
	else if(jobMode=="sect-img")
		{roix=30;roiy=430;roiw=256;roih=256;}
	else if(jobMode=="height")
		{roix=0;roiy=56;roiw=512;roih=512;}
	else if(jobMode=="phase")
		{roix=512;roiy=56;roiw=512;roih=512;}
	else
		showMessage("Warning", "An error occur when assign job mode!");
}
function closeAll() 
{
	requires("1.30e");
  if (isOpen("Results")) 
  {
  	selectWindow("Results"); 
    run("Close" );
  }
  if (isOpen("Log")) 
  {
    selectWindow("Log");
    run("Close" );
  }
  while (nImages()>0) 
  {
    selectImage(nImages());  
    run("Close");
  }
}