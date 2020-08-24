%ana2d2c_ll.m
%analyzing 2 component 2D space simulation for varying cell size
%For: nA0B, nApB, nA0B_salt, nA0B_solvent, etc.
%Author: Yi-Xin Liu@Fudan Univ.
%Since 2010.9.17
%
% scft_out_ll4_*
% scft_out_ll4.5_*
% scft_out_ll10_*
% scft_out_ll10.5_*

isScatter=false;
nrepeatx=8;
nrepeaty=8;
flist=dir('scft_out_ll*.mat'); 
[n,m]=size(flist); % n - number of files, m=1
sizeH0=zeros(n,2); % (:,1) for size, (:,2) for H
for i=1:n
    % collect lowest H for each cell size in sizeH
    [nf,mf]=size(flist(i).name); % nf=1, mf=number of characters
    tmpf=flist(i).name(12:mf);
    %tmpf=flist(i).name(14:mf);
    strsize=strtok(tmpf,'_');
    sizeH0(i,1)=str2num(strsize);
    load(flist(i).name);
    load(['param_out_ll' strsize '.mat']); % load parameter files
    nH=max(size(vH));
    for j=1:nH
        if(abs(vH(j))>0)
            sizeH0(i,2)=vH(j);
        end
    end
    % plot density map 
    plot2d2c;
    set(gcf,'name',strsize);
    % do scattering
    if(isScatter)
    [fout,r,I]=scatter(imresize(phiba,[Lz/(lly/llz),Ly]),dy,nrepeatx,nrepeaty,0,0,1);
    figure;plot(r,I);
    set(gcf,'name',['Diffraction:' strsize]);
    [pks,locs]=findpeaks(I,'minpeakheight',400,'npeaks',8);
    % the peak with largest intensity is the 1st order peak
    [cmax index]=max(pks);
    npk=max(size(locs));
    if(npk>0) 
        rpk=zeros(npk-index+1,1);
        for j=index:npk
            rpk(j-index+1)=r(locs(j));
        end
        disp(['Cell size: ' num2str(lly) ' x ' num2str(llz)])
        disp('        q       q(i)/q(1)        r        I ')
        format short e
        disp([rpk (rpk/rpk(1)) (1.0./rpk) pks(index:npk)'])
    end % if npk>0
    end % if do scattering
end
% sort sizeH according to cell size in ascending order
sizeH=sortrows(sizeH0,2);
clear nrepeatx nrepeaty flist n m
clear nf mf tempf strsize sizeH0
clear i j nH fout r I pks locs npk rpk