function batch2d2c(dir_file,isSaveImage,result_file)
%anabatch2d2c.m
%analyzing 2 component 2D space simulation for varying cell size in batch
%mode
%For: nA0B, nApB, nA0B_salt, nA0B_solvent, etc.
%Author: Yi-Xin Liu@Fudan Univ. liuyxpp@gmail.com
%Since 2011.1.25
%batch var can be: e, eA, f, k, and p
%the dir structure (see details in paramx):
%    basePath/dir1/dir_batch_var
% example
%    basePath=$HOME/simulation/scft_pe_2d/nA0B-ceps-annealed/
%    dir1=eps1.8epsA1.0chiN28pA0.05-stage3-HEX/
%    dir_batch_var=fA0.1 {fA0.2, fA0.3, fA0;.4, etc.}
% $ Revision: 2011.1.26 $
if(nargin==0)
    dir_file='batchdir';
    isSaveImage=1;
    result_file='result_batchdir.txt';
elseif(nargin==1)
    isSaveImage=1;
    batchName=char(regexp(dir_file,'batchdir-\d+-\d+$','match'));
    result_file=['result_' batchName '.txt'];
elseif(nargin==2)
    if(isdeployed)
        isSaveImage=str2num(isSaveImage);
    end
    batchName=char(regexp(dir_file,'batchdir-\d+-\d+$','match'));
    result_file=['result_' batchName '.txt'];
else
    if(isdeployed)
        isSaveImage=str2num(isSaveImage);
    end
end

currentFolder=pwd;
%read all dir from dir_file
fid=fopen(dir_file);
dirs=textscan(fid,'%s');
fclose(fid);
%npath: how many directories
[npath dumb]=size(dirs{1});
% batchVar(1) ll_min(2) ll_max(3) 
% opt_size(4) H(5) 
% incompressibility(6) Err_Density(7) 
% Err_Residual(8) Err_Residual_e(9) steps(10)
outResult=zeros(npath,8);
for j=1:npath
batch_dir=char(dirs{1}(j));
cd(batch_dir);
%integer number or #.#, but without sign.
str_batchvar=char(regexp(batch_dir,'\d+\.?\d*$','match'));
outResult(j,1)=str2num(str_batchvar);
flist=dir('scft_out_ll*.mat');
[n,m]=size(flist); % n - number of files, m=1
sizeH0=zeros(n,3); % (:,1) for size, (:,2) for H, (:,3) for index
for i=1:n
    % collect lowest H for each cell size in sizeH
    [fpath fname fext]=fileparts(flist(i).name);
    str_steps=char(regexp(fname,'\d+\.?\d*$','match'));
    steps=str2num(str_steps);
    str_parts=char(regexp(fname,'scft_out_ll\d+\.?\d*','match'));
    str_size=char(regexp(str_parts,'\d+\.?\d*$','match'));
    sizeH0(i,1)=str2num(str_size);
    sizeH0(i,3)=i;
    load(flist(i).name);
    load(['param_out_ll' str_size '.mat']); % load parameter files
    iH=floor(steps/print_interval); %print_interval from param_out_ll*.mat
    sizeH0(i,2)=vH(iH); %vH from scft_out_ll*.mat
end %mat files
% sort sizeH according to size in ascending order
sizeH1=sortrows(sizeH0,1);
outResult(j,2)=sizeH1(1,1);
outResult(j,3)=sizeH1(length(sizeH1),1);
% sort sizeH according to H in ascending order
sizeH=sortrows(sizeH0,2);
outResult(j,4)=sizeH(1,1);
outResult(j,5)=sizeH(1,2);
idx=sizeH(1,3); % select the index of the lowest H
[fpath fname fext]=fileparts(flist(idx).name);
str_parts=char(regexp(fname,'scft_out_ll\d+\.?\d*','match'));
str_size=char(regexp(str_parts,'\d+\.?\d*$','match'));
load(flist(idx).name);
load(['param_out_ll' str_size '.mat']);
outResult(j,6)=sum(sum(abs(phiA+phiB+phiS-1.0)))/numel(phiA);
str_steps=char(regexp(fname,'\d+\.?\d*$','match'));
steps=str2num(str_steps);
iH=floor(steps/print_interval);
outResult(j,7)=vErrorDensity(iH);
outResult(j,8)=vErrorResidual(iH);
outResult(j,9)=vErrorResidual_e(iH);
outResult(j,10)=str2num(str_steps);
if(isSaveImage)
    batchs=regexp(batch_dir,['\' filesep],'split');
    batch=char(batchs{length(batchs)});
    saveImage(batch,flist(idx).name,['param_out_ll' str_size '.mat'])
end
end %dirs
disp(outResult)
cd('..');
dlmwrite(result_file,outResult,'delimiter','\t','precision',12);
cd(currentFolder);
end %function

function saveImage(batch,datafile,paramfile)
%batch: batchVarName.batchVar (eg. fA0.88)
load(datafile);
load(paramfile);

repeatx=3;
repeaty=3;
isPlotPolymerDensity=1;
isPlotPolymerDensityReplica=1;
isPlotSolventDensity=1;
isPlotChargeDensity=1;
isPlotChargeDensityReplica=1;

L=max(size(phiA));
phi_a=zeros(L);
phi_b=zeros(L);
phiba=zeros(L);
phi_s=zeros(L);
phi_p=zeros(L);
phi_n=zeros(L);
phipn=zeros(L);
phie=zeros(L);
phi0=zeros(L);
for i=1:L
    for j=1:L
        phi_a(i,j)=phiA(1,i,j);
        phi_b(i,j)=phiB(1,i,j);
        phi_s(i,j)=phiS(1,i,j);
        phi_p(i,j)=phiP(1,i,j);
        phi_n(i,j)=phiN(1,i,j);
    end
end
phiba=-phi_a+phi_b;
phipn=phi_p-phi_n;
phie=alphaA*upsA*phi_a+alphaB*upsB*phi_b+upsP*phi_p+upsN*phi_n;
% density plot
% A+B
if(isPlotPolymerDensity)
phi_img=cat(3,phi_a,phi0,phi_b);
%figure('visible','off');imshow(phi_img,'Border','tight');
%set(gca,'DataAspectRatio',[1.0 lly/llz 1.0]);
%axis off
imageName=['..' filesep batch '_ll' num2str(llx) '_densityAB.tif'];
imwrite(phi_img,imageName,'tif','Resolution',[100 100*lly/llz]);
%saveas(gcf,imageName);
%close(gcf);
end
% Solvent
if(isPlotSolventDensity)
smin=min(min(phi_s));
smax=max(max(phi_s));
phi_s=(phi_s-smin)/(smax-smin);
phi_img=cat(3,phi0,phi_s,phi0);
%figure('visible','off');imshow(phi_img,'Border','tight');
%set(gca,'DataAspectRatio',[1.0 lly/llz 1.0]);
%axis off
imageName=['..' filesep batch '_ll' num2str(llx) '_densityS.tif'];
imwrite(phi_img,imageName,'tif','Resolution',[100 100*lly/llz]);
%saveas(gcf,imageName);
%close(gcf);
end
% replica A+B
if(isPlotPolymerDensityReplica)
% replicate to enlarge
phi_img=cat(3,repmat(phi_a,repeatx,repeaty),repmat(phi0,repeatx,repeaty),repmat(phi_b,repeatx,repeaty));
%figure('visible','off');imshow(phi_img,'Border','tight');
%set(gca,'DataAspectRatio',[1.0 lly/llz 1.0]);
%axis off
imageName=['..' filesep batch '_ll' num2str(llx) '_densityAB_' num2str(repeatx) 'x' num2str(repeaty) '.tif'];
imwrite(phi_img,imageName,'tif','Resolution',[100 100*lly/llz]);
%saveas(gcf,imageName);
%close(gcf);
end
% charge density plot
mine=min(min(phie));
maxe=max(max(phie));
r=zeros(L);
g=zeros(L);
b=zeros(L);
% negtive charged region - red
% positive charged regino - green
% neutral region - black
for i=1:L
    for j=1:L
        if phie(i,j)>0
            g(i,j)=(phie(i,j)-0)/(maxe-0);
        end
        if phie(i,j)<0
            r(i,j)=(0-phie(i,j))/(0-mine);
        end
    end
end
if(isPlotChargeDensity)
phie_img=cat(3,r,g,b);
%figure('visible','off');imshow(phie_img,'Border','tight');
%set(gca,'DataAspectRatio',[1.0 lly/llz 1.0]);
%axis off
imageName=['..' filesep batch '_ll' num2str(llx) '_charge.tif'];
imwrite(phie_img,imageName,'tif','Resolution',[100 100*lly/llz]);
%saveas(gcf,imageName);
%close(gcf);
end
if(isPlotChargeDensityReplica)
% replicate to enlarge
phie_img=cat(3,repmat(r,repeatx,repeaty),repmat(g,repeatx,repeaty),repmat(b,repeatx,repeaty));
%figure('visible','off');imshow(phie_img,'Border','tight');
%set(gca,'DataAspectRatio',[1.0 lly/llz 1.0]);
%axis off
imageName=['..' filesep batch '_ll' num2str(llx) '_charge_' num2str(repeatx) 'x' num2str(repeaty) '.tif'];
imwrite(phie_img,imageName,'tif','Resolution',[100 100*lly/llz]);
%saveas(gcf,imageName);
%close(gcf);
end
end