%% DESCRIPTION

%{

Figure 3 - center/distance plots (change in phi, leads up to classification)
3 x 3 (2/3/4ch by awake/anest/difference)
difference - subtraction is easier to read

Note - figures up to figure 3 focus on 2.25s computation; 18s is used for
across fly analyses (for trying to extend within fly findings across flies)

%}

%% Setup

measure = 'phi_star_gaussian'; % 'phi_three' or 'phi_star' or 'phi_star_gaussian' or 'phi_SI'
tau = 1; % 1 = 4ms; 2 = 8ms; 3 = 16ms
if tau == 1
    tau_string = '4';
elseif tau == 2
    tau_string = '8';
elseif tau == 3
    tau_string = '16';
end

flies = (1:13);

% 0 for tpms/covariances constructed per trial, and for within fly analyses
% 1 for tpms/covariances constructed across trials, and for across fly analyses
global_tpm = 0;

fontsize = 11; % Used for drawing label letters

bin_location = '../';
addpath(bin_location);

%% Load files

[phis, measure_string] = phi_load(measure, global_tpm, bin_location);

%% Make figure

figure;
set(gcf, 'Position', [0 0 2100/2 750]);
set(gcf, 'Color', [1 1 1]);
set(gcf, 'InvertHardCopy', 'off'); % For keeping the black background when printing
% set(gcf, 'RendererMode', 'manual');
% set(gcf, 'Renderer', 'painters');

colormap(inferno());
subplot_counter = 1;
cbar_titles = {...
    [measure_string '_{W}'],...
    [measure_string '_{A}'],...
    [measure_string '_{W} / ' measure_string '_{A}']...
    };

nChannels_yAspects = [1 2 4] ./ 2;

ySpacing = 0.05;
xSpacing = 0.03;

yPortion = 0.7;
xPortion = 0.7;

textbox_width = 0.03;
text_labels = 'abcdefghi';

cbar_width = 0.01;
cbar_spacing = 0.08;

heights = [3/14 4/14 7/14] * yPortion; % y-axis doubles each time, x + 2x + 4x = 1
widths = ([1 1 1] * xPortion ./ 3) - cbar_width;

yStarts = (1-yPortion)/2 + fliplr([0 cumsum(fliplr(heights(2:end)))]);
xStarts = (1-xPortion)/3 + (0 : widths(1) : 1);
xStarts(2) = xStarts(2) + xSpacing;
xStarts(3) = xStarts(3) + cbar_width + xSpacing + cbar_spacing;

% Store values for stats
values_mapped = cell(size(phis));

for nChannels_counter = 1 : length(phis)
    nChannels = phis{nChannels_counter}.nChannels;
    channel_sets = double(phis{nChannels_counter}.channel_sets);
    
    % Get values to plot
    % Mean across trials and flies
    values = permute(mean(mean(phis{nChannels_counter}.phis(:, :, flies, :, tau), 2), 3), [1 4 2 3]);
    plot_values = zeros(size(values, 1), 3);
    plot_values(:, 1) = values(:, 1);
    plot_values(:, 2) = values(:, 2);
    plot_values(:, 3) = values(:, 1) ./ values(:, 2);
    
    % Set center / set path distance mapping
    centers = mean(channel_sets, 2); % Mean across channels in each set
    distances = channel_set_distances(channel_sets);
    
    % Store mapping
    values_mapped{nChannels_counter}.centers = centers;
    values_mapped{nChannels_counter}.distances = distances;
    values_mapped{nChannels_counter}.values = plot_values;
    
    % Find minimum delta among map values
    centers_deltas = pdist2(unique(centers), unique(centers));
    centers_deltas(centers_deltas==0) = NaN; % remove 0 distances
    centers_delta = min(centers_deltas(:));
    distances_deltas = pdist2(unique(distances), unique(distances));
    distances_deltas(distances_deltas==0) = NaN; % remove 0 distances
    distances_delta = min(distances_deltas(:));
    
    % Create space mapping (used for indexing into the mapped space)
    %     centers_axis = (min(centers) - (2*centers_delta) : centers_delta : max(centers) + (2*centers_delta)); % - and + delta is for padding
    %     distances_axis = (min(distances) - (2*distances_delta) : distances_delta : max(distances) + (2*distances_delta)); % - and + delta is for padding
    %     [centers_map, distances_map] = meshgrid(centers_axis, distances_axis);
    centers_axis = (min(channel_sets(:)) : centers_delta : max(channel_sets(:))+centers_delta); % range is from first channel to last channel; +delta is for padding (because of how pcolor works)
    distances_axis = (min(distances) : distances_delta : max(distances)+distances_delta); % range is from min to max
    [centers_map, distances_map] = meshgrid(centers_axis, distances_axis);
    
    % Map channel sets to 2D matrix (and average overlaps)
    for value_type = 1 : size(plot_values, 2)
        
        % Create mapped space
        values_map = zeros(size(centers_map)); % Will sum all values with the same coordinates
        values_map_counter = zeros(size(centers_map)); % Keeps count in each coordinate as to how many values have that coordinate
        
        % Populate mapped space
        for value_counter = 1 : size(plot_values, 1)
            x = find(abs(centers_axis - centers(value_counter)) < 0.00001, 1); % This gives the mapped x location
            y = find(distances_axis == distances(value_counter), 1); % This gives the mapped y location
            values_map(y, x) = values_map(y, x) + plot_values(value_counter, value_type); % matrix is (rows, columns), corresponding to (y, x)
            values_map_counter(y, x) = values_map_counter(y, x) + 1;
        end
        
        values_map_plot = values_map ./ values_map_counter; % We will use the NaN values for the black background (and maybe interpolation)
        
        % Interpolate values (linearly - each NaN will turn into the average of the cells immediately adjacent to it, excluding diagonals)
        min_value = min(values_map_plot(:)); % We will remove interpolations which are less than the original min value in the plot (to avoid 'ghost/shadow interpolations');
        values_adjacent = zeros(4, 1);
        for y = 2 : size(values_map_plot, 1) - 1
            for x = 2 : size(values_map_plot, 2) - 1
                if isnan(values_map_plot(y, x))
                    values_adjacent(1) = values_map_plot(y, x-1);
                    values_adjacent(2) = values_map_plot(y, x+1);
                    values_adjacent(3) = values_map_plot(y-1, x);
                    values_adjacent(4) = values_map_plot(y+1, x);
                    if sum(~isnan(values_adjacent)) > 2
                        %values_adjacent(isnan(values_adjacent)) = 0; % Deal with NaNs
                        %values_adjacent(values_adjacent < min_value) = 0; % Don't include 'shadow' interpolations
                        interpolated = mean(values_adjacent(~isnan(values_adjacent)));
                        if interpolated == 0
                            values_map_plot(y, x) = NaN; % Place NaN instead of 0 to avoid affecting the color scaling
                        else
                            values_map_plot(y, x) = interpolated;
                        end
                    end
                end
            end
        end
        
        if value_type == 1
            % Create storage matrix for all value types
            values_map_plots = zeros([size(values_map_plot) size(plot_values, 2)]);
        end
        values_map_plots(:, :, value_type) = values_map_plot;
    end
    
    % Consistent colorbar within set size
    clim = [min(min(plot_values(:, 1:2))) max(max(plot_values(:, 1:2)))];
    
    % Plot
    xCounter = 1;
    for value_type = 1 : size(plot_values, 2)
        subplot(length(phis), size(plot_values, 2), subplot_counter);
        set(gca, 'Position', [xStarts(xCounter) yStarts(nChannels_counter)+ySpacing, widths(xCounter), heights(nChannels_counter)-ySpacing]);
        
        plot = pcolor(values_map_plots(:, :, value_type));
        
        axis_defaults(gca);
        
        set(gca, 'TickDir', 'out');
        set(gca, 'Box', 'off');
        
        if value_type < 3
            
            % Set shared colour axis
            caxis(clim);
            
        end
        if value_type > 1
            
            % Add colorbar (and reposition)
            ax_pos = get(gca, 'Position');
            c = colorbar;
            set(c, 'Position', [ax_pos(1)+ax_pos(3) ax_pos(2) cbar_width ax_pos(4)]); % Reposition colourbar directly next to plot
            set(c, 'Box', 'on');
            c.Ruler.Exponent = 0; % Get rid of scientific notation
            %set(c, 'Ticks', [1, ], 'TickLabels', [])% label min, mid, max values
            clims = get(c, 'Limits');
            set(c, 'Ticks', linspace(clims(1), clims(2), 3)); % Set ticks to be min, mid, and max
            if nChannels_counter == 1 % Set decimal places to display
                c.Ruler.TickLabelFormat = '%.4f';
            else
                c.Ruler.TickLabelFormat = '%.3f';
            end
            if value_type == 3
                c.Ruler.TickLabelFormat = '%.2f';
            end
            set(gca, 'Position', ax_pos); % Reposition plot to original specs
            
            % Hide YTicks
            %set(gca, 'YTick', []);
            set(gca, 'YTickLabel', []);
        end
        
        if nChannels_counter == 1
            title(cbar_titles{value_type});
        end
        
        set(gca, 'XTick', [1.5 ceil(length(centers_axis)/2)+0.5 length(centers_axis)-0.5]);
        set(gca, 'YTick', [1.5 ceil(length(distances_axis)/2)+0.5 length(distances_axis)-0.5]);
        
        if value_type == 1
            set(gca, 'YTickLabel', [min(distances) median(distances) max(distances)]);
        end
        
        if nChannels_counter == 3 && value_type == 1
            set(gca, 'XTickLabel', [1 median(centers) 15]);
        else
            set(gca, 'XTickLabel', []);
        end
        
        % X and Y axis labels
        if nChannels_counter == 3 && value_type == 2
            xlabel('set centre');
        end
        if nChannels_counter == 2 && value_type == 1
            ylabel('set path distance');
        end
        
        set(gca, 'color', [1 1 1]); % black background
        set(plot, 'EdgeColor', 'none'); % remove grid outline
        
        % Add letter label to plot
        ax_pos = get(gca, 'Position');
        axes('Visible', 'off', 'Position', [ax_pos(1) ax_pos(2)+ax_pos(4) textbox_width textbox_width]); axis_defaults(gca);
        text(0, 0.2, text_labels(subplot_counter), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', fontsize, 'FontWeight', 'bold');
        
        subplot_counter = subplot_counter + 1;
        xCounter = xCounter + 1;
    end
end

%% Print figure

% figure_name = 'fig3'; % 'fig3' for phi-3; 'figS1' for phi-star-gaussian
% 
% print(figure_name, '-dsvg'); % SVG
% print(figure_name, '-dpdf', '-bestfit'); % PDF
% print(figure_name, '-dpng'); % PNG

%% Stats
% Correlations with set center / set distance (no splitting)

sigs = zeros(3, 3, 2); % 2,3,4 channels x w,a,w/a x parameter
rs = zeros(3, 3, 2);
for nChannels = 1 : length(values_mapped)
    for value_type = 1 : size(values_mapped{1}.values, 2)
        [r, p] = corr([values_mapped{nChannels}.values(:, value_type) values_mapped{nChannels}.centers]);
        sigs(nChannels, value_type, 1) = p(1, 2);
        rs(nChannels, value_type, 1) = r(1, 2);
        
        [r, p] = corr([values_mapped{nChannels}.values(:, value_type) values_mapped{nChannels}.distances]);
        sigs(nChannels, value_type, 2) = p(1, 2);
        rs(nChannels, value_type, 2) = r(1, 2);
    end
end

%%

% Correlation with set center after splitting based on center value
value_type = 1; % 1 = wake; 2 = anest; 3 = wake/anest (or wake-anest, depending on what the figure is plotting)

sigs = [];
counter = 1;
for nChannels = 1 : length(values_mapped)
    
    middle = median(values_mapped{nChannels}.centers);
    
    below = values_mapped{nChannels}.centers < middle;
    above = ~below; % The middle value is included in the top half
    
    [r, p] = corr([values_mapped{nChannels}.values(below, value_type) values_mapped{nChannels}.centers(below)]);
    sigs(counter) = p(1, 2);
    disp(['nChannels' num2str(nChannels) ' ' num2str(value_type) ' below r=' num2str(r(1, 2)) ' p=' num2str(p(1, 2))]);
    
    [r, p] = corr([values_mapped{nChannels}.values(above, value_type) values_mapped{nChannels}.centers(above)]);
    sigs(counter+1) = p(1, 2);
    disp(['nChannels' num2str(nChannels) ' ' num2str(value_type) ' above r=' num2str(r(1, 2)) ' p=' num2str(p(1, 2))]);
    
    counter = counter + 2;
end

%%

% Correlation(distance from middle set center, phi values)
value_type = 2; % 1 = wake; 2 = anest; 3 = wake/anest (or wake-anest, depending on what the figure is plotting)

sigs = [];
counter = 1;
for nChannels = 1 : length(values_mapped)
    subplot(1, 3, nChannels);
    
    middle = median(values_mapped{nChannels}.centers);
    
    dist_from_mid = abs(middle - values_mapped{nChannels}.centers);
    
    [r, p] = corr([values_mapped{nChannels}.values(:, value_type) dist_from_mid]);
    sigs(counter) = p(1, 2);
    disp(['nChannels' num2str(nChannels) ': r=' num2str(r(1, 2)) ' p=' num2str(p(1, 2))]);
    
    counter = counter + 1;
end

