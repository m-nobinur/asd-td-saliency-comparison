% VISUALIZE  Plot the summary metrics for TD and ASD fixation maps.
%
%   Purpose   : Shows how each model scores against typically developing
%               (TD) and autistic (ASD) fixation maps.
%   Inputs    : Results/TD_summary.csv and Results/ASD_summary.csv. Each has
%               one row per model, with <Metric>_Mean and <Metric>_std
%               columns. Both files ship with the repository. evaluate.m
%               does not write them.
%   Outputs   : Three figures, none saved to disk. One has a grouped TD and
%               ASD bar chart for every summary column. The other two are
%               heatmaps of the mean metrics, one per group.
%   Run order : 1. downloadAndUnzip  2. cloneMetricsCode  3. evaluate
%               4. visualize
%               This script clears the workspace when it starts.

clear; close all; clc;

%% Read the summary CSVs
resultsDir = 'Results';
tdSummaryFile = fullfile(resultsDir, 'TD_summary.csv');
asdSummaryFile = fullfile(resultsDir, 'ASD_summary.csv');

if ~isfile(tdSummaryFile) || ~isfile(asdSummaryFile)
    error('Results/TD_summary.csv and Results/ASD_summary.csv are required. Both ship with the repository, and evaluate.m does not write them.');
end

tdTable = readtable(tdSummaryFile, 'ReadRowNames', true);
asdTable = readtable(asdSummaryFile, 'ReadRowNames', true);

models = tdTable.Properties.RowNames;
metrics = tdTable.Properties.VariableNames;
numMetrics = numel(metrics);

%% Grouped bar chart for every summary column
figure('Name', 'Saliency Evaluation Results', 'NumberTitle', 'off');
for i = 1:numMetrics
    tdValues = tdTable.(metrics{i});
    asdValues = asdTable.(metrics{i});

    subplot(ceil(numMetrics/2), 2, i);
    bar(categorical(models), [tdValues, asdValues]);
    title(sprintf('%s Score', metrics{i}));
    ylabel('Score');
    xlabel('Models');
    legend('TD', 'ASD','Location','Best');
    grid on;
end

sgtitle('Evaluation Metrics for Saliency Predictions');

%% Heatmaps of the mean metrics
meanIdx = contains(tdTable.Properties.VariableNames, '_Mean');
meanMetrics = tdTable.Properties.VariableNames(meanIdx);
tdMeanData = table2array(tdTable(:, meanIdx));
asdMeanData = table2array(asdTable(:, meanIdx));

figure('Name', 'TD Metrics Heatmap', 'NumberTitle', 'off', 'Position', [100, 100, 300, 500]);
tdHeatmap = heatmap(meanMetrics, tdTable.Properties.RowNames, tdMeanData, 'CellLabelFormat','%.3f');
tdHeatmap.Title = 'Typically Developing (TD) Metrics Heatmap';
tdHeatmap.XLabel = 'Metrics';
tdHeatmap.YLabel = 'Models';
tdHeatmap.FontSize = 12;
colormap(tdHeatmap, winter);

figure('Name', 'ASD Metrics Heatmap', 'NumberTitle', 'off', 'Position', [500, 100, 300, 500]);
asdHeatmap = heatmap(meanMetrics, asdTable.Properties.RowNames, asdMeanData, 'CellLabelFormat','%.3f');
asdHeatmap.Title = 'ASD Metrics Heatmap';
asdHeatmap.XLabel = 'Metrics';
asdHeatmap.YLabel = 'Models';
asdHeatmap.FontSize = 12;
colormap(asdHeatmap, winter);
