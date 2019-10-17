requires("1.48h");
imHeight=getHeight();
imWidth=getWidth();
//rtype = Roi.getType();
imName=getTitle();
origID=getImageID();
dWidth=1;

if(selectionType() ==10)
{
	Roi.getCoordinates(xpoints, ypoints);
	
	Dialog.create("Analysis parameters");
	Dialog.addMessage("OrientationJ parameters");
	Dialog.addNumber("Gaussian window (sigma, line width):", 1) 
	items=newArray("Cubic Spline Gradient","Finite Difference Gradient","Fourier Gradient","Riesz Filters","Gaussian Gradient","Finite Difference Hessian");
	Dialog.addChoice("Map calculation method:", items);
	Dialog.show();
	dWidth=Dialog.getNumber();	
	dMethod=Dialog.getChoice();
	dMethodN=0;
	if(startsWith(dMethod,"Cubic Spline Gradien"))
		dMethodN=0;
	if(startsWith(dMethod,"Finite Difference Gradien"))
		dMethodN=1;
	if(startsWith(dMethod,"Fourier Gradien"))
		dMethodN=2;
	if(startsWith(dMethod,"Riesz Filter"))
		dMethodN=3;
	if(startsWith(dMethod,"Gaussian Gradien"))
		dMethodN=4;
	if(startsWith(dMethod,"Finite Difference Hessia"))
		dMethodN=5;
	runstring="log=0.0 tensor="+toString(dWidth)+" gradient="+toString(dMethodN)+" harris-index=on color-survey=off s-distribution=off orientation=on hue=Gradient-X sat=Gradient-X bri=Gradient-X radian=on";
	//run("OrientationJ Analysis", "log=0.0 tensor=5.0 gradient=0 harris-index=on color-survey=off s-distribution=off orientation=on hue=Gradient-X sat=Gradient-X bri=Gradient-X ");
	run("OrientationJ Analysis",runstring);
	rename(imName+"_orientantion_map_width="+toString(dWidth));
	
	centx=xpoints[0];	
	centy=ypoints[0];	
	//IJ.log(toString(centx));
	//IJ.log(toString(centy));
	
	
	//convert to radians
	/*
	for(i=0;i<imWidth;i++)
		for(j=0;j<imHeight;j++)
		{
				val=getPixel(i,j)*PI/180;
				setPixel(i,j,val);
		}
    */
	orientmapID=getImageID();
	run("Enhance Contrast", "saturated=0.35");
	//polarity map
	run("Duplicate...", "title=["+imName+"_radiality_map_width="+toString(dWidth)+"]");
	for(i=0;i<imWidth;i++)
		for(j=0;j<imHeight;j++)
		{
			val=getPixel(i,j);
			//dl=sqrt(px*px+py*py);
			vx=i-centx;
			vy=centy-j;		
			vangle=atan(vy/vx);
			newval=abs(cos(vangle-val));
			setPixel(i,j,newval);		
		}
	run("Enhance Contrast", "saturated=0.35");
	polaritymapID=getImageID();
	polarityTitle=getTitle();
	
	imageCalculator("Multiply create 32-bit", imName,polarityTitle);
	rename(imName+"_mult_radiality_map_width="+toString(dWidth));
	run("Fire");
	
	selectImage(orientmapID);
	
	run("Enhance Contrast", "saturated=0.35");
	//polarity map
	run("Duplicate...", "title=["+imName+"_nonradiality_map_width="+toString(dWidth)+"]");
	for(i=0;i<imWidth;i++)
		for(j=0;j<imHeight;j++)
		{
			val=getPixel(i,j);
			//dl=sqrt(px*px+py*py);
			vx=i-centx;
			vy=centy-j;		
			vangle=atan(vy/vx);
			newval=1-abs(cos(vangle-val));
			setPixel(i,j,newval);
			
			
		}
	run("Enhance Contrast", "saturated=0.35");
	nonpolaritymapID=getImageID();
	nonpolarityTitle=getTitle();
	
	imageCalculator("Multiply create 32-bit", imName,nonpolarityTitle);
	rename(imName+"_mult_nonradiality_map_width="+toString(dWidth));
	run("Fire");


}
else
{
	exit("Need to choose a point ROI first");
}
