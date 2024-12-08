function plot_rdm_full(rdm_matrix, labels, title_str)
% Plot the RDM
%
% Andrea Costantino, 07/12/2024
imagesc(rdm_matrix);
if exist('brewermap', 'file')
    colormap(brewermap([], 'RdBu'));
else
    colormap(parula);
end
colorbar;
axis square;
xticks(1:length(labels));
yticks(1:length(labels));
xticklabels(labels);
yticklabels(labels);
xtickangle(45);
clim([0, 2]);
title(title_str, 'FontSize', 14);
xlabel('Condition'); ylabel('Condition');
set(gca, 'FontSize', 12);
end
