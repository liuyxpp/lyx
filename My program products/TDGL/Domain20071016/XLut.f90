!_______________________________________________________________________
!
! XLut for generating index color from lookup tables
! Author: Liu Yi-Xin
! Date: 2007.8.13 - 
! ______________________________________________________________________
!  
! Modify record:
!   
!_______________________________________________________________________
!
!===================================================================================!
! external subroutines and functions
!
! %%%%%%%%%% generategrayscale %%%%%%%%%%%
! Generating gray scale lut
subroutine generategrayscale(lut)
use dflib
implicit none
! (out) parameter
integer lut(0:255)
! general var
integer i
!
do i=0,255
	lut(i)=rgbtointeger(i,i,i)
end do
end subroutine
!
! %%%%%%%%%%% generatenamedlut(lutname)
! Generating lut from lut name
! Name list: 
!            blue, cyan, fire, gray, green, ice, magenta, red, 
!            redgreen, spectrum, yellow, 332rgb
subroutine generatenamedlut(lutname,lut)
implicit none
! (in) parameter
character(*) lutname
! (out) parameter
integer lut(0:255)
!
if(lutname=="blue") then
	pause
else if(lutname=="cyan") then
	pause
else if(lutname=="fire") then
	call lut_fire(lut)
else if(lutname=="gray") then
	call generategrayscale(lut)
else if(lutname=="green") then
	pause
else if(lutname=="ice") then
	call lut_ice(lut)
else if(lutname=="magenta") then
	pause
else if(lutname=="red") then
	pause
else if(lutname=="redgreen") then
	call lut_redgreen(lut)
else if(lutname=="spectrum") then
	call lut_spectrum(lut)
else if(lutname=="yellow") then
	pause
else if(lutname=="332rgb") then
	call lut_332rgb(lut)
else
	call generategrayscale(lut)
end if
end subroutine
!
! %%%%%%%%%%% generatefilelut %%%%%%%%%%%%
! Generating lut from file
subroutine generatefilelut(lutfilename,lut)
implicit none
! (in) parameter
character lutfilename(256)
! (out) parameter
integer lut
!
! not implemetation yet
end subroutine
!===================================================================================!
! internal subroutines and functions
!
! &&&&&&&&&&& lut_fire &&&&&&&&&&
! Generating fire lut
subroutine lut_fire(lut)
use dflib
implicit none
! (in) parameter
integer lut(0:255)
! general
integer r(0:255),g(0:255),b(0:255)
!integer ::r=(/0,0,1,25,49,73,98,122,146,162,173,184,195,207,217,229,240,252,255,255,255,255,255,255,255,255,255,255,255,255,255,255/)
!integer ::g=(/0,0,0,0,0,0,0,0,0,0,0,0,0,14,35,57,79,101,117,133,147,161,175,190,205,219,234,248,255,255,255,255/)
!integer ::b=(/0,61,96,130,165,192,220,227,210,181,151,122,93,64,35,5,0,0,0,0,0,0,0,0,0,0,0,35,98,160,223,255/)
integer i
!
do i=0,255
	lut(i)=rgbtointeger(r(i),g(i),b(i))
end do
end subroutine
! 
! &&&&&&&&&&& lut_ice &&&&&&&&&&
! Generating ice lut
subroutine lut_ice(lut)
use dflib
implicit none
! (in) parameter
integer lut(0:255)
! general
integer r(0:255),g(0:255),b(0:255)
!integer ::r(0:255)=(/0,0,0,0,0,0,19,29,50,48,79,112,134,158,186,201,217,229,242,250,250,250,250,251,250,250,250,250,251,251,243,230/)
!integer ::g(0:255)=(/156,165,176,184,190,196,193,184,171,162,146,125,107,93,81,87,92,97,95,93,93,90,85,69,64,54,47,35,19,0,4,0/)
!integer ::b(0:255)=(/140,147,158,166,170,176,209,220,234,225,236,246,250,251,250,250,245,230,230,222,202,180,163,142,123,114,106,94,84,64,26,27/)
integer i
!
do i=0,255
	lut(i)=rgbtointeger(r(i),g(i),b(i))
end do
end subroutine
! 
! &&&&&&&&&&& lut_redgreen &&&&&&&&&&
! Generating redgreen lut
subroutine lut_redgreen(lut)
use dflib
implicit none
! (in) parameter
integer lut(0:255)
! general
integer i
!
do i=0,127
	lut(i)=rgbtointeger(i*2,0,0)
end do
do i=128,255
	lut(i)=rgbtointeger(0,i*2,0)
end do
end subroutine
! 
! &&&&&&&&&&& lut_spectrum &&&&&&&&&&
! Generating spectrum lut
subroutine lut_spectrum(lut)
use dflib
implicit none
! (in) parameter
integer lut(0:255)
! general
integer i
! user function definition
integer, external::hsi2rgb
!
do i=0,255
	lut(i)=hsi2rgb(real(i/255.0),1.0,1.0)
end do
end subroutine
!
! &&&&&&&&&&& hsi2rgb(h,s,b)
! Convert HSI color mode to RGB color mode
function hsi2rgb(h,s,i)
use dflib
implicit none
! (in) parameters
real ::h,s,i
! (out) parameter
integer ::hsi2rgb
! general 
real r,g,b
real maxrgb
!
if(h*360.0<120) then
	r=i*(1+s*cos(h*2.0*3.14159)/cos(3.14159/3.0-h*2.0*3.14159))/sqrt(3.0)
	b=i*(1.0-s)/sqrt(3.0)
	g=i*sqrt(3.0)-r-b
else if(h*360.0>=120 .and. h*360.0<240) then
	g=i*(1+s*cos(h*2.0*3.14159-2.0*3.14159/3.0)/cos(3.14159-h*2.0*3.14159))/sqrt(3.0)
	r=i*(1.0-s)/sqrt(3.0)
	b=i*sqrt(3.0)-r-g
else
	b=i*(1+s*cos(h*2.0*3.14159-4.0*3.14159/3.0)/cos(5.0*3.14159/3.0-h*2.0*3.14159))/sqrt(3.0)
	g=i*(1.0-s)/sqrt(3.0)
	r=i*sqrt(3.0)-b-g
end if
maxrgb=max(r,g,b)
hsi2rgb=rgbtointeger(int4(r/maxrgb)*255,int4(g/maxrgb)*255,int4(b/maxrgb)*255)
end function
! 
! &&&&&&&&&&& lut_332rgb &&&&&&&&&&
! Generating 3-3-2 rgb lut
subroutine lut_332rgb(lut)
use dflib
implicit none
! (in) parameter
integer lut(0:255)
! general
integer i
!
do i=0,255
	!java source code:
	!   reds[i] = (byte)(i&0xe0);
    !   greens[i] = (byte)((i<<3)&0xe0);
    !   blues[i] = (byte)((i<<6)&0xc0);
end do
end subroutine