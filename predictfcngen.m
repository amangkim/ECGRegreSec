function [Structed_Ref_Set] = predictfcngen(varargin)
% Generating the sliced ECG Reference Structured Set by using ML
%
% Usage:
%	[Structed_Ref_Set (SRS)] = predictfcngen(DBpath, FileRecord, SampleTime, SliceTime, FilGenOptn)
%
% Output: SRS([1:SampleSize])
%   SRS.ID          :  Signal ID (file name) ['String']
%   SRS.NumofSlice  :  Number of training slices for each ECG signal [1 x 1] 
%   SRS.ECG_Ref     :  Trained ECG signals [SliceTime x 1]
%   SRS.MSE         :  Mean Square Error between Sliced signal and Reference Signal [1 x NumberOfSlice]
%   SRS.RMSER       :  Error ratio of the root MSE [1 x NumberOfSlice]
%   SRS.AccuR       :  Accuracy rate based on the variance
%
% Input:
%   DBpath       :  Path of ECG database (either local or webDB) ['String']
%   FileRecord   :  The set of file names to be trained [1 x N]
%   SampleTime   :  Sampling Time [sec] [1 x 1]
%   SliceTime    :  Time for slice (template size) [1 x 1]
%   FilterOption :  The way of applying a customized filter [0-Off, 1-On]
%
% Note:
%   - Required Matlab file(s): rangecontrol, sigslice_td, ecgpreprocess
%   - SampleSize = length (FileRecord)
%   - The reference is generated in the time domain
%   - Updating the reference ECG set structure
%   - Preprocess package is applied (ecgpreprocess)
%	
% Made by Amang Kim [v0.2b || 2/18/2019]



%(DBpath, FileRecord, SampleTime, SliceTime, FilterOptn)
%-----------------------------
inputs={'DBpath', 'FileRecord', 'SampleTime', 'SliceTime', 'FilterOptn'};
FilterOptn =0;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%-----------------------------



%----------------------------------
SamplePath = DBpath;
StartTime = 0;
EndTime = SampleTime; 	% Sample time for generating [Sec]
NumofId = length(FileRecord);
%----------------------------------

PeakRatio = 0.6;                % Default annotation peak ratio
%----------------------------------


%---------------- Initial Output Setup
ref_dat=[];         % Reference Matrix
TrainRMSE=[];       % RSME 
BaseF=[];
ID_str0=[];
pre_idx=0;

PDFSet =[];
FilterOffset = 'OFF';

if FilterOptn == 1
    FilterOffset = 'ON'
    %DFIL = load ('BaseTimeFilter_AMG.mat');    %--- Universal Filter
    DFIL = load ('TimeFilterSet_AMG.mat');      %--- Custome Filter
    if isempty (DFIL)
        FilterOptn=0;
        FilterOffset = 'OFF';
        disp ('There is NO filter set in the system....');
        disp ('The Reference Signal Set will be generated WITHOUT any filter....');
        pause;
    end        
end


for i1=1:NumofId %-----------------------------------------------

    DB0_Idx = FileRecord(i1);
    DB0_str = num2str(DB0_Idx);
    SampleName=[SamplePath DB0_str '.mat'];
    disp (['Training the data of [' DB0_str ']...........']);
        
    [d0, sfq] = loadecgamg(SampleName,StartTime,EndTime);
    d1 =  ecgpreprocess(sfq, d0(:), [1 1 1], 0); %--------------nsrdb testing case
    %a = Rpeakfind(PeakRatio, sfq, d1,0);
    
    if FilterOptn ==0
        %TS = sigslicefcn(SliceTime, d1, sfq);
        TS = sigslicemodefcn(SliceTime, d1, sfq);
    else
        %Filter = DFIL.SBF.FilterPDF;     %---- Universal Filter
        Filter = DFIL.SFS(i1).FilterPDF;  %---- Custom Filter
        %TS = sigslicefcn(SliceTime, d1, sfq, Filter);
    end
    
    % Output: 
    %	SR.RefFcn = RefModel.predictFcn;
    %	SR.MSE = MSE0; 
    

%------------------------------------------------
SRS(i1).ID = FileRecord(i1);
SRS(i1).DBPath = SamplePath;
SRS(i1).SampleTime = SampleTime;
SRS(i1).SliceTime = [0 SliceTime];
SRS(i1).RefFcn = TS.RefFcn;
%------------------------------------------------
    
end %----------------------------------------------------- 

Structed_Ref_Set = SRS;


end % © 2019 GitHub, Inc.
