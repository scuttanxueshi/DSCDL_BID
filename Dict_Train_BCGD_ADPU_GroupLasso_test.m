clear;clc;
addpath('Data');
addpath('Utilities');
addpath('SPAMS');
addpath('CGD4unconstrained');

load Data/params.mat;
load Data/EMGM_8x8_100_20160921T195205.mat;
% load Data/EMGM_8x8_100_NI2NI.mat
% Parameters Setting
par.rho             = 0.05;
par.lambda1     =       0.01;
par.lambda2     =       0.001;
par.mu             =       0.01;
par.sqrtmu       =       sqrt(par.mu);
par.nu              =       0.1;
par.nup            =       0.5;
par.epsilon       =        5e-3;
par.cls_num      =    cls_num;
par.step            =    2;
par.win             =    8;
par.nIter           =       100;
par.t0               =       5;
par.K                =       256;
par.L                =       par.win * par.win;
param.K = par.K;
param.iter=300;
param.lambda = par.lambda1;
param.L = par.win * par.win;
flag_initial_done = 0;
paramsname = sprintf('Data/params.mat');
save(paramsname,'par','param');

load Data/EMGM_8x8_100_20160921T195205.mat;
% Initiate Dictionary
for i = 1 : par.cls_num
    XN_t = double(Xn{i});
    XC_t = double(Xc{i});
    XN_t = XN_t - repmat(mean(XN_t), [par.win^2 1]);
    XC_t = XC_t - repmat(mean(XC_t), [par.win^2 1]);
    fprintf('Double Semi-Coupled dictionary learning: Cluster: %d\n', i);
    D = mexTrainDL([XN_t;XC_t], param);
    Dini{i} = D;
    clear D;
    Dict_BID_Initial = sprintf('Data/temp_BID_Dict_BCGD_ADPU_DSCDL_Initial_2_50.mat');
    save(Dict_BID_Initial,'Dini');
    % Double S emi-Coupled Dictionary Learning
    D = Dini{i};
    Dn = D(1:par.win * par.win,:);
    Dc = D(par.win * par.win+1:end,:);
    Wn = eye(size(Dn, 2));
    Wc = eye(size(Dc, 2));
    Alphac = mexLasso([XN_t;XC_t], D, param);
    Alphan = Alphac;
    clear D;
    [Alphac, Alphan, XC_t, XN_t, Dc, Dn, Wc, Wn, Uc, Un, Pn, Energy] = GL_BCGD_ADPU_SCDL(Alphac, Alphan, XC_t, XN_t, Dc, Dn, Wc, Wn, par);
    Dict.DC{i} = Dc;
    Dict.DN{i} = Dn;
    Dict.WC{i} = Wc;
    Dict.WN{i} = Wn;
    Dict.UC{i} = Uc;
    Dict.UN{i} = Un;
    Dict.PN{i} = Pn;
    Dict.Energy{i} = Energy;
    %     Dict_BID_backup = sprintf('Data/DSCDL_BID_Dict_BCGD_ADPU_backup_nup0.5_%s.mat',datestr(now, 30));
    Dict_BID_backup = sprintf('Data/temp_BID_Dict_BCGD_ADPU_DSCDL_backup_test.mat');
    save(Dict_BID_backup,'Dict');
end