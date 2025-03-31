% EVALUATE  Score each model's saliency maps against TD and ASD fixation maps.
%
%   Purpose   : For every model folder in PredictionMaps/, compares each
%               predicted map with the matching typically developing (TD)
%               and autistic (ASD) fixation maps using AUC-Borji, CC, KL
%               divergence and NSS.
%   Inputs    : PredictionMaps/<Model>/<name>.png       predicted maps
%               TrainingData/TD_FixMaps/<name>_s.png    TD fixation maps
%               TrainingData/ASD_FixMaps/<name>_s.png   ASD fixation maps
%               AUC_Borji, CC, KLdiv and NSS on the MATLAB path, which
%               cloneMetricsCode sets up. Needs the Image Processing Toolbox.
%   Outputs   : Results/TD_metrics_<Model>.csv and
%               Results/ASD_metrics_<Model>.csv, one row per image.
%               Results/TD_summary.csv and Results/ASD_summary.csv, one row
%               per model with the mean and sample standard deviation of
%               each metric. Per-model means are also printed to the
%               Command Window.
%   Notes     : Each fixation map is binarised with imbinarize and the same
%               binary map goes to all four metrics. Predicted maps are
%               scored as saved, with no extra blur. An image is skipped
%               unless both of its fixation maps exist. No random seed is
%               set, so any metric that samples at random can differ
%               slightly between runs.
%   Run order : 1. downloadAndUnzip  2. cloneMetricsCode  3. evaluate
%               4. visualize
%               This script clears the workspace when it starts.

clear; close all; clc;

%% Paths and metric names
tdFixFolder  = fullfile('TrainingData', 'TD_FixMaps');
asdFixFolder = fullfile('TrainingData', 'ASD_FixMaps');

predictionsBaseFolder = 'PredictionMaps';

% Each subfolder of PredictionMaps/ is one model.
models = dir(predictionsBaseFolder);
models = models([models.isdir] & ~ismember({models.name}, {'.','..'}));

% These names are the metric function names and the CSV column headers.
metricNames = {'AUC_Borji', 'CC', 'KLdiv', 'NSS'};
numMetrics = length(metricNames);

% One row per model, one column per metric.
tdMean  = zeros(length(models), numMetrics);
asdMean = zeros(length(models), numMetrics);
tdStd   = zeros(length(models), numMetrics);
asdStd  = zeros(length(models), numMetrics);

resultsDir = 'Results';
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% Score every model
for m = 1:length(models)
    modelName = models(m).name;
    fprintf('Evaluating %s...\n', modelName);
    modelFolder = fullfile(predictionsBaseFolder, modelName);
    predFiles = dir(fullfile(modelFolder, '*.png'));

    % nextRow is the row the next scored image will fill.
    nextRow = 1;
    processedImageNames = {};
    tdMetrics  = zeros(length(predFiles), numMetrics);
    asdMetrics = zeros(length(predFiles), numMetrics);

    for i = 1:length(predFiles)
        predFileName = predFiles(i).name;
        [~, baseName, ext] = fileparts(predFileName);

        predPath = fullfile(modelFolder, predFileName);
        predMap = im2double(imread(predPath));

        % Fixation maps share the prediction's name with an '_s' suffix.
        tdFixPath  = fullfile(tdFixFolder, [baseName, '_s', ext]);
        asdFixPath = fullfile(asdFixFolder, [baseName, '_s', ext]);

        if ~isfile(tdFixPath) || ~isfile(asdFixPath)
            warning('Fixation maps for %s not found. Skipping image.', baseName);
            continue;
        end

        tdFixMap  = imbinarize(im2double(imread(tdFixPath)));
        asdFixMap = imbinarize(im2double(imread(asdFixPath)));

        processedImageNames{nextRow} = baseName;

        % TD fixation map
        try
            tdMetrics(nextRow,1) = AUC_Borji(predMap, tdFixMap);
            tdMetrics(nextRow,2) = CC(predMap, tdFixMap);
            tdMetrics(nextRow,3) = KLdiv(predMap, tdFixMap);
            tdMetrics(nextRow,4) = NSS(predMap, tdFixMap);
        catch ME
            warning('Error computing TD metrics for image %s: %s', baseName, ME.message);
        end

        % ASD fixation map
        try
            asdMetrics(nextRow,1) = AUC_Borji(predMap, asdFixMap);
            asdMetrics(nextRow,2) = CC(predMap, asdFixMap);
            asdMetrics(nextRow,3) = KLdiv(predMap, asdFixMap);
            asdMetrics(nextRow,4) = NSS(predMap, asdFixMap);
        catch ME
            warning('Error computing ASD metrics for image %s: %s', baseName, ME.message);
        end

        nextRow = nextRow + 1;
    end

    % Drop the preallocated rows that skipped images left unused.
    if nextRow > 1
        validTD  = tdMetrics(1:nextRow-1, :);
        validASD = asdMetrics(1:nextRow-1, :);
    else
        validTD  = [];
        validASD = [];
    end

    % Mean and sample standard deviation over images.
    if ~isempty(validTD)
        tdMean(m,:) = mean(validTD, 1);
        tdStd(m,:) = std(validTD, 0, 1);
    else
        tdMean(m,:) = NaN;
        tdStd(m,:) = NaN;
    end
    if ~isempty(validASD)
        asdMean(m,:) = mean(validASD, 1);
        asdStd(m,:) = std(validASD, 0, 1);
    else
        asdMean(m,:) = NaN;
        asdStd(m,:) = NaN;
    end

    % Per-image metrics, one CSV per model and group.
    if ~isempty(validTD)
        tdPerImage = table(processedImageNames', validTD(:,1), validTD(:,2), validTD(:,3), validTD(:,4), ...
            'VariableNames', [{'ImageName'}, metricNames]);
        tdCsvFile = fullfile(resultsDir, ['TD_metrics_' modelName '.csv']);
        writetable(tdPerImage, tdCsvFile);
    end
    if ~isempty(validASD)
        asdPerImage = table(processedImageNames', validASD(:,1), validASD(:,2), validASD(:,3), validASD(:,4), ...
            'VariableNames', [{'ImageName'}, metricNames]);
        asdCsvFile = fullfile(resultsDir, ['ASD_metrics_' modelName '.csv']);
        writetable(asdPerImage, asdCsvFile);
    end

end

%% Print the per-model means
tdMeanTable = array2table(tdMean, 'VariableNames', metricNames, ...
    'RowNames', {models.name});
fprintf('\nMean scores against typically developing (TD) fixation maps:\n');
disp(tdMeanTable);

asdMeanTable = array2table(asdMean, 'VariableNames', metricNames, ...
    'RowNames', {models.name});
fprintf('\nMean scores against ASD fixation maps:\n');
disp(asdMeanTable);

%% Write the per-model summaries that visualize.m reads
summaryNames = [strcat(metricNames, '_Mean'), strcat(metricNames, '_std')];

tdSummary = array2table([tdMean, tdStd], 'VariableNames', summaryNames, ...
    'RowNames', {models.name});
writetable(tdSummary, fullfile(resultsDir, 'TD_summary.csv'), 'WriteRowNames', true);

asdSummary = array2table([asdMean, asdStd], 'VariableNames', summaryNames, ...
    'RowNames', {models.name});
writetable(asdSummary, fullfile(resultsDir, 'ASD_summary.csv'), 'WriteRowNames', true);
