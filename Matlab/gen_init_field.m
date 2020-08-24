base_dir = '/Users/lyx/Develop/polyorder/example/AB/O70/16x32x56/';
data_file = [base_dir 'field_in_16x32x56.mat'];
%load('/Users/lyx/Dropbox/simulation/scft_ab_asym/asym1.5_triBHS/benchmark/BCC/ETDRK4/field_in_32x32x32.mat')
%load('/Users/lyx/Dropbox/simulation/scft_ab_asym/asym1.5_triBHS/benchmark/HEX/ETDRK4/field_in_32x64x24.mat')
for Nx=32:16:32
    Ny = Nx;
    Nz = 2*Nx;
    load(data_file);
    [xp,yp,zp,wA] = interp3_density(x,y,z,wA,Nx,Ny,Nz);
    [xp,yp,zp,wB] = interp3_density(x,y,z,wB,Nx,Ny,Nz);
    [xp,yp,zp,yita] = interp3_density(x,y,z,yita,Nx,Ny,Nz);
    [xp,yp,zp,phiA] = interp3_density(x,y,z,phiA,Nx,Ny,Nz);
    [xp,yp,zp,phiB] = interp3_density(x,y,z,phiB,Nx,Ny,Nz);
    x=xp; y=yp; z=zp;
    out_filename = ['field_in_' int2str(Nx) 'x' int2str(Ny) 'x' int2str(Nz) '.mat'];
    out_file = [base_dir out_filename];
    save(out_file, 'x', 'y', 'z', 'wA', 'wB', 'yita', 'phiA', 'phiB');
end
%save '/Users/lyx/Dropbox/simulation/scft_ab_asym/asym1.5_triBHS/benchmark/BCC/ETDRK4/field_in_16x16x16.mat'
%save '/Users/lyx/Dropbox/simulation/scft_ab_asym/asym1.5_triBHS/benchmark/HEX/ETDRK4/field_in_64x128x32.mat'
