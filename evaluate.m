clear; close all; clc;

tdFixFolder  = fullfile('TrainingData', 'TD_FixMaps');
asdFixFolder = fullfile('TrainingData', 'ASD_FixMaps');

predictionsBaseFolder = 'PredictionMaps';

% List the model folders
models = dir(predictionsBaseFolder);
models = models([models.isdir] & ~ismember({models.name}, {'.','..'}));

% Define the evaluation metrics
metricNames = {'AUC_Borji', 'CC', 'KLdiv', 'NSS'};
numMetrics = length(metricNames);

% Initialize matrices to hold average metric values and standard deviations for each model.
TD_results  = zeros(length(models), numMetrics);
ASD_results = zeros(length(models), numMetrics);
TD_std  = zeros(length(models), numMetrics);
ASD_std = zeros(length(models), numMetrics);

% Create a directory for CSV results if it doesn't exist.
resultsDir = 'Results';
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

for m = 1:length(models)
    modelName = models(m).name;
    fprintf('Evaluating %s...\n', modelName);
    modelFolder = fullfile(predictionsBaseFolder, modelName);
    predFiles = dir(fullfile(modelFolder, '*.png'));
    
    j = 1;
    processedImageNames = {};
    % Preallocate arrays for all images.
    tdMetrics  = zeros(length(predFiles), numMetrics);
    asdMetrics = zeros(length(predFiles), numMetrics);
    
    % Process each prediction image
    for i = 1:length(predFiles)
        predFileName = predFiles(i).name;
        [~, baseName, ext] = fileparts(predFileName);
        
        % Read the prediction map image and convert to double.
        predPath = fullfile(modelFolder, predFileName);
        predMap = im2double(imread(predPath));
        
        % Determine the corresponding fixation map paths for TD and ASD.
        tdFixPath  = fullfile(tdFixFolder, [baseName, '_s', ext]);
        asdFixPath = fullfile(asdFixFolder, [baseName, '_s', ext]);
        
        % Check if both fixation maps exist; if not, skip.
        if ~isfile(tdFixPath) || ~isfile(asdFixPath)
            warning('Fixation maps for %s not found. Skipping image.', baseName);
            continue;
        end
        
        % Read and binarize the fixation maps.
        tdFixMap  = imbinarize(im2double(imread(tdFixPath)));
        asdFixMap = imbinarize(im2double(imread(asdFixPath)));
        
        processedImageNames{j} = baseName;
        
        %% Evaluate metrics for TD fixation maps
        try
            tdMetrics(j,1) = AUC_Borji(predMap, tdFixMap);
            tdMetrics(j,2) = CC(predMap, tdFixMap);
            tdMetrics(j,3) = KLdiv(predMap, tdFixMap);
            tdMetrics(j,4) = NSS(predMap, tdFixMap);
        catch ME
            warning('Error computing TD metrics for image %s: %s', baseName, ME.message);
        end
        
        %% Evaluate metrics for ASD fixation maps
        try
            asdMetrics(j,1) = AUC_Borji(predMap, asdFixMap);
            asdMetrics(j,2) = CC(predMap, asdFixMap);
            asdMetrics(j,3) = KLdiv(predMap, asdFixMap);
            asdMetrics(j,4) = NSS(predMap, asdFixMap);
        catch ME
            warning('Error computing ASD metrics for image %s: %s', baseName, ME.message);
        end
        
        j = j + 1;
    end % End loop over images
    
    % Remove any unused preallocated rows.
    if j > 1
        validTD  = tdMetrics(1:j-1, :);
        validASD = asdMetrics(1:j-1, :);
    else
        validTD  = [];
        validASD = [];
    end
    
    if ~isempty(validTD)
        TD_results(m,:) = mean(validTD, 1);
        TD_std(m,:) = std(validTD, 0, 1);
    else
        TD_results(m,:) = NaN;
        TD_std(m,:) = NaN;
    end
    if ~isempty(validASD)
        ASD_results(m,:) = mean(validASD, 1);
        ASD_std(m,:) = std(validASD, 0, 1);
    else
        ASD_results(m,:) = NaN;
        ASD_std(m,:) = NaN;
    end
    
    %% Save per-image metrics to CSV files.
    if ~isempty(validTD)
        TD_metrics_table = table(processedImageNames', validTD(:,1), validTD(:,2), validTD(:,3), validTD(:,4), ...
            'VariableNames', [{'ImageName'}, metricNames]);
        csvFileTD = fullfile(resultsDir, ['TD_metrics_' modelName '.csv']);
        writetable(TD_metrics_table, csvFileTD);
    end
    if ~isempty(validASD)
        ASD_metrics_table = table(processedImageNames', validASD(:,1), validASD(:,2), validASD(:,3), validASD(:,4), ...
            'VariableNames', [{'ImageName'}, metricNames]);
        csvFileASD = fullfile(resultsDir, ['ASD_metrics_' modelName '.csv']);
        writetable(ASD_metrics_table, csvFileASD);
    end
    
end

% Create table for TD average results.
TD_table = array2table(TD_results, 'VariableNames', metricNames, ...
    'RowNames', {models.name});
fprintf('\nEvaluation Results for Training Data (TD):\n');
disp(TD_table);

% Create table for ASD average results.
ASD_table = array2table(ASD_results, 'VariableNames', metricNames, ...
    'RowNames', {models.name});
fprintf('\nEvaluation Results for ASD:\n');
disp(ASD_table);