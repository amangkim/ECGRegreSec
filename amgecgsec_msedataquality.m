% amgecgsec_msedataquality
% demo06_dataquality
% Demo for the sliced mean filter

clear all;
amgecgsec_localsetup;

DBpath = SamplePath;
SampleECG = length(FileRecord);
FileIdx = -1;
%SliceTime = 0.35;
%EndTime = 37;

%SliceTime = input('Choose the SliceTime: ');

%-------------------- Quality Analysis for DataSet1
%DQ1= msedataqualityengine(DBpath, DataSet1) %, 20, SliceTime, SigmaLevel)
%DQ2= maerdataqualityengine(DBpath, DataSet2) %, 20, SliceTime, SigmaLevel)


Accepted = [];
Rejected = [];

DQ3= msedataqualityengine(DBpath, FileRecord, EndTime, SliceTime)
UCL_R = DQ3.min_mean_Max_MSE_UCL(2); %--- Based on the mean

for i = 1:length(DQ3.FileRecord)
    files = DQ3.FileRecord(i);
    mse0 = DQ3.MSE(i);
    if mse0 <= UCL_R
        Accepted = [Accepted files];
    else
        Rejected = [Rejected files];
    end
end

Accepted
Rejected




