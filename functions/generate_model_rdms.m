function rdms = generate_model_rdms(n_categories)
% GENERATE_MODEL_RDMS Generates dissimilarity matrices (RDMs) based on clusters.
%
% INPUTS:
%   n_categories - Number of target categories
%
% OUTPUT:
%   rdms - A structure array containing dissimilarity matrices (RDMs) for each clustering scheme.
%
% Andrea Costantino, 07/12/2024

% Define clustering schemes
clustering_schemes = {
    struct('description', 'Animate vs. Inanimate', 'clusters', [
        struct('targets', [1, 2, 3, 4], 'description', 'Animate'), ...
        struct('targets', [5, 6, 7, 8], 'description', 'Inanimate')
    ]),
    struct('description', 'Grouped Pairs', 'clusters', [
        struct('targets', [1, 2], 'description', 'Humans'), ...
        struct('targets', [3, 4], 'description', 'Animals'), ...
        struct('targets', [5, 6], 'description', 'Natural Objects'), ...
        struct('targets', [7, 8], 'description', 'Artificial Objects')
    ]),
    struct('description', 'Round vs. Spiky', 'clusters', [
        struct('targets', [2, 4, 6, 8], 'description', 'Even Categories'), ...
        struct('targets', [1, 3, 5, 7], 'description', 'Odd Categories')
    ])
};

% Initialize output structure
rdms = struct([]);

% Generate dissimilarity matrices
for i = 1:numel(clustering_schemes)
    scheme = clustering_schemes{i};
    clusters = scheme.clusters;
    
    % Create an empty dissimilarity matrix
    dsm = 2 * ones(n_categories); % Initialize with dissimilarity = 2
    
    % Assign dissimilarity = 0 for within-cluster comparisons
    for cluster = clusters
        target_indices = cluster.targets;
        dsm(target_indices, target_indices) = 0; % Set within-cluster comparisons to 0
    end
    
    % Store RDM and metadata
    rdms(i).description = scheme.description;
    rdms(i).dsm = dsm;
    rdms(i).clusters = clusters;
end

end
