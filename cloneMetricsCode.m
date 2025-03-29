metricsFolder = 'code_forMetrics';
visualizationFolder = 'code_forVisualization';

if ~isfolder(metricsFolder) || ~isfolder(visualizationFolder) || isempty(dir(fullfile(metricsFolder, '*.*')))
    fprintf('The folder "%s" and/or "%s" is missing or empty. Cloning repository...\n', metricsFolder, visualizationFolder);
    
    system('git clone https://github.com/cvzoya/saliency.git');
    
    % Move code_forMetrics folder to current directory.
    if ~isfolder(metricsFolder) && isfolder(fullfile('saliency', 'code_forMetrics'))
        movefile(fullfile('saliency', 'code_forMetrics'), '.');
    end

    % Move code_forVisualization folder to current directory.
    if ~isfolder(visualizationFolder) && isfolder(fullfile('saliency', 'code_forVisualization'))
        movefile(fullfile('saliency', 'code_forVisualization'), '.');
    end
    
    fprintf('Metrics & visualization folders verified and ready for use.\n'); % New line added for clarity
    
    % Clean up
    if isfolder('saliency')
        fprintf('Removing cloned repository...\n');
        rmdir('saliency', 's');
    end
end

% Add the metrics and visualization folder to path
addpath(metricsFolder);
addpath(visualizationFolder);
fprintf('Metrics & visualization folder added to path successfully.\n');
