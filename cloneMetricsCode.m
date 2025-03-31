% CLONEMETRICSCODE  Fetch the MIT Saliency Benchmark metric code.
%
%   Purpose   : Makes the metric functions that evaluate.m calls (AUC_Borji,
%               CC, KLdiv, NSS) available on the MATLAB path.
%   Inputs    : None. If the folders below are missing, git must be on the
%               system path and the machine needs internet access.
%   Outputs   : code_forMetrics/ and code_forVisualization/ in the current
%               folder, taken from https://github.com/cvzoya/saliency and
%               added to the MATLAB path. The rest of the clone is removed.
%   Run order : 1. downloadAndUnzip  2. cloneMetricsCode  3. evaluate
%               4. visualize
%               The path change lasts for the session, so run this once per
%               MATLAB session before evaluate.

metricsFolder = 'code_forMetrics';
visualizationFolder = 'code_forVisualization';

%% Clone the benchmark repository if either folder is missing
if ~isfolder(metricsFolder) || ~isfolder(visualizationFolder) || isempty(dir(fullfile(metricsFolder, '*.*')))
    fprintf('The folder "%s" and/or "%s" is missing or empty. Cloning repository...\n', metricsFolder, visualizationFolder);

    system('git clone https://github.com/cvzoya/saliency.git');

    % Keep only the two folders this project uses.
    if ~isfolder(metricsFolder) && isfolder(fullfile('saliency', 'code_forMetrics'))
        movefile(fullfile('saliency', 'code_forMetrics'), '.');
    end

    if ~isfolder(visualizationFolder) && isfolder(fullfile('saliency', 'code_forVisualization'))
        movefile(fullfile('saliency', 'code_forVisualization'), '.');
    end

    fprintf('Metrics and visualization folders are in place.\n');

    if isfolder('saliency')
        fprintf('Removing cloned repository...\n');
        rmdir('saliency', 's');
    end
end

%% Add both folders to the MATLAB path
addpath(metricsFolder);
addpath(visualizationFolder);
fprintf('Metrics and visualization folders added to the MATLAB path.\n');
