function [TrainedStruct] = sigslicefcn(varargin)
% Generating the sliced regference signal by using ML (in time domain)
%
% Usage:
%	[Structred_Reference (SR)] = Sigslice_time(SliceTime, ECG_data, SampleFreq, CustFilter, DisplayOption)
% Output: 
%   SR.SampleFreq:      Sampling Frequency
%   SR.NumberofSlice:   Number of slicing
%   SR.SliceWindow:     Sampling Time sequence
%   SR.RefData:         Base ECG data for the reference
%   SR.TrainData:       [[Time ECG]; Nx2] Training data
%   SR.RefFcn:          Regression Function with the time variables
% Input:
%   SliceTime [sec]:    Time for slicing the data [sec]
%   ECG_data:           ECG data from ML training
%   SampleFreq:         Sampling frequency of ECG data
%   CustFilter:          Off (0) or Custnomized filter
%   Display Option:     [0 (Off), 1 (2D-plot), 3(3D-plot)]
% 
% Note:
%   - Original m-code: ECGslice_time.m
%   - Required Matlab file(s): ECGtrainRegression, customfilter
%   - Adding the plotting feature
%   - Supporting 3D Plot option
%   - MSE of the data is included (SR.MSE)
%   - Revising the start index
%   - Allow the multiple input arguments
%	
% Made by Amang Kim [v0.75 || 3/18/2019]

%------------------------------------
inputs={'SliceTime', 'Sig_data', 'SampleFreq', 'CustFilter', 'DisplayOption'};

CustFilter = [];
DisplayOption = 0;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------

d1=Sig_data;
f=SampleFreq;
a=Rpeakfind(0.6, f, d1,0);

stm = stmgen(f, 0, d1);
stm_len=length(stm);

WindowTime=[0:1/f:SliceTime];
win_slot=length(WindowTime);


dat4train=[];
Data4ML = [];
la=length(a(:,1));

slice_sq =[];
dat3D =[];

%--------------- Find the time index for the time window
cut_end_idx=find(abs(stm-SliceTime)<0.0001);
if isempty(cut_end_idx)
    cut_end_idx=mean(find(abs(stm-SliceTime)<0.01));
end
%--------- Adjusting the end of the signal
while a(la,2)+cut_end_idx >=length(d1)    
    la=la-1;    
end
%--------------------------------------------------------

%---------------Diplay Option is ON
if DisplayOption==1
	figure;
    hold on
    grid on
    title('Machine Learning Plot');
    xlabel('window time (s)');
    ylabel('ECG amplitude (mV or V)');    
end
%----------------------------------


for i2=1:la %-----------------------------------------------------------------------------------
    st_idx=a(i2,2);
    if st_idx <=0
        st_idx =1;
    end
    
    dataidx=[st_idx:st_idx+win_slot-1];
    
    slicetime=WindowTime;
    slicedata=d1(dataidx);
    

    %--------------------- Applying the customized filter
    if isempty(CustFilter) | CustFilter == 0
        slicedata_w=slicedata;        
        %datasliced_w=weibullfilter(dataframed(:));
    else
        slicedata_w=usefilter(CustFilter, slicedata(:));
    end
    %----------------------------------------------------
       
	dat4train=[dat4train;[slicetime(:) slicedata_w(:)]];
    Data4ML = [Data4ML slicedata_w(:)];
    
    %---------------Diplay Option is ON
    if DisplayOption==1
        plot(slicetime, slicedata_w,'Color',[i2/(la*1.0003) i2/(la*1.01) i2/(la*1.05)]);
    end
    if DisplayOption == 3
        slice_sq =[slice_sq i2];
        dat3D(:,i2) = slicedata_w(:);
    end
    %----------------------------------
               
end	%-----------------------------------------------------------------------------------


%--------------------- Regression Model
[RefModel, RMSE_bar]= ECGtrainRegression(dat4train);
ref_plot=RefModel.predictFcn(slicetime(:));
MSE0 = RMSE_bar^2;
%--------------------------------------

%---------------Diplay Option is ON
if DisplayOption==1
    plot(WindowTime,ref_plot,'r.-');
    hold off
end
%---------------- 3D Display Option
if DisplayOption==3
    dat3D(:,la+1) = ref_plot(:);
    slice_sq =[slice_sq la+1];
    
    figure
    hold on
    %xlabel(['sliced samples (' num2str(la) ')']);
    grid on 
    xlabel('sliced samples');
    zlabel('ECG amplitude (mV or V)');
    %ylabel(['Window Time (' num2str (WindowTime) '[sec])']);
    ylabel('Window Time (sec)');
    surf (slice_sq, WindowTime, dat3D);
    grid off
    hold off
    %mesh(dat3D);
end
%----------------------------------

%---------------------------------------
S.RefFcn = RefModel.predictFcn;
S.MSE = MSE0; 
%S.RefData = ref_plot;
%S.TrainData = dat4train;
%S.MLData = Data4ML;

TrainedStruct=S;
%---------------------------------------

end