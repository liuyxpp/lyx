!_______________________________________________________________________
!
! Domain for domain recognition, domain counting,
! boundary tracing and feature parameters caculating. 
!_______________________________________________________________________
!
! Author: Liu Yi-Xin
! Date: 2007.8.26 - 
! ______________________________________________________________________
!  
! subroutine and function list:
!       
!_______________________________________________________________________
!
! Modify record:
!              
!_______________________________________________________________________
!
!===================================================================================!
! Subroutines
!
! %%%%%%%%%% histgram %%%%%%%%%%%
! Caculate histgram of an image
subroutine histgram(image_in,hist)
use lyxTK
implicit none
! in parameter
integer ::image_in(1:n1,1:n2)
! out parameter
integer ::hist(256)
! general
integer i
!
hist=0
do i=1,256
	hist(i)=count(image_in==i-1) ! Refer to FORTRAN online help for more information of the intrinsic funtion: count().
end do
end subroutine
!
! %%%%%%%%%% threshold %%%%%%%%%%%
! threshhold image
subroutine threshold(image_in,image_out,thresh,mode)
use lyxTK
implicit none
! in parameters
integer ::image_in(n1,n2)
integer thresh
integer ::mode
! out parameters
integer ::image_out(n1,n2)
! general
integer i,j
!
do i=1,n2
	do j=1,n1
		select case(mode)
		case(2)
			if(image_in(j,i)<=thresh) then
				image_out(j,i)=255
			else
				image_out(j,i)=0
			end if
		case default
			if(image_in(j,i)>=thresh) then
				image_out(j,i)=255
			else
				image_out(j,i)=0
			end if
		end select
	end do
end do 
end subroutine
!
! %%%%%%%%%% domain labeling %%%%%%%%%%%
! the first domain is given the label 1, and increase it by 1 for next domain.
subroutine labeling(image_bin,image_label,numdomain,nplist)
use lyxTK
implicit none
! in parameter
integer ::image_bin(n1,n2)
! out parameter
integer ::image_label(n1,n2)
integer numdomain ! the number of domains
integer ::nplist(MAX_DOMAIN_NUM)
! general
integer label
integer i,j
!
image_label=image_bin
label=1
do i=1,n2
	do j=1,n1
		if(image_label(j,i)==255) then
			if(label>MAX_DOMAIN_NUM) then
				write(*,*) 'Error: too many domains!'
				return
			end if
			call setlabel(image_label,i,j,label,nplist(label))
			label=label+1
		end if
	end do
end do
numdomain=label-1
end subroutine
!
! %%%%%%%%%% set one label to a domain %%%%%%%%%%%
! using the cluster dialation method
subroutine setlabel(image,xs,ys,label,np)
use lyxTK
implicit none
! in parameters
integer ::image(n1,n2) 
integer xs,ys ! the starting position
integer label
! out parameters
integer np ! number of domain points
! image(n1,n2)
! general
integer i,j,k
integer cnt
integer im,ip,jm,jp
!
image(ys,xs)=label
np=0
do while(1>0) ! loop never stops
	cnt=0
	do i=1,n2
		do j=1,n1
			if(image(j,i)==label) then
				im=i-1
				ip=i+1
				jm=j-1
				jp=j+1
				if(im<1) im=1
				if(ip>n2) ip=n2
				if(jm<1) jm=1
				if(jp>n1) jp=n1
				if(image(jp,i)==255) then
					image(jp,i)=label
					cnt=cnt+1
				end if
				if(image(jp,im)==255) then
					image(jp,im)=label
					cnt=cnt+1
				end if
				if(image(j,im)==255) then
					image(j,im)=label
					cnt=cnt+1
				end if
				if(image(jm,im)==255) then
					image(jm,im)=label
					cnt=cnt+1
				end if
				if(image(jm,i)==255) then
					image(jm,i)=label
					cnt=cnt+1
				end if
				if(image(jm,ip)==255) then
					image(jm,ip)=label
					cnt=cnt+1
				end if  
				if(image(j,ip)==255) then
					image(j,ip)=label
					cnt=cnt+1
				end if
				if(image(jp,ip)==255) then
					image(jp,ip)=label
					cnt=cnt+1
				end if
			end if
		end do
	end do
	np=np+cnt
	if(cnt==0) exit 
end do
np=np+1 ! record the first start point (xs,ys) 
end subroutine
!
! %%%%%%%%%% getdomain_inners %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
! get domains' inner points (contains boundary) of an image.
subroutine getdomain_inners(image_in,image_label,dmn,nplist)
use lyxTK
implicit none
! in/out parameters
integer ::image_label(n1,n2) ! the labeled image
! in parameters
integer ::image_in(n1,n2) ! the original gray scale image
integer ::nplist(MAX_DOMAIN_NUM)
! out parameters
type (image_domains) dmn
! general
integer i,j,k
integer cnt
integer nd ! the actual domain numbers
logical, allocatable ::isbd(:) ! is boundary domain? 
!
allocate(isbd(dmn%nd))
isbd=.false.
do k=1,dmn%nd
LOOP_A: 	do i=1,n2
		do j=1,n1
			if(image_label(j,i)==k) then
				if(j==1 .or. j==n1 .or. i==1 .or. i==n2) then
					isbd(k)=.true.
					exit LOOP_A
				end if
			end if
		end do
	end do  LOOP_A
end do
!
nd=0
do k=1,dmn%nd
	! drop off the domains that contains points number less than MIN_DOMAIN_POINTS
	if(nplist(k)>=MIN_DOMAIN_POINTS .and. .not. isbd(k)) then
		nd=nd+1
		cnt=1
		dmn%inners(nd)%np=nplist(k)
		allocate(dmn%inners(nd)%p(nplist(k)))
		do i=1,n2
			do j=1,n1
				if(image_label(j,i)==k) then
					image_label(j,i)=nd       ! reset the label for the domains number changing
					dmn%inners(nd)%p(cnt)%x=i
					dmn%inners(nd)%p(cnt)%y=j
					dmn%inners(nd)%p(cnt)%pv=image_in(j,i)
					cnt=cnt+1
				end if
			end do
		end do
	else
		do j=1,n1
			do i=1,n2
				if(image_label(j,i)==k) image_label(j,i)=0 ! set the dropped domains' label back to background (0)
			end do
		end do
	end if
end do
! ensure that there are no labeled pixels on the image bounds.
do i=1,n2
	image_label(1,i)=0
	image_label(n1,i)=0
end do
do j=1,n1
	image_label(j,1)=0
	image_label(j,n2)=0
end do
!
dmn%nd=nd ! reset the number of domains
end subroutine
!
! %%%%%%%%%% trace domains boundary %%%%%%%%%%%%%%%%%%%%%%%
! trace domains boundary
subroutine traceboundary(image_bound,label,circum,np)
use lyxTK
implicit none
! in parameters
integer label
! out parameter
integer ::image_bound(n1,n2) ! also in
real ::circum
integer ::np
! general
integer i,j
!
do i=1,n2
	do j=1,n1
		if(image_bound(j,i)==label) then
			call trace(image_bound,i-1,j,circum,np)
			return
		end if
	end do
end do
end subroutine
!
! %%%%%%%%%% trace domain boundary %%%%%%%%%%%
! trace domain boudary using 8-neighbor algorithm
! set boundary pixels to 255, inner domain is label and other region is 0
subroutine trace(image,xs,ys,circum,np)
use lyxTK
implicit none
! in parameters
integer ::image(n1,n2) ! The value will change
integer xs,ys ! the starting search position
! out parameter
real circum
integer np
! general
integer i,j
integer x,y
integer vector ! indicate the search direction
integer label
!
real, parameter ::root2=1.4142
!
np=0
x=xs
y=ys
label=image(y,x+1)
circum=0
vector=5
do while(1>0) ! loop never stops
	if(x==xs .and. y==ys .and. circum>0) exit
	image(y,x)=255
	select case(vector)
	case(3)
		if(x+1>n2) then
			vector=5
		else if(y-1<1) then
			vector=7
		else
			if(image(y,x+1)/=label .and. image(y-1,x+1)==label) then
				np=np+1
				x=x+1
				!y=y
				circum=circum+1.0
				vector=0
			else
				vector=4
			end if
		end if
	case(4)
		if(y-1<1) then
			vector=7
		else if(x+1>n2) then
			vector=5
		else 
			if(image(y-1,x+1)/=label .and. image(y-1,x)==label) then
				np=np+1
				x=x+1
				y=y-1
				circum=circum+root2
				vector=1
			else
				vector=5
			end if
		end if
	case(5)
		if(y-1<1) then
			vector=7
		else if(x-1<1) then
			vector=1
		else
			if(image(y-1,x)/=label .and. image(y-1,x-1)==label) then
				np=np+1
				!x=x
				y=y-1
				circum=circum+1.0
				vector=2
			else
				vector=6
			end if
		end if
	case(6)
		if(y-1<1) then
			vector=7
		else if(x-1<1) then
			vector=1
		else
			if(image(y-1,x-1)/=label .and. image(y,x-1)==label) then
				np=np+1
				x=x-1
				y=y-1
				circum=circum+root2
				vector=3
			else
				vector=7
			end if
		end if
	case(7)
		if(x-1<1) then
			vector=1
		else if(y+1>n1) then
			vector=3
		else
			if(image(y,x-1)/=label .and. image(y+1,x-1)==label) then
				np=np+1
				x=x-1
				!y=y
				circum=circum+1.0
				vector=4
			else
				vector=0
			end if
		end if
	case(0)
		if(y+1>n1) then
			vector=3
		else if(x-1<1) then
			vector=1
		else
			if(image(y+1,x-1)/=label .and. image(y+1,x)==label) then
				np=np+1
				x=x-1
				y=y+1
				circum=circum+root2
				vector=5
			else
				vector=1
			end if
		end if
	case(1)
		if(y+1>n1) then
			vector=3
		else if(x+1>n2) then
			vector=5
		else 
			if(image(y+1,x)/=label .and. image(y+1,x+1)==label) then
				np=np+1
				!x=x
				y=y+1
				circum=circum+1.0
				vector=6
			else
				vector=2
			end if
		end if
	case(2) 
		if(y+1>n1) then
			vector=3
		else if(x+1>n2) then
			vector=5
		else
			if(image(y+1,x+1)/=label .and. image(y,x+1)==label) then
				np=np+1
				x=x+1
				y=y+1
				circum=circum+root2
				vector=7
			else
				vector=3
			end if
		end if
	end select
end do
! set the color of boundary to label value 
do i=1,n2
	do j=1,n1
		if(image(j,i)==label) image(j,i)=0
		if(image(j,i)==255) image(j,i)=label
	end do
end do
end subroutine
!
! %%%%%%%%%% getdomain_boundaries %%%%%%%%%%%
! get domains' boundary points of an image.
subroutine getdomain_boundaries(image_bound,dmn,nplist)
use lyxTK
implicit none
! in parameters
integer ::image_bound(1:n1,1:n2)
integer ::nplist(MAX_DOMAIN_NUM)
! out parameters
type (image_domains) dmn
! general
integer i,j,k
integer cnt
!
do k=1,dmn%nd
	cnt=1
	dmn%boundaries(k)%np=nplist(k)
	allocate(dmn%boundaries(k)%p(nplist(k)))
	do i=1,n2
		do j=1,n1
			if(image_bound(j,i)==k) then
				dmn%boundaries(k)%p(cnt)%x=i
				dmn%boundaries(k)%p(cnt)%y=j
				dmn%boundaries(k)%p(cnt)%pv=k
				cnt=cnt+1
			end if
		end do
	end do
end do
end subroutine
!
! %%%%%%%%%% getdomain_features %%%%%%%%%%%
! get domains' features of an image.
! C, A, V, R, H, gcx, gcy
subroutine getdomain_features(dmn,circum)
use lyxTK
implicit none
! in/out parameter
type (image_domains) dmn
! in parameter
real ::circum(MAX_DOMAIN_NUM)
! general
integer i,j
integer tv    ! count for volume
integer tx,ty ! count for gcx,gcy
integer rg2
!
do i=1,dmn%nd
	dmn%features(i)%C=circum(i)
	dmn%features(i)%A=dmn%inners(i)%np
	dmn%features(i)%H=maxval(dmn%inners(i)%p%pv)
	! volume and gravity center
	tv=0
	tx=0
	ty=0
	do j=1,dmn%inners(i)%np
		tv=tv+dmn%inners(i)%p(j)%pv
		tx=tx+dmn%inners(i)%p(j)%x
		ty=ty+dmn%inners(i)%p(j)%y
	end do
	dmn%features(i)%V=tv
	dmn%features(i)%gcx=int(tx/dmn%inners(i)%np)
	dmn%features(i)%gcy=int(ty/dmn%inners(i)%np)
	! radius of gyration, denpendce of gravity center, R=sqrt(2)Rg
	rg2=0
	do j=1,dmn%inners(i)%np
		rg2=rg2+(dmn%inners(i)%p(j)%x-dmn%features(i)%gcx)**2+(dmn%inners(i)%p(j)%y-dmn%features(i)%gcy)**2
	end do
	dmn%features(i)%R=sqrt(rg2*2.0/dmn%inners(i)%np) ! R=sqrt(2*R*R)
end do
end subroutine
!
! %%%%%%%%%% identify domain %%%%%%%%%%%
! the same domain in different images may change their intrinsic labels.
! Here, we provide a method to indentify the same domain in different images by using gravity center
! location. First compare the current domain's area with previous domain; Second determine the gravity center 
! of the smaller area domain is contained in the larger one; Then consider these two domain as the same one if
! the value is true, and set them a same label.
! !!!!!! NOTE: we also may applied other criterior here to determine whether two domains are the same, for example,
!              the distance of these two domains' gravity center is within a limiting value.
subroutine identifydomain(predmn,dmn)
use lyxTK
implicit none
! in parameter
type (IMAGE_DOMAINS) predmn
! in/out parameter
type (IMAGE_DOMAINS) dmn
! general
integer i,j,k
integer cnt
!
dmn%labels=-1 ! indicating that the label is unsetted
do i=1,dmn%nd
LOOP_PRE:	do j=1,predmn%nd
		if(dmn%inners(i)%np>=predmn%inners(j)%np) then  ! growth or saturated
			do k=1,dmn%inners(i)%np
				if(predmn%features(j)%gcx==dmn%inners(i)%p(k)%x .and. predmn%features(j)%gcy==dmn%inners(i)%p(k)%y) then
					dmn%labels(i)=predmn%labels(j)
					exit LOOP_PRE
				end if
		    end do
		else            ! diminishing
			do k=1,predmn%inners(j)%np
				if(dmn%features(i)%gcx==predmn%inners(j)%p(k)%x .and. dmn%features(i)%gcy==predmn%inners(j)%p(k)%y) then
					dmn%labels(i)=predmn%labels(j)
					exit LOOP_PRE
				end if
			end do
		end if
	end do LOOP_PRE
end do
cnt=0
do i=1,dmn%nd
	if(dmn%labels(i)==-1) then
		cnt=cnt+1
		dmn%labels(i)=predmn%maxlabel+cnt
	end if
end do
dmn%maxlabel=predmn%maxlabel+cnt
end subroutine
!
! %%%%%%%%%% get label position %%%%%%%%%%%
! the y coord of label position is the domain gravity center,
! and the x coord of label position is to the right boundary of the domain
! or to the left boundary of the domain if out of image bounds. 
subroutine getlabel_pos(dmn,pos,ftheight,ftwidth)
use lyxTK
implicit none
! in parameters
type (image_domains) dmn
integer(2) ftheight,ftwidth
! out parameters
type (domain_point) ::pos(MAX_DOMAIN_NUM)
! general
integer i,j,k
integer right,left
!
do k=1,dmn%nd
	pos(k)%x=dmn%features(k)%gcx
	if(pos(k)%x+ftheight>n2) pos(k)%x=n2-ftheight
	right=1
	left=n1
	! find the right most point
	do i=1,dmn%inners(k)%np
		if(dmn%inners(k)%p(i)%x==dmn%features(k)%gcx) then
			if(dmn%inners(k)%p(i)%y>right) right=dmn%inners(k)%p(i)%y
		end if
	end do
	pos(k)%y=right+DOMAIN_LABEL_SPACE
	! if the text exceeds image bounds, find the left most point
	if(right+DOMAIN_LABEL_SPACE+3*ftwidth>n1) then
		do i=1,dmn%inners(k)%np
			if(dmn%inners(k)%p(i)%x==dmn%features(k)%gcx) then
				if(dmn%inners(k)%p(i)%y<left) left=dmn%inners(k)%p(i)%y
			end if
		end do
		pos(k)%y=left-DOMAIN_LABEL_SPACE-3*ftwidth
		if(pos(k)%y<1) pos(k)%y=1
	end if
end do
end subroutine