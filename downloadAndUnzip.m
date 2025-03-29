function checkAndUnzipData()
    trainingDataFolder = 'TrainingData';
    if ~isfolder(trainingDataFolder) || isempty(dir(fullfile(trainingDataFolder, '*.*')))
        fprintf('The folder "%s" is missing or empty. Setting up training data...\n', trainingDataFolder);
        
        trainingDataZip = 'TrainingData.zip';
        zipDownloaded = false;
        
        if isfile(trainingDataZip)
            fprintf('Found %s locally.\n', trainingDataZip);
        else
            fprintf('TrainingData.zip not found locally. Attempting to download...\n');
            trainingDataUrl = 'https://shehqm88uj.ufs.sh/f/1nZKRMz7cdXZ6yMLdyJDxKSmfpinT19bdYB3FtkcHMuy72NI';
            downloadFile(trainingDataUrl, trainingDataZip);
            zipDownloaded = true;
            
            if ~isfile(trainingDataZip)
                error('Failed to download TrainingData.zip. Please check your internet connection or manually place the file in the current directory.');
            end
        end
        
        if ~isfolder(trainingDataFolder)
            mkdir(trainingDataFolder);
        end
        
        % Unzip the training data
        fprintf('Unzipping %s...\n', trainingDataZip);
        unzip(trainingDataZip);
        
        % Clean up
        if zipDownloaded && isfile(trainingDataZip)
            fprintf('Removing downloaded zip file %s...\n', trainingDataZip);
            delete(trainingDataZip);
        end
    end
    
    % Check PredictionMaps folder
    predMapsFolder = 'PredictionMaps';
    if ~isfolder(predMapsFolder) || isempty(dir(fullfile(predMapsFolder, '*.*')))
        fprintf('The folder "%s" is missing or empty. Setting up prediction maps...\n', predMapsFolder);
        
        predMapsZip = 'PredictionMaps.zip';
        zipDownloaded = false;
        
        if isfile(predMapsZip)
            fprintf('Found %s locally.\n', predMapsZip);
        else
            fprintf('PredictionMaps.zip not found locally. Attempting to download...\n');
            predMapsUrl = 'https://shehqm88uj.ufs.sh/f/1nZKRMz7cdXZNp8NWuUznJYaMv3VymWLqfrIt9AeXDpZRChK';
            downloadFile(predMapsUrl, predMapsZip);
            zipDownloaded = true;
            
            if ~isfile(predMapsZip)
                error('Failed to download PredictionMaps.zip. Please check your internet connection or manually place the file in the current directory.');
            end
        end
        
        if ~isfolder(predMapsFolder)
            mkdir(predMapsFolder);
        end
        
        % Unzip the prediction maps
        fprintf('Unzipping %s...\n', predMapsZip);
        unzip(predMapsZip);
        
        % Clean up
        if zipDownloaded && isfile(predMapsZip)
            fprintf('Removing downloaded zip file %s...\n', predMapsZip);
            delete(predMapsZip);
        end
    end
    
    % Check if the required subfolders exist
    tdFixFolder = fullfile(trainingDataFolder, 'TD_FixMaps');
    asdFixFolder = fullfile(trainingDataFolder, 'ASD_FixMaps');
    
    if ~isfolder(tdFixFolder)
        error('TD_FixMaps folder not found in TrainingData. Data structure may be incorrect.');
    end
    
    if ~isfolder(asdFixFolder)
        error('ASD_FixMaps folder not found in TrainingData. Data structure may be incorrect.');
    end
    
    fprintf('Data folders verified and ready for evaluation.\n');
end

% Helper function to download files
function downloadFile(fileUrl, outputFilename)
    try
        fprintf('Downloading %s...\n', outputFilename);
        websave(outputFilename, fileUrl);
        fprintf('File downloaded successfully: %s\n', outputFilename);
    catch ME
        fprintf('Error downloading file: %s\n', ME.message);
    end
end