% FES  Generate FES saliency maps for the stimulus images.
%
%   Purpose   : Runs the FES model (https://github.com/hrtavakoli/FES) on
%               every .jpg and .png image in TrainingData/Images.
%   Inputs    : TrainingData/Images/ in the current folder. If that folder
%               does not exist, the script creates it and fills it from
%               1.zip in the current folder. git must be on the system path.
%   Outputs   : result/FES/<name>.png, one map per image at the image's
%               size, and FES.zip containing that folder.
%   Run order : Run this before the evaluation scripts. All paths are
%               relative to MATLAB's current folder. evaluate.m reads the
%               maps from PredictionMaps/FES/, so copy them there afterwards.
%               This script clears the workspace when it starts.

clear; close all; clc;

%% Get the FES code
if ~exist('FES', 'dir')
    system('git clone https://github.com/hrtavakoli/FES.git');
    fprintf('FES repository cloned successfully.\n');
else
    fprintf('FES repository already exists.\n');
end

addpath(genpath('./FES'));
fprintf('Added FES repository to MATLAB path.\n');

%% Unpack the images
% The images arrive as a zip because the hosted MATLAB session I used
% limits upload size. Only the archives listed in zipFiles are unpacked.
if ~exist('./TrainingData/Images', 'dir')
    mkdir('./TrainingData/Images');
    fprintf('Created TrainingData/Images directory.\n');

    zipFiles = {'1.zip'};
    for n = 1:numel(zipFiles)
        tmpDir = tempname;
        mkdir(tmpDir);
        unzip(zipFiles{n}, tmpDir);

        % Flatten the archive: move every non-hidden file into Images/.
        files = dir(fullfile(tmpDir, '**', '*'));
        for k = 1:numel(files)
            if ~files(k).isdir && files(k).name(1) ~= '.'
                movefile(fullfile(files(k).folder, files(k).name), './TrainingData/Images/');
            end
        end
        rmdir(tmpDir, 's');
    end

    fprintf('Extracted image files from %s to TrainingData/Images.\n', strjoin(zipFiles, ', '));
end

%% Compute a saliency map for every image
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

    img = imread([imageDir imgList(i).name]);
    [numRows, numCols, ~] = size(img);

    % FES works in Lab colour space.
    img = RGB2Lab(img);

    % prior.mat ships with the FES repository and provides p1.
    load('prior');

    saliency = computeFinalSaliency(img, [8 8 8], [13 25 38], 30, 10, 1, p1);
    saliency = imresize(saliency, [numRows, numCols]);

    [~, name, ~] = fileparts(imgList(i).name);
    imwrite(saliency, [resultFolder, name, '.png']);
end

%% Zip the maps for download
zipFile = 'FES.zip';
fprintf('Creating zip file %s of results...\n', zipFile);
if ispc
    zip(zipFile, resultFolder);
else
    system(['zip -r ' zipFile ' ' resultFolder]);
end

fprintf('Processing complete. Results saved to %s\n', zipFile);
