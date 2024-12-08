% Function to cluster similar classes
function updated_ds = cluster_similar_classes(dataset, target_labels, sigma_level)
% Modify dataset to cluster similar classes by blending with a common pattern
%
% INPUT:
%   dataset - The dataset structure with 'samples' and 'sa.targets'
%   target_labels - A vector of target labels to cluster
%   sigma_level - A value between 0 and 1 controlling the similarity
%
% OUTPUT:
%   updated_ds - The modified dataset
%
% Andrea Costantino, 07/12/2024

% Extract target labels from dataset
labels = dataset.sa.targets;

% Find indices of observations with the specified target labels
target_idx = ismember(labels, target_labels);

% Ensure there are matching observations
if ~any(target_idx)
    error('No matching observations found for the specified target labels.');
end

% If sigma_level is 0, return the dataset without modifications
if sigma_level == 0
    updated_ds = dataset;
    return;
end

% Get the number of features (columns) in the samples matrix
num_columns = size(dataset.samples, 2);

% Determine the number of features to modify based on sigma_level
num_features_to_modify = round(sigma_level * num_columns);

% Randomly select columns to modify
cols_to_modify = randperm(num_columns, num_features_to_modify);

% Generate a common pattern for the cluster
% Scale the pattern magnitude to match the data's standard deviation
pattern_magnitude = std(dataset.samples(:));
pattern = randn(1, num_columns) * pattern_magnitude;

% Only keep the pattern values for the selected columns
pattern_mask = zeros(1, num_columns);
pattern_mask(cols_to_modify) = 1;
pattern = pattern .* pattern_mask;

% Apply the pattern to the selected observations
dataset.samples(target_idx, :) = ...
    (1 - sigma_level) * dataset.samples(target_idx, :) + ...
    sigma_level * repmat(pattern, sum(target_idx), 1);

% Return the modified dataset
updated_ds = dataset;
end
