% VISUALIZE  Plot the summary metrics for TD and ASD fixation maps.
%
%   Purpose   : Shows how each model scores against typically developing
%               (TD) and autistic (ASD) fixation maps.
%   Inputs    : Results/TD_summary.csv and Results/ASD_summary.csv. Each has
%               one row per model, with <Metric>_Mean and <Metric>_std
%               columns. evaluate.m writes both.
%   Outputs   : Three figures, saved to visuals/ as bar.png, heatmap_td.png
%               and heatmap_asd.png. The first has a grouped TD and ASD bar
%               chart for each mean metric. The other two are heatmaps of
%               the mean metrics, one per group.
%   Run order : 1. downloadAndUnzip  2. cloneMetricsCode  3. evaluate
%               4. visualize
%               This script clears the workspace when it starts.

clear; close all; clc;

%% Read the summary CSVs
resultsDir = 'Results';
tdSummaryFile = fullfile(resultsDir, 'TD_summary.csv');
asdSummaryFile = fullfile(resultsDir, 'ASD_summary.csv');

if ~isfile(tdSummaryFile) || ~isfile(asdSummaryFile)
    error('Results/TD_summary.csv and Results/ASD_summary.csv are required. Run evaluate first.');
end

tdTable = readtable(tdSummaryFile, 'ReadRowNames', true);
asdTable = readtable(asdSummaryFile, 'ReadRowNames', true);

models = tdTable.Properties.RowNames;
metrics = tdTable.Properties.VariableNames(contains(tdTable.Properties.VariableNames, '_Mean'));
numMetrics = numel(metrics);

visualsDir = 'visuals';
if ~exist(visualsDir, 'dir')
    mkdir(visualsDir);
end

%% Grouped bar chart for each mean metric
figure('Name', 'Saliency Evaluation Results', 'NumberTitle', 'off');
for i = 1:numMetrics
    tdValues = tdTable.(metrics{i});
    asdValues = asdTable.(metrics{i});

    subplot(ceil(numMetrics/2), 2, i);
    bar(categorical(models), [tdValues, asdValues]);
    title(strrep(metrics{i}, '_', ' '));
    ylabel('Score');
    xlabel('Models');
    legend('TD', 'ASD','Location','Best');
    grid on;
end

sgtitle('Evaluation Metrics for Saliency Predictions');
saveas(gcf, fullfile(visualsDir, 'bar.png'));

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
saveas(gcf, fullfile(visualsDir, 'heatmap_td.png'));

figure('Name', 'ASD Metrics Heatmap', 'NumberTitle', 'off', 'Position', [500, 100, 300, 500]);
asdHeatmap = heatmap(meanMetrics, asdTable.Properties.RowNames, asdMeanData, 'CellLabelFormat','%.3f');
asdHeatmap.Title = 'ASD Metrics Heatmap';
asdHeatmap.XLabel = 'Metrics';
asdHeatmap.YLabel = 'Models';
asdHeatmap.FontSize = 12;
colormap(asdHeatmap, winter);
saveas(gcf, fullfile(visualsDir, 'heatmap_asd.png'));
