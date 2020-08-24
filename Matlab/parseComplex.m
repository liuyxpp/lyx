function [ output, datar, datai ] = parseComplex( input )
%PARSECOMPLEX Parse the C++ complex data stored by C++ CMatFile Class
%   Storage scheme of the CMatFile:
%       NRMat3d<complex<double> > data(Lx,Ly,Lz);
%       mwSize dims3[3]={Lx,Ly,2*Lz};
%       mat.matPut("data",reinterpret_cast<void>(data.getRaw()),data.sizeBy
%       te(),3,dims3,mxDOUBLE_CLASS,mxREAL);
%
%   Example:
%       In C++:
%           Lx=4,Ly=3,Lz=2
%           data[i][j][k]=complex<double>(i*Ly*Lz+j*Lz+k,0);
%       In Matlab
%           data(:,:,1)=
%                    0     2     4
%                    0     0     0
%                    1     3     5
%                    0     0     0
%   Output:
%       Matlab complex array /output/
%       Real data /datar/
%       Imaginary data /datai/
%   NOTE:
%       Only works for 3D arrays.
%
sz=size(input);
datar=zeros(sz(1),sz(2),sz(3)/2);
datai=zeros(sz(1),sz(2),sz(3)/2);
for i=1:sz(3)
    for j=1:sz(2)
        for k=1:sz(1)
            index=(i-1)*sz(2)*sz(1)+(j-1)*sz(1)+(k-1);
            ii=floor(index/(2*sz(1)*sz(2)))+1;
            jj=floor((index-(ii-1)*2*sz(1)*sz(2))/(2*sz(1)))+1;
            kk=floor((index-(ii-1)*2*sz(1)*sz(2)-(jj-1)*2*sz(1))/2)+1;
            if(mod(index,2)==0)                
                datar(kk,jj,ii)=input(k,j,i);
            else                
                datai(kk,jj,ii)=input(k,j,i);
            end
        end
    end
end
output=complex(datar,datai);
end

