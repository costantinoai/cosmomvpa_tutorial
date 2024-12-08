% Function to apply clustering to the dataset
%
% Andrea Costantino, 07/12/2024

function updated_ds = apply_clustering(dataset, clusters)
% Apply clustering to the dataset based on specified clusters and sigma_levels
for i = 1:numel(clusters)
    cluster = clusters(i);
    dataset = cluster_similar_classes(dataset, cluster.targets, cluster.sigma_level);
end
updated_ds = dataset;
end
