function plot_activation_heatmap(ds, label_names, roiName, outDir)
%PLOT_ACTIVATION_HEATMAP Plots and saves an activation heatmap for a CosmoMVPA dataset with image labels.
%
%   plot_activation_heatmap(ds, label_names, roiName, outDir) normalizes
%   activations, plots a heatmap with image labels, and saves it to 'outDir'.
%
%   Input:
%       ds - CosmoMVPA dataset structure containing the data.
%       label_names - Cell array of category labels for the observations.
%       roiName - String specifying the region of interest (e.g., 'V1').
%       outDir - Directory where the plot will be saved.
%
%   Example:
%       plot_activation_heatmap(ds, label_names, 'V1', './output/');
%
% Andrea Costantino, 07/12/2024

    % Normalize samples for visualization
    ds_mean = cosmo_fx(ds, @(x) mean(x, 1), 'targets');
    normalized_samples = (ds_mean.samples - min(ds_mean.samples(:))) / ...
        (max(ds_mean.samples(:)) - min(ds_mean.samples(:)));

    % Prepare data with white space between rows
    n_rows = size(normalized_samples, 1);
    n_cols = size(normalized_samples, 2);

    % Initialize display_samples with NaNs to create white spaces
    display_samples = NaN(n_rows * 2 - 1, n_cols);

    % Fill display_samples with normalized_samples in odd rows
    for i = 1:n_rows
        display_samples(i * 2 - 1, :) = normalized_samples(i, :);
    end

    % Map label names to corresponding image files
    label_to_image = containers.Map( ...
        {'human face', 'human body', 'animal face', 'animal body', ...
         'natural round', 'natural spiky', 'artificial round', 'artificial spiky'}, ...
        { 'stimuli/human-face.png', ...
          'stimuli/human-body.png', ...
          'stimuli/animal-face.png', ...
          'stimuli/animal-body.png', ...
          'stimuli/natural-round.png', ...
          'stimuli/natural-spiky.png', ...
          'stimuli/artificial-round.png', ...
          'stimuli/artificial-spiky.png'} );

    % Plot the heatmap
    figure;

    % Plot the heatmap with imagesc and set NaN values to be transparent
    imagesc(display_samples, 'AlphaData', ~isnan(display_samples));

    % Adjust the aspect ratio to make each cell square
    axis equal tight;
    axis ij; % To display the first row at the top

    % Set the figure size to be large enough
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1], 'Color', [220, 220, 220] / 255); % Full screen

    % Adjust colormap
    if exist('brewermap', 'file')
        colormap(brewermap([], 'RdBu'));
    else
        colormap(parula);
    end
    colorbar;

    % Set labels and title with larger font size
    xlabel('Voxel (Beta value)', 'FontSize', 14);
    ylabel('Stimulus', 'FontSize', 14);
    title(sprintf('Activation Heatmap for ROI: %s', roiName), 'FontSize', 16);

    % Position and render images as labels
    y_positions = 1:2:(n_rows * 2 - 1); % Y positions of labels
    x_margin = -0.5; % Position images slightly left of the heatmap
    for i = 1:length(label_names)
        current_label = label_names{i};
        if isKey(label_to_image, current_label)
            img_file = label_to_image(current_label);
            if exist(img_file, 'file')
                [im, ~, alpha] = imread(img_file);

                % Normalize and handle alpha transparency
                if isempty(alpha)
                    alpha = ones(size(im, 1), size(im, 2));
                end
                im = double(im) / 255;

                % Aspect ratio and size for consistent scaling
                [img_height_original, img_width_original, ~] = size(im);
                aspect_ratio = img_width_original / img_height_original;
                img_height = 1.5; % Set image height in axis units
                img_width = img_height * aspect_ratio;

                % Render the image
                h_img = image('CData', im, ...
                    'XData', [x_margin - img_width, x_margin], ...
                    'YData', [y_positions(i) - img_height / 2, y_positions(i) + img_height / 2]);
                set(h_img, 'AlphaData', alpha);
            else
                warning('Image file not found for label: %s', current_label);
            end
        else
            warning('No image mapping found for label: %s', current_label);
        end
    end

    % axis tight; axis padded; % Adds padding around the heatmap
ax = gca;
ax.XTick = []; % Turn off x-axis ticks
ax.YTick = []; % Turn off y-axis ticks

    % Adjust axes limits to avoid extra space
    xlim([x_margin-4, n_cols + 2]); % Extend x-limits for labels
    ylim([0.5-2, n_rows * 2 + 2]);


% ax.Position = ax.Position + [-0.05 -0.05 0.1 0.1]; % Expand axes for additional padding

    % Save the plot
    if ~exist(outDir, 'dir')
        mkdir(outDir); % Create the directory if it doesn't exist
    end

    % Create a descriptive file name
    fileName = sprintf('%s_Activation_Heatmap.png', roiName);

    % Save the figure
    saveas(gcf, fullfile(outDir, fileName));

    % Display a message indicating completion
    disp(['Activation heatmap created and saved to: ', fullfile(outDir, fileName)]);
end
