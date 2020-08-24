%ana2d2cn_ll.m
%analyzing 2 component 2D space simulation for varying cell size
%For: 0A0B, ie neutral case.
%Author: Yi-Xin Liu@Fudan Univ.
%Since 2010.10.9
%
% scft_out_ll4_*
% scft_out_ll4.5_*
% scft_out_ll10_*
% scft_out_ll10.5_*
nrepeatx=3;
nrepeaty=3;
flist=dir('scft_out_ll*.mat'); 
%flist=dir('scft_out_1_ll*.mat');
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
    nH=max(size(vH));
    for j=1:nH
        if(abs(vH(j))>0)
            sizeH0(i,2)=vH(j);
        end
    end
    % plot density map 
    plot2d2cn;
    set(gcf,'name',strsize);
    % do scattering
    if(1)
    [r,I]=scatter(phiba,str2num(strsize)/max(size(phiba)),nrepeatx,nrepeaty,0,0,1);
    set(gcf,'name',strsize);
    [pks,locs]=findpeaks(I,'minpeakheight',2000,'npeaks',4);
    npk=max(size(locs));
    if(npk>0)
    rpk=zeros(size(locs));
    for j=1:npk
        rpk(j)=r(locs(j));
    end
    disp(['Cell size: ',strsize])
    disp('        q       q(i)/q(1)        r        I ')
    format short e
    disp([rpk' (rpk/rpk(1))' (1.0./rpk)' pks'])
    end
    end
end
% sort sizeH according to cell size in ascending order
sizeH=sortrows(sizeH0);
clear nrepeatx nrepeaty flist n m
clear nf mf tempf strsize sizeH0
clear i j nH r I pks locs npk rpk