clear; close all; clc;

resultsDir = 'Results';
tdSummaryFile = fullfile(resultsDir, 'TD_summary.csv');
asdSummaryFile = fullfile(resultsDir, 'ASD_summary.csv');

if ~isfile(tdSummaryFile) || ~isfile(asdSummaryFile)
    error('Summary CSV files not found in the Results folder. Please run evaluate.m first.');
end

%% Read the CSV summaries
% If the CSV files don't include row names, you may need to modify this section.
tdTable = readtable(tdSummaryFile, 'ReadRowNames', true);
asdTable = readtable(asdSummaryFile, 'ReadRowNames', true);

%% Retrieve model and metric names
models = tdTable.Properties.RowNames;
metrics = tdTable.Properties.VariableNames;
numMetrics = numel(metrics);

%% Create a figure to display grouped bar charts for each metric
figure('Name', 'Saliency Evaluation Results', 'NumberTitle', 'off');
for i = 1:numMetrics
    % Extract metric values for TD and ASD data
    tdValues = tdTable.(metrics{i});
    asdValues = asdTable.(metrics{i});

    % Create a grouped bar chart for the current metric
    subplot(ceil(numMetrics/2), 2, i);
    bar(categorical(models), [tdValues, asdValues]);
    title(sprintf('%s Score', metrics{i}));
    ylabel('Score');
    xlabel('Models');
    legend('TD', 'ASD','Location','Best');
    grid on;
end

%% Improve figure layout
sgtitle('Evaluation Metrics for Saliency Predictions');

% Visualize the Heat Maps for Averaged Mean Metrics
meanIdx = contains(tdTable.Properties.VariableNames, '_Mean');
meanMetrics = tdTable.Properties.VariableNames(meanIdx);
tdMeanData = table2array(tdTable(:, meanIdx));
asdMeanData = table2array(asdTable(:, meanIdx));

% Create narrow heatmap for Training Data (TD)
figure('Name', 'TD Metrics Heatmap', 'NumberTitle', 'off', 'Position', [100, 100, 300, 500]);
h_td = heatmap(meanMetrics, tdTable.Properties.RowNames, tdMeanData, 'CellLabelFormat','%.3f');
h_td.Title = 'Training Data (TD) Metrics Heatmap';
h_td.XLabel = 'Metrics';
h_td.YLabel = 'Models';
h_td.FontSize = 12;
colormap(h_td, winter);

% Create narrow heatmap for ASD Data
figure('Name', 'ASD Metrics Heatmap', 'NumberTitle', 'off', 'Position', [500, 100, 300, 500]);
h_asd = heatmap(meanMetrics, asdTable.Properties.RowNames, asdMeanData, 'CellLabelFormat','%.3f');
h_asd.Title = 'ASD Metrics Heatmap';
h_asd.XLabel = 'Metrics';
h_asd.YLabel = 'Models';
h_asd.FontSize = 12;
colormap(h_asd, winter);