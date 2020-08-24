function [ output, datar, datai ] = parseComplex_1D( input )
%PARSECOMPLEX Parse the C++ complex data stored by C++ CMatFile Class
%   Storage scheme of the CMatFile:
%       NRMat3d<complex<double> > data(M);
%       mwSize dims1[1]={2*M};
%       mat.matPut("data",reinterpret_cast<void>(data.getRaw()),data.sizeBy
%       te(),1,dims1,mxDOUBLE_CLASS,mxREAL);
%
%   Example:
%       In C++:
%           M=4
%           data[i]=complex<double>(i,0);
%       In Matlab
%           data(:)=
%                    1 0 2 0 3 0 4 0
%   Output:
%       Matlab complex array /output/
%       Real data /datar/
%       Imaginary data /datai/
%   NOTE:
%       Only works for 1D arrays.
%
M=numel(input);
datar=zeros(1,M/2);
datai=zeros(1,M/2);
for i=1:2:M
    datar((i+1)/2)=input(i);
    datai((i+1)/2)=input(i+1);
end
output=complex(datar,datai);
datar=datar';
datai=datai';
end

