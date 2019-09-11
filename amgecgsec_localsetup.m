% amgecgsec_cat1_localsetup
% Collected dataset for demostrating the time sliced ECG
% Sources from nsrdb, edb, eiddb from physionet and cse (KU) data
% Data Access: C:\AMG_Lounge\Mathwork_AMG\amgecgdb\amgecgsec
% Data Revision: R03
% Update: 2019.04.07

%--------------- Path & Filename Setup

SigDB = 'amgecgsec';
OriginalPath = 'C:\AMG_Lounge\Mathwork_AMG\Physionet\nsrdb\';
SamplePath=[pwd '\amgecgsec_dataset\train\'];
SamplePath2 = [pwd '\amgecgsec_dataset\test\'];

%--------Full FileRecord R04
kucsu = [101:115 117:128]; %Remove = [116]
edb = [401:404 406 407 411:458]; % Remove = [405 408:410]
nsrdb = [506:514];  %Remove = [501:505]
Unknown = [904:913]; % Remove = [901:903 914:916]
%-----------------------
PeakRatio = 0.6;    % Default annotation peak ratio for annotation
FileRecord = [kucsu edb nsrdb];
SampleSize = length (FileRecord);

% ------------ Required Values

NumofId = SampleSize;
NumofTrial = 60;

StartTime = 0;
EndTime = 50;       % Sample time for generating [Sec]
SliceTime = 0.6;
%------------------------------------   


