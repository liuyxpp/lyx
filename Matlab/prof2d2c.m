%prof2d2c.m
%plot 2 component 2D space simulation for varying cell size profiles
%For: nA0B, ie neutral case.
%Author: Yi-Xin Liu@Fudan Univ.
%Since 2010.10.17
%
% chiN80_scft_out_*.mat
% pA0.01_scft_out_*.mat
nrepeatx=1;
nrepeaty=1;
flist=dir('chiN*.mat'); 
[n,m]=size(flist); % n - number of files, m=1
profs=zeros(128,n+1); % (:,1) for x, (:,2:n+1) for density
for i=1:n
    % collect lowest H for each cell size in sizeH
    [nf,mf]=size(flist(i).name); % nf=1, mf=number of characters
    tmpf=flist(i).name(5:mf);
    strVar=strtok(tmpf,'_');
    sizeH0(i,1)=str2num(strVar);
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
clear nrepeatx nrepeaty flist n m profs
clear nf mf tempf strVar sizeH0
clear i j nH r I pks locs npk rpk