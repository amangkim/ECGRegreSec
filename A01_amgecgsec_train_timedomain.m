% amgecgsec_train_timedomain
% Access Path: C:\AMG_Lounge\Mathwork_AMG\amgecgdb\amgecgsec
% Made by Amang Kim
% Update: 4/1/2019

clear all;
amgecgsec_localsetup;

%--------------------------------------------------
SigDB
SamplePath

NumofId
NumofTrial;

StartTime
EndTime       % Sample time for generating [Sec]
PeakRatio     % Default annotation peak ratio for annotation
SliceTime
FileRecord =FileRecord(1:NumofId);
SampleTime = EndTime

disp('Ready for testing the trained data............');

pause;
%--------------------------------------------------

DBpath=SamplePath;

SRS = predictfcngen(DBpath, FileRecord, SampleTime, SliceTime);
%SRS = predictfcngenF(DBpath, FileRecord, SampleTime, SliceTime);



%TargetFull = [SigDB '_RefWDFECG_FcnSet.mat']; 
TargetFull = [SigDB '_RefECG_FcnSet.mat']; 

disp(['Saving the record of ',TargetFull, '.......']);
save(TargetFull,'SRS')
disp(['Saving is competed..................................']);
