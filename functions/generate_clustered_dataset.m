function ds = generate_clustered_dataset(n_categories, n_subj, n_runs, n_reps, sigma, seed, roi, size)
% GENERATE_CLUSTERED_DATASET Generates a clustered synthetic dataset.
%
% INPUTS:
%   n_categories - Number of target categories
%   n_subj       - Number of subjects
%   n_runs       - Number of simulated runs (chunks)
%   n_reps       - Number of repetitions per condition
%   sigma        - Standard deviation for the synthetic dataset
%   seed         - Random seed for reproducibility
%
% OUTPUT:
%   ds           - Clustered dataset structure
%
% The function generates a synthetic dataset using CosmoMVPA, defines
% clusters with associated sigma levels, and applies the clustering logic.
%
% Andrea Costantino, 07/12/2024

% Generate a synthetic dataset
ds = cosmo_synthetic_dataset( ...
    'size', size, ...
    'sigma', sigma, ...
    'ntargets', n_categories, ...
    'nsubjects', n_subj, ...
    'nchunks', n_runs, ...
    'nreps', n_reps, ...
    'seed', seed);

% Define clusters as an array of structures
if roi == "IT"
    clusters = [
        struct('targets', [1, 2, 3, 4], 'sigma_level', 0.7, 'description', 'Animate'), ...
        struct('targets', [1, 2], 'sigma_level', 0.2, 'description', 'Humans'), ...
        struct('targets', [3, 4], 'sigma_level', 0.2, 'description', 'Animals'), ...
        struct('targets', [5, 6], 'sigma_level', 0.7, 'description', 'Natural'), ...
        struct('targets', [7, 8], 'sigma_level', 0.6, 'description', 'Artificial') ...
        ];
else
    clusters = [
    struct('targets', [1, 3, 5, 7], 'sigma_level', 0.4, 'description', 'Round'), ...
    struct('targets', [2, 4, 6, 8], 'sigma_level', 0.4, 'description', 'Spiky'), ...
    ];
end

% Apply clustering to the dataset
ds = apply_clustering(ds, clusters);

% Display cluster information
fprintf('Generated dataset with the following clusters:\n');
for i = 1:numel(clusters)
    fprintf('Cluster %d: %s\n', i, clusters(i).description);
    fprintf('  Targets: [%s]\n', num2str(clusters(i).targets));
    fprintf('  Sigma Level: %.2f\n\n', clusters(i).sigma_level);
end

% Define the mapping of targets to human-readable labels
target_to_label = containers.Map( ...
    {1, 2, 3, 4, 5, 6, 7, 8}, ... % Targets
    { ...
    'human face', ...       % 1
    'human body', ...       % 2
    'animal face', ...      % 3
    'animal body', ...      % 4
    'natural round', ...    % 5
    'natural spiky', ...    % 6
    'artificial round', ... % 7
    'artificial spiky' ...  % 8
    });

% Assign the corresponding label to each target
ds.sa.labels = arrayfun(@(x) target_to_label(x), ds.sa.targets, 'UniformOutput', false);

end
