function plot_rdms_and_coefficients(data_rdm, rdms, labels, regression_coefficients, roiName, outDir)
%PLOT_RDMS_AND_COEFFICIENTS Plots data RDM, model RDMs, and regression coefficients and saves the final plot.
%
%   plot_rdms_and_coefficients(data_rdm, rdms, labels, regression_coefficients, roiName, outDir)
%   visualizes the data RDM, model RDMs, and regression coefficients from RSA GLM.
%
%   Inputs:
%       data_rdm - The data RDM (square matrix).
%       rdms - Structure array of model RDMs with fields 'dsm' (RDM) and 'description' (name).
%       labels - Cell array of condition labels.
%       regression_coefficients - Regression coefficients from RSA GLM.
%       roiName - String specifying the region of interest (e.g., 'V1').
%       outDir - Directory where the plot will be saved.
%
%   Example:
%       plot_rdms_and_coefficients(data_rdm, rdms, labels, coefficients, 'V1', './output/');
%
% Andrea Costantino, 07/12/2024

    % Number of model RDMs
    num_model_rdms = numel(rdms);

    % Total columns: number of model RDMs plus 2 (for data RDM spanning two columns)
    num_cols = num_model_rdms + 2;

    % Set the figure size to be large enough
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1], 'Color', [220, 220, 220] / 255); % Full screen

    % Create the tiled layout
    t = tiledlayout(2, num_cols, 'TileSpacing', 'Compact', 'Padding', 'Compact');

    % Plot regression coefficients in row 1, columns 1 to num_model_rdms
    nexttile(1, [1, num_model_rdms]);
    bar(regression_coefficients, 'FaceColor', [0.2 0.6 0.5]);
    xticks(1:num_model_rdms);
    xticklabels({rdms.description});
    xtickangle(45);
    ylabel('Regression Coefficient');
    title('Regression Coefficients', 'FontSize', 14);
    set(gca, 'FontSize', 12);
    grid on;
    ylim([0, 1]); % Set the upper limit of y-axis to 1

    % Plot data RDM in columns num_model_rdms+1 to num_cols, spanning two rows
    nexttile(num_model_rdms + 1, [2, 2]);
    plot_rdm_full(data_rdm, labels, ['Data RDM: ' roiName]);

    % Plot model RDMs in row 2, columns 1 to num_model_rdms
    for i = 1:num_model_rdms
        nexttile(num_cols + i);
        model_rdm = rdms(i).dsm;
        emptyLabels = repmat({''}, size(labels));
        plot_rdm_full(model_rdm, emptyLabels, ['Model RDM: ' rdms(i).description]);
    end

    % Adjust layout
    t.TileSpacing = 'Compact';
    t.Padding = 'Compact';

    % Save the final plot if output directory and ROI name are provided
    if nargin > 4 && ~isempty(outDir) && ~isempty(roiName)
        % Ensure the output directory exists
        if ~exist(outDir, 'dir')
            mkdir(outDir); % Create the directory if it doesn't exist
        end

        % Define the file name
        fileName = sprintf('%s_RSA_regression.png', roiName);

        % Save the final figure
        saveas(gcf, fullfile(outDir, fileName));

        % Display a completion message
        disp(['RDM and regression plot saved to: ', fullfile(outDir, fileName)]);
    end
end
