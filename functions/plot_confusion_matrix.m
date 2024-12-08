function plot_confusion_matrix(true_labels, predicted_labels, n_categories, accuracy, label_names, roiName, outDir)
%PLOT_CONFUSION_MATRIX Plots and saves a confusion matrix.
%
%   plot_confusion_matrix(true_labels, predicted_labels, n_categories, 
%   accuracy, label_names, roiName, outDir) computes the confusion matrix
%   from true and predicted labels, displays it, and saves it to 'outDir'
%   with a descriptive file name.
%
%   Input:
%       true_labels - Ground truth labels.
%       predicted_labels - Predicted labels from the classifier.
%       n_categories - Number of categories/classes.
%       accuracy - Classification accuracy.
%       label_names - Cell array of category labels.
%       roiName - String specifying the region of interest (e.g., 'V1').
%       outDir - Directory where the plot will be saved.
%
%   Example:
%       plot_confusion_matrix(true_labels, predicted_labels, 8, 0.85, ...
%           label_names, 'V1', './output/');
%
% Andrea Costantino, 07/12/2024

    % Compute the confusion matrix
    confusion_matrix = cosmo_confusion_matrix(true_labels, predicted_labels);
    confusion_matrix = sum(confusion_matrix, 3); % Sum over folds if necessary

    % Plot the confusion matrix
    figure;
    imagesc(confusion_matrix, [0, max(confusion_matrix(:))]);
    colormap("sky"); % Blue colormap
    colorbar;

    % Adjust the aspect ratio to make each cell square
    axis equal tight;

    % Set the figure size to be large enough
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .5 .5], 'Color', [220, 220, 220] / 255); % Full screen

    % Add text annotations
    textStrings = num2str(confusion_matrix(:), '%d'); % Convert counts to strings
    textStrings = strtrim(cellstr(textStrings));      % Remove whitespace
    [x, y] = meshgrid(1:n_categories);               % Create grid for text placement
    hStrings = text(x(:), y(:), textStrings(:));     % Add text to the plot
    set(hStrings, 'HorizontalAlignment', 'center', 'Color', 'white');

    % Use labels for axis ticks
    xticks(1:n_categories); yticks(1:n_categories);
    xticklabels(label_names); yticklabels(label_names);

    % Adjust axis and add title
    title(sprintf('Confusion Matrix for ROI: %s (Accuracy = %.2f%%)', roiName, accuracy * 100), ...
        'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Predicted Class', 'FontSize', 12);
    ylabel('True Class', 'FontSize', 12);
    axis square;

    % Save the plot
    if ~exist(outDir, 'dir')
        mkdir(outDir); % Create the directory if it doesn't exist
    end

    % Create a descriptive file name
    fileName = sprintf('%s_Confusion_Matrix.png', roiName);

    % Save the figure
    saveas(gcf, fullfile(outDir, fileName));

    % Display a message indicating completion
    disp(['Confusion matrix plot created and saved to: ', fullfile(outDir, fileName)]);
end
