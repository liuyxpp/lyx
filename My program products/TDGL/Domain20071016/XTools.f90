!_______________________________________________________________________
!
! XTools for some useful mathematical subroutines and functions 
! Author: Liu Yi-Xin
! Date: 2007.8.12 - 
! ______________________________________________________________________
!  
! subroutine and function list:
!       exhcange(a,b) !!!! integer a,b
! Modify record:
!        2007.8.18 Add funtion: integer gcd(a,b)
!                  Add subroutine: exchange_r8(a,b)
!                  Add subroutine: quikSort(x,y,size,start,tail)
!_______________________________________________________________________
!
!===================================================================================!
! Subroutines
!
! %%%%%%%%%% exchange %%%%%%%%%%%
! exchange the value of integer a and integer b
subroutine exchange(a,b)
implicit none
integer a,b
integer tmp
!
tmp=a
a=b
b=tmp
end subroutine
!
! %%%%%%%%%% exchange %%%%%%%%%%%
! exchange the value of integer a and integer b
subroutine exchange_r8(a,b)
implicit none
real*8 a,b
real*8 tmp
!
tmp=a
a=b
b=tmp
end subroutine
!
! %%%%%%%%% gcd %%%%%%%%
! find the greatest common divisor of a and b
function gcd(c,d)
implicit none
integer, intent(in) ::c,d
integer a,b,r
integer ::gcd
!
a=c
b=d
do while(b/=0)
	r=mod(a,b)
	a=b
	b=r
end do
gcd=a
end function
!
! %%%%%%%%% quikSort %%%%%%%%
! quik sort algorithm for sort fi axis and its depend value ffs, ffv, fds, fdv
! test ok! (2007.8.18)
recursive subroutine quickSort(x,y,size,start,tail)
implicit none
! (in) parameters
integer size ! the number of elements to be sorted
integer start ! the starting subscript of x array
integer tail ! the end subscript of x array. It's not nessessary that (tail-start-1) = size  
! (in/out) parameters
real*8 x(size) ! x axis, the array to be sorted
real*8 y(size) ! y axis, must move as x does
! general var
integer left,right
real*8 k
!
left=start
right=tail+1
if(right<=left) return
!
k=x(start)
do while(.TRUE.)
	! find x(left)<k
	do while(.TRUE.)
		left=left+1
		if((x(left)>k).or.(left>=tail)) exit
	end do
	! find x(right)>k
	do while(.TRUE.)
		right=right-1
		if((x(right)<k).or.(right<=start)) exit
	end do
	if(right<=left) exit
	call exchange_r8(x(left),x(right))
	call exchange_r8(y(left),y(right))
end do
call exchange_r8(x(start),x(right))
call exchange_r8(y(start),y(right))
call quickSort(x,y,size,start,right-1)
call quickSort(x,y,size,right+1,tail)
return
end subroutine