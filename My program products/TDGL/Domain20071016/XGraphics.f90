!_______________________________________________________________________
!
! XGraphic for visualizing the 2D-lattice data obtained from simulation
! Author: Liu Yi-Xin
! Date: 2007.8.7 - 
! ______________________________________________________________________
!  
! Modify record:
!   
!_______________________________________________________________________
!
!===================================================================================!
! Subroutines
!
! %%%%%%%%%%% graphicsmode %%%%%%%%%%%
! Initialization: set monitor at best resolution graphics mode
subroutine graphicsmode( )
use dflib
implicit none
logical statusmode
type (windowconfig) myscreen
common myscreen
! Set highest resolution graphics mode.
myscreen.numxpixels=-1
myscreen.numypixels=-1
myscreen.numtextcols=-1
myscreen.numtextrows=-1
myscreen.numcolors=-1
myscreen.fontsize=-1
myscreen.title = " "C ! blank
!
statusmode=setwindowconfig(myscreen)
if(.NOT. statusmode) statusmode = setwindowconfig(myscreen)
!
statusmode = getwindowconfig(myscreen)
!
call clearscreen($GCLEARSCREEN)
end subroutine
!
! %%%%%%%%%%%%%% drawscreen %%%%%%%%%%%%%%
! framework of screen
subroutine drawscreen(c,n1,n2,time,lut,issavegraph,filename)
use dflib
implicit none
! (in) parameter
integer n1,n2
real*8, dimension(1:n1,1:n2) ::c
real*8 time
logical issavegraph
character(*) filename
! general variables
! graph
integer(2) status
integer(2) xwidth, yheight, cols, rows
integer(2) ux,uy,lx,ly
integer(2) hprofile,htext
integer(4) rgb,red,green,blue,oldrgb,rgbwhite
integer, dimension(1:n1,1:n2)::cgraph
integer lut(0:255)
integer(4) res
logical statusmode
type (windowconfig)  myscreen
common myscreen
! text
character(128) text
type (rccoord) txtpos
!
!call clearscreen($GVIEWPORT)
xwidth  = myscreen.numxpixels
yheight = myscreen.numypixels
cols    = myscreen.numtextcols
rows    = myscreen.numtextrows
! graph window /left part of screen/
call setviewport(int2(30),int2(30),n1-1+60,yheight-1)
call settextwindow(int2(1),int2(1),rows-1,(60+n1)*cols/xwidth)
write(text,"(A,F10.3)") "elapse time ",time
txtpos.row=(30+n2)*rows/yheight+3
txtpos.col=30*cols/xwidth+1
call drawtext(txtpos,#FFFFFF,text)
write(text,"(A,F)") "<c>",sum(c)/n1/n2
txtpos.row=txtpos.row+1
call drawtext(txtpos,#FFFFFF,text)
call constructgraph(c,n1,n2,0.0_8,1.0_8,lut,cgraph)
call drawgraph(cgraph,n1,n2,issavegraph,filename)
oldrgb=setcolorrgb(#00FFFF) !yellow
status=rectangle($GBORDER,int2(0),int2(0),n1+1,n2+1) !draw boundary rect
! calc profile height and text height
htext=3*yheight/rows
hprofile=yheight/3-htext-20
! x direction profile window /upper right part of screen/
ux=n1-1+60
uy=30
lx=xwidth-60
ly=hprofile+30
call setviewport(ux,uy,lx,ly)
call clearscreen($GVIEWPORT)
call setwindow(.TRUE.,1.0_8,0.0_8,dble(n1),1.0_8)
call drawxprofile(c,n1,n2,n2/2) ! middle
oldrgb=setcolorrgb(#00FFFF) !yellow
status=rectangle_w($GBORDER,1.0_8,0.0_8,dble(n1),1.0_8)
call settextwindow(int2(1),int2(1),rows-1,cols-1)
txtpos.row=ly*1.0*rows/yheight+2
txtpos.col=(ux+lx)*0.5*cols/xwidth-12
call drawtext(txtpos,#FFFFFF,"x direction porfile (1/2)")
! y direction profile window /middle right part of screen/
uy=ly+htext
ly=uy+hprofile
call setviewport(ux,uy,lx,ly)
call clearscreen($GVIEWPORT)
call setwindow(.TRUE.,1.0_8,0.0_8,dble(n2),1.0_8)
call drawyprofile(c,n1,n2,n1/2) ! middle
oldrgb=setcolorrgb(#00FFFF) !yellow
status=rectangle_w($GBORDER,1.0_8,0.0_8,dble(n2),1.0_8)
call settextwindow(int2(1),int2(1),rows-1,cols-1)
txtpos.row=ly*1.0*rows/yheight+2
txtpos.col=(ux+lx)*0.5*cols/xwidth-12
call drawtext(txtpos,#FFFFFF,"y direction porfile (1/2)")
! arbitrary direction profile window /lower right part of screen/
uy=ly+htext
ly=uy+hprofile
call setviewport(ux,uy,lx,ly)
call clearscreen($GVIEWPORT)
call setwindow(.TRUE.,1.0_8,0.0_8,dble(sqrt(n1*n1*1.0+n2*n2*1.0)),1.0_8)
call drawlineprofile(c,n1,n2,1,1,n1,n2) ! the diagonal line section from up-left to low-right
oldrgb=setcolorrgb(#00FFFF) !yellow
status=rectangle_w($GBORDER,1.0_8,0.0_8,dble(sqrt(n1*n1*1.0+n2*n2*1.0)),1.0_8)
call settextwindow(int2(1),int2(1),rows-1,cols-1)
txtpos.row=ly*1.0*rows/yheight+3
txtpos.col=(ux+lx)*0.5*cols/xwidth-26
call drawtext(txtpos,#FFFFFF,"up-left to low-right diagonal line direction profile")
end subroutine
!
! %%%%%%%%%%%%%% drawtext %%%%%%%%%%%%%
! Output text words at specified position 
! and using specified color in RGB mode
subroutine drawtext(txtpos,rgb,text)
use dflib
implicit none
! (in) parameters
type (rccoord) txtpos,curpos
integer(4) rgb,oldrgb
character(*) text
!
call settextposition(txtpos.row,txtpos.col,curpos)
oldrgb=settextcolorrgb(rgb)
call outtext(text)
end subroutine
!
! %%%%%%%%%%% constructgraph %%%%%%%%%%%%
! Construct graph cgraph from c
! cgraph is a one-dimesion array whose elements are the RGB color in integer mode
! if c(1:n1,1:n2) then cgraph(1:n1,1:n2).
subroutine constructgraph(c,n1,n2,cmin,cmax,lut,cgraph)
use dflib
implicit none
! (in) parameters
integer n1,n2
real*8, dimension(1:n1,1:n2) ::c
real*8 cmin ! the low limit of c value
real*8 cmax ! the up limit of c value -------- the cmin and cmax set the range 
                                   !-------- for color converting (cmin,cmax) <=> (0,255)
integer lut(0:255) ! 256 index color lookup table
! (out) parameters
integer, dimension(1:n1,1:n2) ::cgraph
! graph
integer colorindex ! 0 ~ 255 for lut
! general var
integer i,j ! iteration var
!
do j=1,n2
	do i=1,n1
		!colorindex=int4((c(i,j)-min(c))/(c(i,j)+max(c)))*255.0) !expand c to full range scale
		!colorindex=int4((c(i,j)-cmin)/(cmax-cmin)*255.0) ! assume the experimental c ranges from cmin to cmax
		!colorindex=int4(c(i,j)*255.0) !assume c ranges from 0.0 to 1.0
		!colorindex=int4((c(i,j)+0.5)*255.0) ! assume c ranges from -0.5 to 0.5
		colorindex=int4((c(i,j)-cmin)/(cmax-cmin)*255.0)
		if(colorindex>255) colorindex=255
		if(colorindex<0) colorindex=0
		cgraph(i,j)=lut(colorindex)
	end do
end do
end subroutine 
!
! %%%%%%%%%%%%%% drawgraph %%%%%%%%%%%%%
! Construct and show 2D lattice image from array c(1:n1,1:n2)
! Planned feature: show grayscale image 
! as a pseudo-color image via using LUT (lookup table)
subroutine drawgraph(cgraph,n1,n2,issavegraph,filename)
use dflib
implicit none
! (in) parameter
integer n1,n2
integer, dimension(1:n1,1:n2) ::cgraph
logical issavegraph
character(*) filename
! general variables
integer(2) i,j
! graph
integer(2) ::bx(n1*n2),by(n1*n2)
integer(4) ::cgraph2draw(n1*n2),bn
integer(4) res
!
bn=1
do j=1,n2
	do i=1,n1
		bx(bn)=i
		by(bn)=j
		cgraph2draw(bn)=cgraph(i,j)
		bn=bn+1
	end do	
end do
call setpixelsrgb(bn-1,bx,by,cgraph2draw)
! save graph
if(issavegraph) res=saveimage(filename,1,1,n1,n2)
end subroutine
!
! %%%%%%%%%%% drawxprofile %%%%%%%%%%%%
! Profile the 2D-image at x direction 
! with line through point (0,ypos)
subroutine drawxprofile(c,n1,n2,ypos)
use dflib
implicit none
! (in) parameters
integer n1,n2
real*8, dimension(1:n1,1:n2) ::c
integer ypos
! general var
integer i
! profile
type (wxycoord) wxy
integer(2) status
integer(4) oldrgb
! 
oldrgb=setcolorrgb(#00FF00) ! full green
call moveto_w(1.0_8,dble(c(1,ypos)),wxy)
do i=1,n1
	status=lineto_w(dble(i),dble(c(i,ypos)))
end do
end subroutine
!
! %%%%%%%%%%%%% drawyprofile %%%%%%%%%%%%%%
! Profile the 2D-image at y direction 
! with line through point (xpos,0)
subroutine drawyprofile(c,n1,n2,xpos)
use dflib
implicit none
! (in) parameters
integer n1,n2
real*8, dimension(1:n1,1:n2) ::c
integer xpos
! general var
integer i
! profile
type (wxycoord) wxy
integer(2) status
integer(4) oldrgb
! 
oldrgb=setcolorrgb(#00FF00) ! full green
call moveto_w(1.0_8,dble(c(xpos,1)),wxy)
do i=1,n2
	status=lineto_w(dble(i),dble(c(xpos,i)))
end do
end subroutine
!
! %%%%%%%%%%%%% drawlineprofile %%%%%%%%%%%%%
! Profile the 2D-image at arbitrary direction 
! with line through point (x1,y1) and (x2,y2)
subroutine drawlineprofile(c,n1,n2,x1,y1,x2,y2)
use dflib
implicit none
! (in) parameters
integer n1,n2
real*8, dimension(1:n1,1:n2) ::c
integer x1,x2,y1,y2,tmp
! general var
integer i
! profile
type (wxycoord) wxy
integer(2) status
integer(4) oldrgb
!
if(x1>x2) then
	call exchange(x1,x2)
	call exchange(y1,y2)
end if
if(x1==x2) then
	call drawyprofile(c,n1,n2,x1)
else if(y1==y2) then
	call drawxprofile(c,n1,n2,y1)
else
	oldrgb=setcolorrgb(#00FF00) ! full green
	call moveto_w(dble(x1),dble(c(x1,y1)),wxy)
	do i=x1,x2
		tmp=anint((y2*1.0-y1*1.0)*(i*1.0-x1*1.0)/(x2*1.0-x1*1.0)+y1*1.0) ! calc ypos on line
		status=lineto_w(dble(sqrt((i-x1)*(i-x1)*1.0+(tmp-y1)*(tmp-y1)*1.0)),dble(c(i,tmp)))
	end do
end if
end subroutine
!
! %%%%%%%%%%%%% drawcurve %%%%%%%%%%%%%
! Plot (x,y) curve on the middle of screen and label coordinates
subroutine drawcurve(x,y,np,xmin,ymin,xmax,ymax)
use dflib
implicit none
! (in) parameters
integer np ! number of points to be ploted
real*8 ::x(np) !x coordinate
real*8 ::y(np) !y coordinate
real*8 ::xmin,ymin,xmax,ymax
! general var
integer i
! graphics
logical statusmode
type (windowconfig)  myscreen
common myscreen
integer(2) xwidth,yheight,cols,rows
! curve
type (wxycoord) wxy
integer(2) status
integer(4) oldrgb
character(32) label
! text
integer(2) textxp,textyp ! one char's x and y length in pixel unit
type (rccoord) txtpos
!
xwidth  = myscreen.numxpixels
yheight = myscreen.numypixels
cols    = myscreen.numtextcols
rows    = myscreen.numtextrows
textxp=xwidth/cols
textyp=yheight/rows
!
call clearscreen($GCLEARSCREEN)
call setviewport(textxp*10,yheight/3,xwidth-textxp*5,yheight*2/3)
call setwindow(.TRUE.,xmin,ymin,xmax,ymax)
! draw frame
oldrgb=setcolorrgb(#00FFFF) !yellow
status=rectangle_w($GBORDER,xmin,ymin,xmax,ymax)
call moveto_w(xmin,(ymin+ymax)/2.0,wxy)
status=lineto_w(xmax,(ymin+ymax)/2.0)
! draw curve
oldrgb=setcolorrgb(#00FF00) ! full green
call moveto_w(x(1),y(1),wxy)
do i=2,np
	status=lineto_w(x(i),y(i))
end do
end subroutine