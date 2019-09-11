% amgecgsec_full_testing
% Testing ECG Signals based on ecgiddb
% Access Path: C:\AMG_Lounge\Mathwork_AMG\Physionet\ecgiddb\__R02
% Solution of the paper Optimzied [0.4 15]
% Made 
clear all
amgecgsec_localsetup;

RefSet = load('amgecgsec_RefECG_FcnSet.mat');
%RefSet = load('amgecgsec_RefECG_modeFcnSet.mat');
REF=RefSet.SRS;
%--------------------------------------------------
NumofId = length(REF)
SliceTime = REF(1).SliceTime(2)
%--------------------------------------------------
TargetRecord = [FileRecord 999]; 
FileRecord = [FileRecord Unknown];
%FileRecord = Unknown;

%NumofTrial=150
NumofTestSample=length(FileRecord)
NumofTrial=NumofTestSample;

TestPath = SamplePath2
FileRecRef =FileRecord;
TestStart = StartTime;        % Duration for scanning

Set = [0.6 30]
%Set = [0.4 30]
TestEnd = Set(2);
SliceTime = Set(1); % Best
%TestEnd = EndTime;
%[SliceTime TestEnd]
pause;

%disp('It is ready to validating the singal based on the reference function database......');
%pause;
%TestEnd = input('Select the sample time (5-45):');

%--------------------------------------------------

ID_sq=[];
VID_sq=[];
AP_ID_sq=[];
FalseDetect=[];
CorrectDetect=[];
PredictUnknown =[];
Accu_set = [];
UnknownCorrect = [];
KnownFalse = [];
PredictKnown = [];
Reject = [];
% ---------------------------

for i1=1:NumofTrial
    
    TestID=ceil(rand*NumofTestSample);
    %TestID=i1;
    DB0_Idx = FileRecord(TestID);
    DB0_str = num2str(DB0_Idx);
    SampleName=[TestPath DB0_str '.mat'];
    Heading=[DB0_str,' (',num2str(TestID),')'];
    
    [d0,sfq]=loadecgamg(SampleName, TestStart, TestEnd,0);
    stm = stmgen(sfq,SliceTime);
    d1= ecgpreprocess(sfq, d0, [1 1 1], 0);
        
    
    s2 =[];
    MAER = [];
    MSE0 = [];
    MSE00 = [];
    
    TestSt = timeslicedecg(SliceTime, d1, sfq);
    TrainDat = TestSt.SlicedData;
    %TestingECG =TestSt.MeanPlot;
    TestingECG =TestSt.ModePlot;
    WindowTimeIndex = TestSt.SliceWindow(2);
    NumofSlice = TestSt.NumberofSlice; 
    mmse0 = mean(mseamg(TrainDat, TestingECG));
    

       
    %=============================================
    UCL0 = [];
    RefAPU =[];
    APU0 = [];
    Ref_sq = [];
	AER0 = [];
    
    MAER1 = [];
    TestAPU = [];
    
    TargetOutput = zeros(1,NumofId+1);

            
    %--------------------------
    for i2=1:NumofSlice
        OneSlice = TrainDat(:,i2);
                
        MSE0 = [];
        ERange = [];
        idx_ERange = 0;
               
        
        for j = 1:NumofId
            Ref_sq = REF(j).RefFcn(stm);
            mse0= mseamg(OneSlice, Ref_sq);            
            MSE0 = [MSE0 mse0];
        end        
                
        ERange = MSE0;
        % UCL @ [0.4 50] == [1.8961e-04 0.0191 0.3109]
        if min(ERange) >= 0.3109 
            TargetOutput(NumofId+1) = TargetOutput(NumofId+1)+1;
            Predict = TargetRecord(NumofId+1);
            PredictUnknown = [PredictUnknown DB0_Idx];
        else
            [min_ERange, idx_ERange] = min(ERange);
            TargetOutput(idx_ERange) = TargetOutput(idx_ERange)+1;
        end
                
    end
    %--------------------------
    
    TargetProb = TargetOutput/sum(TargetOutput);
    [max_Prob, Prob_idx]=max(TargetProb);
    Actual = DB0_Idx;

	if Actual > 900
        Actual = 999;
    end
    
    Predict = TargetRecord(Prob_idx);

    % Training @[0.4 50] -- min_mean_Max_MSE_APR: [0.6939-96% 0.8386-100% 0.9783-100%]
    % Trainig @[0.6 60] -- min_mean_Max_MSE_APR: [0.7143-91.2% 0.8371 0.9630]
    if max_Prob <= 0.8371
    %if mmse0 > 0.0213 % UCL @ [0.4 50] == [1.8961e-04 0.0191 0.3109]
	
        Reject = [Reject Actual];
        Actual = -1;
        Predict = -1;
    else
        if(Actual ~= Predict)
            FalseDetect=[FalseDetect; [Actual Predict]];
            %------------------------ Module for Checking Sliced ECG        
            %amgecgsec_slicedECGcompare;
            %-------------------------------------------------------
        else
            CorrectDetect=[CorrectDetect; [Actual Predict]];
        end
        

        
    end    
	ID_sq = [ID_sq  Actual];
	VID_sq = [VID_sq Predict];    
   
end

[ID_sq(:) VID_sq(:)];
FalseDetect;
CorrectDetect;
ValidSamples = NumofTrial - length(Reject)
acc = sum(VID_sq == ID_sq)./numel(ID_sq);
DetectionRate = 1-length(Reject)/NumofTrial

%---------------------------------- Confusion Matrix (SCK)
%UnknownFalse = length(Unknown) - length(UnknownCorrect);
%False = length(FalseDetect(:,1))-UnknownFalse-length(find(FalseDetect(:,1) == PredictUnknown));

CorrectUnknown = length(find(CorrectDetect(:,1)>=900));
FalseUnknown = length(find(FalseDetect(:,1)>=900));
Correct = length(CorrectDetect(:,1))-CorrectUnknown;
False = length(FalseDetect(:,1))-FalseUnknown;

%Confusion = [Correct CorrectUnknown; False FalseUnknown]
%Confusion = [Correct False; FalseUnknown CorrectUnknown]

Confusion = [Correct FalseUnknown; False CorrectUnknown]
WithinDetect = Confusion(1,1)/(Correct+False);
disp(['The accuracy of the testing for ' num2str(ValidSamples) ' is ' num2str(WithinDetect*100) '%......']);
%---------------------------------------------------------
