clear; close all; clc;

if ~exist('FES', 'dir')
    system('git clone https://github.com/hrtavakoli/FES.git');
    fprintf('FES repository cloned successfully.\n');
else
    fprintf('FES repository already exists.\n');
end

% Add the FES repository to path
addpath(genpath('./FES'));
fprintf('Added FES repository to MATLAB path.\n');

% I uploaded the 1.zip and 2.zip files(Images) to the Matlab server
% Since Matlab server doesn't allow large files
% Unzip the 1.zip and 2.zip files to TrainingData/Images
if ~exist('./TrainingData/Images', 'dir')
    mkdir('./TrainingData/Images');
    fprintf('Created TrainingData/Images directory.\n');
    
    zipFiles = {'1.zip'};
    for n = 1:numel(zipFiles)
        tmpDir = tempname;
        mkdir(tmpDir);
        unzip(zipFiles{n}, tmpDir);
        
        % Recursively get all files from tmpDir
        files = dir(fullfile(tmpDir, '**', '*'));
        for k = 1:numel(files)
            if ~files(k).isdir && files(k).name(1) ~= '.'
                movefile(fullfile(files(k).folder, files(k).name), './TrainingData/Images/');
            end
        end
        rmdir(tmpDir, 's');
    end
    
    fprintf('Extracted image files from 1.zip and 2.zip to TrainingData/Images.\n');
end

imageDir = './TrainingData/Images/';
resultFolder = './result/FES/';
if ~exist(resultFolder, 'dir')
    mkdir(resultFolder);
    fprintf('Created result directory: %s\n', resultFolder);
end

imgList = [dir([imageDir '*.jpg']); dir([imageDir '*.png'])];
fprintf('Found %d images to process.\n', numel(imgList));

for i = 1:numel(imgList)
    fprintf('Processing image %d of %d: %s\n', i, numel(imgList), imgList(i).name);
    
    %% Load a RGB image
    img = imread([imageDir imgList(i).name]);
    [x, y, ~] = size(img);
    
    %% Transform it to LAB
    img = RGB2Lab(img);
    
    load('prior');
    
    %% Compute the saliency
    saliency = computeFinalSaliency(img, [8 8 8], [13 25 38], 30, 10, 1, p1);
    saliency = imresize(saliency, [x,y]);
    
    % Save the saliency map
    [~, name, ~] = fileparts(imgList(i).name);
    imwrite(saliency, [resultFolder, name, '.png']);
end

% Zip the result folder for download
zipFile = 'FES.zip';
fprintf('Creating zip file %s of results...\n', zipFile);
if ispc
    zip(zipFile, resultFolder);
else
    system(['zip -r ' zipFile ' ' resultFolder]);
end

fprintf('Processing complete. Results saved to %s\n', zipFile);