function plot_mds(ds, roiName, outDir)
%PLOT_MDS Creates a 2D MDS plot from a CosmoMVPA dataset, labeling points with images.
%
%   plot_mds(ds, roiName, outDir) computes the pairwise dissimilarities
%   between conditions in the dataset 'ds' and performs multidimensional
%   scaling (MDS) to project the data into a 2D space. Instead of using text
%   labels and markers, it uses corresponding stimulus images placed at the 
%   coordinates.
%
%   Input:
%       ds      - CosmoMVPA dataset structure containing the data.
%       roiName - String specifying the ROI name for the title of the plot.
%       outDir  - Output directory where the MDS plot image will be saved.
%
%   Example:
%       plot_mds(ds, 'ROI_example', './output');
%
% Andrea Costantino, 07/12/2024

    % Ensure the dataset is valid
    cosmo_check_dataset(ds);

    % Average data across runs for each condition to get one sample per condition
    ds_mean = cosmo_fx(ds, @(x) mean(x, 1), 'targets');

    % Retrieve condition labels
    labels       = ds_mean.sa.labels;
    uniqueLabels = unique(labels, 'stable');

    % Compute pairwise dissimilarity (correlation distance)
    dissimilarityMatrix = pdist(ds_mean.samples, 'correlation');

    % Perform multidimensional scaling (MDS) to project data into 2D space
    mdsCoordinates = mdscale(dissimilarityMatrix, 2, 'Criterion', 'metricstress');

    % Define the mapping of targets to human-readable labels (already in ds)
    % The original code snippet suggests these labels are in ds_mean.sa.labels
    % and matches the unique labels we have.
    % We now map these labels to the corresponding stimulus image files:
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

    % Create a figure for the MDS plot
    figure('Color', 'w');
    hold on;
    grid on;
    box on;

    % Set the figure size to be large enough
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .5 .5], 'Color', [220, 220, 220] / 255);

for i = 1:length(labels)
    currentLabel = labels{i};
    if isKey(label_to_image, currentLabel)
        imgFile = label_to_image(currentLabel);
        if exist(imgFile, 'file')
            [im, ~, alpha] = imread(imgFile); % Load image and alpha channel if present
            
            % Handle alpha transparency for PNGs; set alpha to 1 (opaque) for non-PNGs
            if isempty(alpha)
                [~, ~, ext] = fileparts(imgFile);
                if strcmpi(ext, '.png')
                    alpha = ones(size(im, 1), size(im, 2)); % Assume fully opaque if no alpha provided
                else
                    alpha = []; % For non-PNG formats like JPEG
                end
            end

            % Fix color normalization issues
            if max(im(:)) > 1.0
                im = double(im) / 255; % Normalize to [0, 1]
            end

            % Ensure consistent color mapping for 3-channel images
            if size(im, 3) == 1 % Grayscale image
                im = repmat(im, [1, 1, 3]); % Convert to RGB by replicating channels
            end

            % Determine the aspect ratio
            [imgHeightOriginal, imgWidthOriginal, ~] = size(im);
            aspectRatio = imgWidthOriginal / imgHeightOriginal;

            % Set image size while maintaining aspect ratio
            xRange = max(mdsCoordinates(:,1)) - min(mdsCoordinates(:,1));
            imgHeight = xRange * 0.2; % Base size multiplier (adjustable)
            imgWidth = imgHeight * aspectRatio;

            % Coordinates for this data point
            xPos = mdsCoordinates(i, 1);
            yPos = mdsCoordinates(i, 2);

            % Place the image at the specified point
            hImg = image('CData', im, ...
                'XData', [xPos - imgWidth/2, xPos + imgWidth/2], ...
                'YData', [yPos + imgHeight/2, yPos - imgHeight/2]);

            % Apply transparency (alpha) if available
            if ~isempty(alpha)
                set(hImg, 'AlphaData', alpha);
            end
        else
            warning('Image file not found for label: %s', currentLabel);
        end
    else
        warning('No image mapping found for label: %s', currentLabel);
    end
end
    % Set axis labels and title
    xlabel('Dimension 1', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Dimension 2', 'FontSize', 14, 'FontWeight', 'bold');
    title(sprintf('2D MDS Plot for ROI: %s', roiName), ...
        'FontSize', 16, 'FontWeight', 'bold');

    % Enhance plot aesthetics
    set(gca, 'FontSize', 12, 'LineWidth', 1.5,  'DataAspectRatio', [1 1 1]);

    hold off;

    % Save the plot
    if ~exist(outDir, 'dir')
        mkdir(outDir); % Create the directory if it doesn't exist
    end

    % Create a descriptive file name
    fileName = sprintf('%s_MDS_Plot_.png', roiName);

    % Save the figure
    saveas(gcf, fullfile(outDir, fileName));

    % Display a message indicating completion
    disp(['MDS plot created and saved to: ', fullfile(outDir, fileName)]);

end
