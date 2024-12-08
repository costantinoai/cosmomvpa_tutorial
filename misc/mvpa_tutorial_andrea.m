%% CoSMoMVPA Workshop Script
% Demonstrates basic usage of CoSMoMVPA for Multivariate Pattern Analysis (MVPA) 
% and Representational Similarity Analysis (RSA) on fMRI data.
%
% --------------------------------
% Data Pre-processing and Analysis
% --------------------------------
% For real data, the following prior steps are expected:
% 
% 1. **Data Acquisition**:
%    - Collect functional MRI data during an experiment that manipulates categories 
%      of interest (e.g., visual stimuli such as faces, bodies, objects).
%
% 2. **BIDS Conversion**:
%    - Convert raw fMRI data into the BIDS (Brain Imaging Data Structure) format.
%    - BIDS ensures standardized data organization, simplifying preprocessing and analysis.
%
% 3. **Preprocessing (Ideally in fMRIPrep)**:
%    - Perform minimal preprocessing using fMRIPrep:
%      - Align functional images to anatomical data and normalize them to a common space.
%      - Avoid excessive spatial smoothing or denoising, as these can distort fine-grained 
%        patterns that are crucial for decoding neural representations in MVPA.
%
% 4. **GLM Estimation**:
%    - Use a General Linear Model (GLM) to estimate neural activation (beta images) for 
%      each experimental condition (e.g., categories of visual stimuli).
%    - The result is a folder containing:
%      - **Beta images**: One per condition (category) and run.
%      - **SPM.mat**: Metadata about the GLM and experiment design.
%
% 5. **Defining Regions of Interest (ROIs)**:
%    - Use precomputed masks to restrict the analysis to brain areas of interest.
%    - In this script, we analyze:
%      - **Inferotemporal Cortex (IT)**: Processes categorical, abstract information.
%      - **Primary Visual Cortex (V1)**: Processes perceptual, low-level visual information.
%
% ----------------------
% Purpose of This Script
% ----------------------
% For this tutorial, we generate synthetic data rather than using real fMRI data. 
% The synthetic data generation is designed to mimic the processing properties of 
% IT and V1. This allows us to:
% - Focus on understanding MVPA and RSA methods without needing real data.
% - Simulate well-controlled scenarios to explore key concepts and analyses.
%
% The goal is to investigate the representational geometry of two ROIs, V1 and IT, 
% to determine what properties of the stimuli are represented in these areas.
%
% ----------------------
% Synthetic Data Details
% ----------------------
% In this tutorial, synthetic data is generated with the following characteristics:
%
% - **Subjects**: One subject.
% - **Runs**: Ten runs per subject.
% - **Categories**: Eight distinct categories:
%     - 'Human face', 'Human body', 'Animal face', 'Animal body',
%       'Natural round', 'Natural spiky', 'Artificial round', 'Artificial spiky'.
% 
% - **Beta Images**: Each category has one beta image per run (similar to outputs from a GLM in SPM).
% - **ROI Simulations**:
%     - **V1**: Simulates sensitivity to low-level perceptual similarities (e.g., shape-based 
%       similarities like "round" vs. "spiky" objects).
%     - **IT**: Simulates sensitivity to high-level conceptual similarities (e.g., 
%       "human faces" and "human bodies" are more similar than "human faces" and "animal faces").
%
% ----------------------
% Representational Assumptions
% ----------------------
% The generated data reflects the following representational structures:
% - V1: **Perceptual Similarity**: Faces and round objects are similar; bodies and spiky objects are similar.
% - IT: **Categorical Similarity**: Human faces and bodies are more similar than animal faces and bodies.
% - IT: **Animate vs. Inanimate**: Animals and humans (animate) are more similar than inanimate objects.
% - IT: **Natural vs. Artificial**: Natural objects differ significantly from artificial objects.
%
% ----------------------
% Outputs
% ----------------------
% This script computes:
% 1. **Decoding Accuracies**: Decoding performance for different categories within each ROI.
% 2. **RSA Comparisons**: Evaluations of representational dissimilarity matrices (RDMs) in V1 and IT 
%    against theoretical models to determine which representational geometry better matches the data.
%
% Author: Andrea Costantino
% Created: 08/12/2024


% Clear workspace, close figures, and reset command window
clear all;
close all;
clc;

% Set random number generator seed for reproducibility
seed = 42;
rng(seed);

% Add necessary paths and define output directory
addpath("functions/");
outDir = fullfile(pwd, "results");

%% Data Import from SPM (Optional)
% % Specify the path to the SPM.mat file or directory containing SPM files
% spm_path = [data_dir '/betas/SPM.mat'];
%
% % Specify path for ROI mask image
% mask_path = [data_dir '/betas/IT_ROI_mask.nii'];
%
% % Load SPM data using CosmoMVPA
% ds = cosmo_fmri_dataset(spm_path, 'mask', mask_path);

%% Synthetic Data Generation
% Parameters for synthetic data generation
numCategories = 8;       % Number of categories/classes
numRuns = 10;            % Number of runs (folds)
numSubjects = 1;         % Number of subjects
numRepetitions = 1;      % Number of repetitions per condition
size = "normal";

% Define Region of Interest (ROI)
roiName = "IT";     % Inferotemporal Cortex (IT)
% roiName = "V1";   % Visual Cortex (V1)

% Generate synthetic clustered data for the current ROI
sigma = .6;  % Standard deviation for synthetic data
ds = generate_clustered_dataset( ...
    numCategories, ...   % Number of categories
    numSubjects, ...     % Number of subjects
    numRuns, ...         % Number of runs
    numRepetitions, ...  % Number of repetitions
    sigma, ...           % Data variability
    seed, ...            % Random seed for reproducibility
    roiName, ...         % Current ROI
    size ...             % Dataset size type
);

%% Visualization: Activation Heatmap
% Extract and display unique labels
labelNames = unique(ds.sa.labels, 'stable');
disp('Target to Label Mapping:');
disp(table(ds.sa.targets, ds.sa.labels));

% Plot activation heatmap
plot_activation_heatmap( ...
    ds, ...           % Dataset
    labelNames, ...   % Unique labels
    roiName, ...      % Current ROI
    outDir ...        % Output directory
);

%% Classification Analysis
% Define classifier (e.g., Linear Discriminant Analysis)
classifier = @cosmo_classify_lda;

% Define cross-validation partitions (n-fold)
partitions = cosmo_nfold_partitioner(ds);

% Perform cross-validation
[predictedLabels, accuracy] = cosmo_crossvalidate(ds, classifier, partitions);

% Compute chance-level accuracy
chanceLevel = 1 / numCategories;

% Display classification accuracy
fprintf('Classification accuracy: %.2f%% (chance level: %.2f%%)\n', accuracy * 100, chanceLevel * 100);

% Plot confusion matrix
plot_confusion_matrix( ...
    ds.sa.targets, ...      % True labels (targets)
    predictedLabels, ...    % Predicted labels
    numCategories, ...      % Number of categories
    accuracy, ...           % Classification accuracy
    labelNames, ...         % Category labels
    roiName, ...            % Current ROI
    outDir ...              % Output directory
);

%% Representational Dissimilarity Matrices (RDMs)
% Compute mean dataset across runs for each target
dsMean = cosmo_fx(ds, @(x) mean(x, 1), 'targets');

% Visualize 2D projections
plot_mds( ...
    ds, ...      % Dataset
    roiName, ... % Current ROI
    outDir ...   % Output directory
);

% Set CoSMoMVPA parameters to calculate the RDM
measureDsm = @cosmo_dissimilarity_matrix_measure;
argsDsm.metric = 'correlation';        % Correlation distance (1 - correlation)
argsDsm.center_data = true;            % Center data before calculation

% Calculate the RDM
dataDsm = measureDsm(dsMean, argsDsm); % Flat distance vector
dataRdm = squareform(dataDsm.samples); % Convert to square matrix

% Generate model RDMs
rdms = generate_model_rdms(numCategories);

%% Representational Similarity Analysis (RSA)
% Set up measure arguments for RSA regression
measure = @cosmo_target_dsm_corr_measure;
measureArgs = struct();
measureArgs.center_data = true;

% Prepare regressor RDMs (one RDM per cell)
regressorRDMs = cellfun(@(x) squareform(x)', {rdms.dsm}, 'UniformOutput', false);
measureArgs.glm_dsm = regressorRDMs;

% Perform RSA regression
result = measure(dsMean, measureArgs);

% Extract and visualize results
labels = dsMean.sa.labels;
plot_rdms_and_coefficients( ...
    dataRdm, ...           % Observed data RDM
    rdms, ...              % Model RDMs
    labels, ...            % Labels for axes
    result.samples, ...    % Regression coefficients
    roiName, ...           % Current ROI
    outDir ...             % Output directory
);
