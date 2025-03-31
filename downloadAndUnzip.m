function downloadAndUnzip()
% DOWNLOADANDUNZIP  Fetch and unpack the data that evaluate.m reads.
%
%   Purpose   : Makes sure TrainingData/ (fixation maps) and PredictionMaps/
%               (model outputs) exist in the current folder.
%   Inputs    : None. For each folder that is missing or empty, the function
%               uses TrainingData.zip or PredictionMaps.zip from the current
%               folder if it is there, and downloads it otherwise.
%   Outputs   : TrainingData/ and PredictionMaps/ in the current folder. A
%               zip this function downloaded is deleted after extraction. A
%               zip that was already present is kept.
%   Run order : 1. downloadAndUnzip  2. cloneMetricsCode  3. evaluate
%               4. visualize

    trainingDataFolder = 'TrainingData';

    %% Fixation maps
    ensureDataFolder(trainingDataFolder, 'TrainingData.zip', ...
        'https://shehqm88uj.ufs.sh/f/1nZKRMz7cdXZ6yMLdyJDxKSmfpinT19bdYB3FtkcHMuy72NI');

    %% Predicted saliency maps
    ensureDataFolder('PredictionMaps', 'PredictionMaps.zip', ...
        'https://shehqm88uj.ufs.sh/f/1nZKRMz7cdXZNp8NWuUznJYaMv3VymWLqfrIt9AeXDpZRChK');

    %% Check the folders evaluate.m depends on
    tdFixFolder = fullfile(trainingDataFolder, 'TD_FixMaps');
    asdFixFolder = fullfile(trainingDataFolder, 'ASD_FixMaps');

    if ~isfolder(tdFixFolder)
        error('TD_FixMaps folder not found in TrainingData. TrainingData.zip must unpack to TrainingData/TD_FixMaps and TrainingData/ASD_FixMaps.');
    end

    if ~isfolder(asdFixFolder)
        error('ASD_FixMaps folder not found in TrainingData. TrainingData.zip must unpack to TrainingData/TD_FixMaps and TrainingData/ASD_FixMaps.');
    end

    fprintf('Data folders verified and ready for evaluation.\n');
end

function ensureDataFolder(dataFolder, zipName, zipUrl)
% Unpack zipName into the current folder if dataFolder is missing or empty,
% downloading the zip from zipUrl when there is no local copy.
    if isfolder(dataFolder) && ~isempty(dir(fullfile(dataFolder, '*.*')))
        return;
    end

    fprintf('The folder "%s" is missing or empty. Setting it up...\n', dataFolder);

    zipDownloaded = false;

    if isfile(zipName)
        fprintf('Found %s locally.\n', zipName);
    else
        fprintf('%s not found locally. Attempting to download...\n', zipName);
        downloadFile(zipUrl, zipName);
        zipDownloaded = true;

        if ~isfile(zipName)
            error('Failed to download %s. Check the internet connection, or place the file in the current folder and run again.', zipName);
        end
    end

    if ~isfolder(dataFolder)
        mkdir(dataFolder);
    end

    fprintf('Unzipping %s...\n', zipName);
    unzip(zipName);

    if zipDownloaded && isfile(zipName)
        fprintf('Removing downloaded zip file %s...\n', zipName);
        delete(zipName);
    end
end

function downloadFile(fileUrl, outputFilename)
% Download fileUrl to outputFilename. A failure is reported here and the
% caller raises the error once it sees the file is missing.
    try
        fprintf('Downloading %s...\n', outputFilename);
        websave(outputFilename, fileUrl);
        fprintf('File downloaded successfully: %s\n', outputFilename);
    catch ME
        fprintf('Error downloading file: %s\n', ME.message);
    end
end
