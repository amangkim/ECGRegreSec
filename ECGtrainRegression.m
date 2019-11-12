function [RegFunction, RMSE_Bar] = ECGtrainRegression(trainingData)
% Regression Engine for Time Sliced ECG Training
%
% Usage: [RegFunction, RMSE_Bar] = trainRegressionModel(trainingData)
% Input:
%   trainingData: 2 column data [x1,y] where y=RegFunction(x1)
% Output:
%   RegFunction : Function of the regression model
%   RMSE_Bar : Overall root mean squre error
% How to Use:
%   y = RegFunction.predictFcn(x2)
% Note:
%   This function is autoatically generated by MATLAB
%   Machine Learning Method: Regression Decision Tree Method
%
% Edited by Amang Kim [22/Dec/2018]


inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2'});

predictorNames = {'column_1'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_2;
isCategoricalPredictor = [false];

regressionTree = fitrtree(...
    predictors, ...
    response, ...
    'MinLeafSize', 4, ...
    'Surrogate', 'off');


predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
treePredictFcn = @(x) predict(regressionTree, x);
RegFunction.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));


RegFunction.RegressionTree = regressionTree;
RegFunction.About = 'This struct is a trained model exported from Regression Learner R2018b.';
RegFunction.HowToPredict = sprintf('To make predictions on a new predictor column matrix, X, use: \n  yfit = c.predictFcn(X) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nX must contain exactly 1 columns because this model was trained using 1 predictors. \nX must contain only predictor columns in exactly the same order and format as your training \ndata. Do not include the response column or any columns you did not import into the app. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2'});

predictorNames = {'column_1'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_2;
isCategoricalPredictor = [false];

partitionedModel = crossval(RegFunction.RegressionTree, 'KFold', 5);


validationPredictions = kfoldPredict(partitionedModel);


RMSE_Bar = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));

end

