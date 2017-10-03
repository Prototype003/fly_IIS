%% DESCRIPTION

%{
This is for plotting of raw phi values
%}

%% SETUP

star_metric = 'phi_stars';

flies = (1:13); %[1 2 3 4 5 6 7 9 10 11 12 13];

data_nChannels = '2t4';
data_detrended = 0;
data_zscored = 0;

filter_percent = 5; % 0 to 100 %

tau_colours = {'r', 'g', 'b'};
tau_alphas = [1 0.8 0.5];

data_directory = 'results/';
data_filename = ['split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim'...
    '_detrend' num2str(data_detrended)...
    '_zscore' num2str(data_zscored)...
    '_nChannels' data_nChannels...
    %'_shareFiltered'
    ];

%% LOAD

disp('loading');
% Phi-3
load([data_directory data_filename '_phithree.mat']);
phi_threes = phis;

% Phi-star
load([data_directory data_filename '_phistar.mat']);
phi_stars = phis;

disp('loaded');

for nChannels_counter = 1 : length(phi_threes)
    phi_threes{nChannels_counter}.phis = phi_threes{nChannels_counter}.phi_threes;
    phi_stars{nChannels_counter}.phis = phi_stars{nChannels_counter}.phi_stars;
end

%% Sort channel sets by phi
% Sort, within channels-used, by air phi
% Sort within fly (so the first average channel set can be different among flies) - thus the average across flies will be across different sets also
% Not valid, as this mixes up the channel sets (which probably violates our assumption of independence of observations at each channel set)

% phi_threes = sort_phis(phi_threes, 'phi_threes', 'within flies');
% phi_stars = sort_phis(phi_stars, 'phi_stars', 'within flies');

%% Average across trials and flies, calculate deltas and associated standard error

for nChannels_counter = 1 : numel(phi_threes)
    % Raw
    phi_threes{nChannels_counter}.phis_raw = phi_threes{nChannels_counter}.phi_threes(:, :, flies, :, :);
    phi_stars{nChannels_counter}.phis_raw = phi_stars{nChannels_counter}.(star_metric)(:, :, flies, :, :);
    
    % Average 
    phi_threes{nChannels_counter}.phis = squeeze(mean(mean(phi_threes{nChannels_counter}.phi_threes(:, :, flies, :, :), 2), 3));
    phi_stars{nChannels_counter}.phis = squeeze(mean(mean(phi_stars{nChannels_counter}.(star_metric)(:, :, flies, :, :), 2), 3));
    
    % Standard error (across flies)
    phi_threes{nChannels_counter}.phis_std = squeeze(std(mean(phi_threes{nChannels_counter}.phi_threes(:, :, flies, :, :), 2), [], 3)) / sqrt(length(flies));
    phi_stars{nChannels_counter}.phis_std = squeeze(std(mean(phi_stars{nChannels_counter}.(star_metric)(:, :, flies, :, :), 2), [], 3)) / sqrt(length(flies));
    
    % Delta (air - iso) (absolute)
    phi_threes{nChannels_counter}.phis_delta = squeeze(mean(mean(phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :) - phi_threes{nChannels_counter}.phi_threes(:, :, flies, 2, :), 2), 3));
    phi_stars{nChannels_counter}.phis_delta = squeeze(mean(mean(phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :) - phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 2, :), 2), 3));
    
    % Delta std (air - iso)
    phi_threes{nChannels_counter}.phis_delta_std = squeeze(std(mean(phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :) - phi_threes{nChannels_counter}.phi_threes(:, :, flies, 2, :), 2), [], 3)) / sqrt(length(flies));
    phi_stars{nChannels_counter}.phis_delta_std = squeeze(std(mean(phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :) - phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 2, :), 2), [], 3)) / sqrt(length(flies));
    
%     % Delta (air - iso / air) (relative)
%     phi_threes{nChannels_counter}.phis_delta = squeeze(mean(mean((phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :) - phi_threes{nChannels_counter}.phi_threes(:, :, flies, 2, :)) ./ phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :), 2), 3));
%     phi_stars{nChannels_counter}.phis_delta = squeeze(mean(mean((phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :) - phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 2, :)) ./ phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :), 2), 3));
%     
%     % Delta std (air - iso)
%     phi_threes{nChannels_counter}.phis_delta_std = squeeze(std(mean((phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :) - phi_threes{nChannels_counter}.phi_threes(:, :, flies, 2, :)) ./phi_threes{nChannels_counter}.phi_threes(:, :, flies, 1, :), 2), [], 3)) / sqrt(length(flies));
%     phi_stars{nChannels_counter}.phis_delta_std = squeeze(std(mean((phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :) - phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 2, :)) ./ phi_stars{nChannels_counter}.(star_metric)(:, :, flies, 1, :), 2), [], 3)) / sqrt(length(flies));
end
%% Plot all phi values on a single axis
% Uses natural channel-set ordering

q = 0.05;
labelled_subplot = 7;
sort_phi = 0;

phis_concatenated = struct();
phis_concatenated.threes = struct();
phis_concatenated.stars = struct();

% Phi-3
[phis_concatenated.threes.all, phis_concatenated.threes.stds, phis_concatenated.threes.deltas, phis_concatenated.threes.delta_stds, channel_ticks, channel_labels] =...
    plot_phis(phi_threes, [-0.005 0.05], 1, 'phi-3', sort_phi, labelled_subplot);
%plot_phis(phi_threes, [-1.5 1.5], 1, 'phi-3', sort_phi, labelled_subplot);
% Add t-tests for delta
[sigs_three_corrected, sigs_three] = phi_tests(phi_threes, q, sort_phi);
%plot_sigs(sigs_three_corrected, 0.05, -0.0025);
plot_sigs(sigs_three_corrected, 0.035, -0.0025);


% Phi-star
[phis_concatenated.stars.all, phis_concatenated.stars.stds, phis_concatenated.stars.deltas, phis_concatenated.stars.delta_stds, channel_ticks, channel_labels] =...
    plot_phis(phi_stars, [-0.002 0.03], 1, 'phi-*', sort_phi, labelled_subplot);
%plot_phis(phi_stars, [-1.5 1.5], 1, 'phi-*', sort_phi, labelled_subplot);
% Add t-tests for delta
[sigs_star_corrected, sigs_star] = phi_tests(phi_stars, q, sort_phi);
%plot_sigs(sigs_star_corrected, 0.025, -0.0025);
plot_sigs(sigs_star_corrected, 0.018, -0.001);

%% Plot portion of significance per nChannels

total_channels = 15;

sig_portions = struct();
sig_portions.phi_threes = zeros(length(phi_threes), length(phi_threes{1}.taus));
sig_portions.phi_stars = zeros(length(phi_threes), length(phi_threes{1}.taus));

set_counter = 1;
for nChannels_counter = 1 : length(phi_threes)
    sig_sets = double(nchoosek(total_channels, phi_threes{nChannels_counter}.nChannels));
    sig_portions.phi_threes(nChannels_counter, :) = 100 * sum(sigs_three_corrected(set_counter:set_counter+sig_sets-1, :), 1) / sig_sets;
    sig_portions.phi_stars(nChannels_counter, :) = 100 * sum(sigs_star_corrected(set_counter:set_counter+sig_sets-1, :), 1) / sig_sets;
    set_counter = set_counter + sig_sets;
end

figure;
subplot(1, 2, 1);
bar(sig_portions.phi_threes);
subplot(1, 2, 2);
bar(sig_portions.phi_stars);
xlabel('nChannels');

%% Plot figure for phi three and phi star
% Top row = delta across flies, one tau
% Second row = comparisons at each tau (x3); percentage of significant
% decreases per nChannels

% RUN main_avi_plot.m FIRST (loading appropriate phi table of course)

plot_tau = 1;
plot_metric = 'threes';

figure;
subplot(2, length(phi_threes{1}.taus)+1, [1 length(phi_threes{1}.taus)+1]);
bar(phis_concatenated.(plot_metric).deltas(:, plot_tau));
hold on;
errorbar((1:size(phis_concatenated.(plot_metric).deltas, 1)), phis_concatenated.(plot_metric).deltas(:, plot_tau), zeros(size(phis_concatenated.(plot_metric).deltas, 1), 1), phis_concatenated.(plot_metric).delta_stds(:, plot_tau), 'k', 'LineStyle', 'none', 'LineWidth', 0.1, 'CapSize', 0);
if strcmp(plot_metric, 'threes')
    axis([-24 size(phis_concatenated.(plot_metric).deltas, 1)+25 -0.005 0.035])
    %set(gca, 'yscale', 'log');
else
    axis([-24 size(phis_concatenated.(plot_metric).deltas, 1)+25 -0.005 0.02])
    %set(gca, 'yscale', 'log');
end
ylabel(char(981), 'FontSize', 15, 'rotation', 0);
xlabel('channels in set');
xticks(channel_ticks); xticklabels(channel_labels);

% Relies on results from previous plots
for tau_counter = 1 : length(taus)
    s = subplot(2, length(phi_threes{1}.taus)+1, length(phi_threes{1}.taus)+1+tau_counter);
    [bars, errors] = barwitherr(plot_data_perTau.stds(:, :, tau_counter), plot_data_perTau.means(:, :, tau_counter));
    if strcmp(plot_metric, 'threes')
        axis([0.5 2.5 0 0.028]);
        set(gca, 'XTick', [1 2], 'XTickLabel', {'air', 'iso'}, 'YTick', [0 0.01 0.02]);
    else
        axis([0.5 2.5 0 0.005]);
        set(gca, 'XTick', [1 2], 'XTickLabel', {'air', 'iso'});
    end
    title(['\tau = ' num2str(taus(tau_counter)) ' ms'], 'FontSize', 15);
    s.XAxis.FontSize = 15;
    set(errors, 'LineWidth', 0.1, 'CapSize', 0);
    set(bars(3), 'FaceColor', 'g');
    if tau_counter == 1
        ylabel(char(981), 'FontSize', 15, 'rotation', 0);
        legend('2ch', '3ch', '4ch');
    end
end

subplot(2, length(phi_threes{1}.taus)+1, 2*(length(phi_threes{1}.taus)+1));
bars = bar(sig_portions.(['phi_' plot_metric])');
set(bars(3), 'FaceColor', 'g');
set(gca, 'XTick', [1 2 3], 'XTickLabel', phi_threes{1}.taus);
xlabel('\tau', 'FontSize', 15, 'rotation', 0);

%% Plot main effects after averaging across other effects

plot_tau = 1;
plot_metric = 'stars';

figure;
subplot(2, length(phi_threes{1}.taus)+1, [1 length(phi_threes{1}.taus)+1]);
bar(phis_concatenated.(plot_metric).deltas(:, plot_tau));
hold on;
errorbar((1:size(phis_concatenated.(plot_metric).deltas, 1)), phis_concatenated.(plot_metric).deltas(:, plot_tau), zeros(size(phis_concatenated.(plot_metric).deltas, 1), 1), phis_concatenated.(plot_metric).delta_stds(:, plot_tau), 'k', 'LineStyle', 'none', 'LineWidth', 0.1, 'CapSize', 0);
if strcmp(plot_metric, 'threes')
    axis([-24 size(phis_concatenated.(plot_metric).deltas, 1)+25 -0.005 0.035])
    %set(gca, 'yscale', 'log');
else
    axis([-24 size(phis_concatenated.(plot_metric).deltas, 1)+25 -0.005 0.02])
    %set(gca, 'yscale', 'log');
end
ylabel(char(981), 'FontSize', 15, 'rotation', 0);
xlabel('channels in set');
xticks(channel_ticks); xticklabels(channel_labels)

% Build matrix holding average across channel sets (nChannels x conditions
% x taus x flies)
field = ['phi_' plot_metric];
effects_matrix.phi_threes = zeros(length(phi_threes), size(phi_threes{1}.phi_threes, 4), size(phi_threes{1}.phi_threes, 5), size(phi_threes{1}.phi_threes, 3));
effects_matrix.phi_stars = zeros(length(phi_threes), size(phi_threes{1}.phi_threes, 4), size(phi_threes{1}.phi_threes, 5), size(phi_threes{1}.phi_threes, 3));

for nChannels_counter = 1 : length(phi_threes)
    for condition_counter = 1 : size(phi_threes{nChannels_counter}.phi_threes, 4)
        for tau_counter = 1 : size(phi_threes{nChannels_counter}.phi_threes, 5)
            for fly_counter = 1 : size(phi_threes{nChannels_counter}.phi_threes, 3)
            effects_matrix.phi_threes(nChannels_counter, condition_counter, tau_counter, fly_counter) =...
                mean(mean(phi_threes{nChannels_counter}.phi_threes(:, :, fly_counter, condition_counter, tau_counter), 2));
            effects_matrix.phi_stars(nChannels_counter, condition_counter, tau_counter, fly_counter) =...
                mean(mean(phi_stars{nChannels_counter}.phi_stars(:, :, fly_counter, condition_counter, tau_counter), 2));
            end
        end
    end
end

% Subplots for each effect
% Average across flies, then other effects

if strcmp(plot_metric, 'threes')
    ylimit = 0.018;
else
    ylimit = 0.004;
end

% Condition
s = subplot(2, 4, 5);
effect = mean(mean(mean(effects_matrix.(field), 1), 3), 4);
effect_std = std(mean(mean(effects_matrix.(field), 1), 3), [], 4) / sqrt(size(effects_matrix.(field), 4));
bar([1 2], effect); hold on;
errorbar((1:length(effect)), effect, effect_std, effect_std, 'k', 'LineStyle', 'none', 'CapSize', 0);
set(gca, 'XTick', [1 2], 'XTickLabel', {'air', 'iso'});
axis([0.5 2.5 0 ylimit]);
ylabel(char(981), 'FontSize', 15, 'rotation', 0);

% Number of channels
s = subplot(2, 4, 6);
effect = mean(mean(mean(effects_matrix.(field), 2), 3), 4);
effect_std = std(mean(mean(effects_matrix.(field), 2), 3), [], 4) / sqrt(size(effects_matrix.(field), 4));
bar(effect); hold on;
errorbar((1:length(effect)), effect, effect_std, effect_std, 'k', 'LineStyle', 'none', 'CapSize', 0);
set(gca, 'XTick', [1 2 3], 'XTickLabel', [2 3 4], 'YTick', []);
axis([0.5 3.5 0 ylimit]);
xlabel('channels');

% Lag
s = subplot(2, 4, 7);
effect = squeeze(mean(mean(mean(effects_matrix.(field), 1), 2), 4));
effect_std = squeeze(std(mean(mean(effects_matrix.(field), 1), 2), [], 4) / sqrt(size(effects_matrix.(field), 4)));
bar(effect); hold on;
errorbar((1:length(effect)), effect, effect_std, effect_std, 'k', 'LineStyle', 'none', 'CapSize', 0);
set(gca, 'XTick', [1 2 3], 'XTickLabel', [4 8 16], 'YTick', []);
axis([0.5 3.5 0 ylimit]);
xlabel('\tau');

% Portion of significant decreases
subplot(2, length(phi_threes{1}.taus)+1, 2*(length(phi_threes{1}.taus)+1));
bars = bar(sig_portions.(['phi_' plot_metric])');
%set(bars(3), 'FaceColor', 'g');
set(gca, 'XTick', [1 2 3], 'XTickLabel', phi_threes{1}.taus);
ylabel('%', 'rotation', 0);
xlabel('\tau');

%% Find portion of decreases per fly

% decrease_portions = struct();
% [decrease_portions.threes, decrease_counts.threes] = decrease_portion(phi_threes);
% [decrease_portions.stars, decrease_counts.stars] = decrease_portion(phi_stars);
% 
% figure;
% subplot(1, 2, 1);
% bar(mean(decrease_portions.threes, 3));
% subplot(1, 2, 2);
% bar(mean(decrease_portions.stars, 3));
% 
% function [portions, counts] = decrease_portion(phis)
% % Outputs:
% %   portions = matrix (nChannels x tau x flies); gives percentage of sets
% %   (of size nChannels) for which phi decreased in isoflurane; averaged
% %   across trials
% 
% portions = zeros(length(phis), length(phis{1}.taus), size(phis{1}.phis_raw, 3));
% counts = zeros(length(phis), length(phis{1}.taus), size(phis{1}.phis_raw, 3));
% for nChannels_counter = 1 : length(phis)
%     phi_diffs = permute(phis{nChannels_counter}.phis_raw(:, :, :, 1, :) - phis{nChannels_counter}.phis_raw(:, :, :, 2, :), [1 2 3 5 4]);
%     decreased = phi_diffs > 0;
%     nSets = size(decreased, 1); 
%     decreased = permute(sum(decreased, 1), [2 3 4 1]); % Sum across sets
%     decreased = permute(mean(decreased, 1), [3 2 1]); % Average across trials
%     portions(nChannels_counter, :, :) = 100 * decreased / nSets;
%     counts(nChannels_counter, :, :) = decreased;
% end
% 
% end

%% Function: sort all phi values

function [phis] = sort_phis(phis, field, across)

if strcmp(across, 'within flies')
    for nChannels_counter = 1 : numel(phis)
        % Average across trials first (as different trials might give a different 'best' channel combination)
        phis{nChannels_counter}.(field) = mean(phis{nChannels_counter}.(field), 2);
        
        % sort_linear_index()
        % Get the indices for sorting the first condition (awake)
        [~, indices] = sort_linear_index(phis{nChannels_counter}.(field)(:, :, :, 1, :), 1, 'descend');
        % Sort all conditions using indices from the first condition
        for condition = 1 : size(phis{nChannels_counter}.(field), 4)
            condition_phis = phis{nChannels_counter}.(field)(:, :, :, condition, :);
            phis{nChannels_counter}.(field)(:, :, :, condition, :) = condition_phis(indices);
        end
    end
end

end

%% Function: concatenate all phi values and plot on a single axis

function [phis_all, phis_all_stds, phis_all_delta, phis_all_delta_std, channel_ticks, channel_labels] = plot_phis(phis, y_limits, errorbars, ylabel_text, sort_sets, labelled_subplot)
% Plots all phis (for all nChannels used) on a single axis
%
% Inputs:
%   phis: cell array, each cell holds .phis, a matrix with dimensions
%       (channel sets x conditions x taus); Average across trials and average across
%       flies or or filter for a fly before inputting to this function, .phis_std, .phis_delta, and .phis_delta_std
% Outputs: None

plot_titles{1} = 'air';
plot_titles{2} = 'iso';
plot_titles{3} = 'delta';
tau_labels = phis{1}.taus;

phis_all = [];
phis_all_stds = [];
phis_all_delta = [];
phis_all_delta_std = [];
channel_ticks = []; xtick_counter = 1;
channel_labels = [];
% Concatenate results
for nChannels_counter = 1 : numel(phis)
    % Sort if necessary
    if sort_sets == 1
        % Get sorting indices for condition 1
        [~, indices] = sort_linear_index(phis{nChannels_counter}.phis(:, 1, :), 1, 'descend');
        for condition = 1 : size(phis{nChannels_counter}.phis, 2)
            tmp = phis{nChannels_counter}.phis(:, condition, :);
            phis{nChannels_counter}.phis(:, condition, :) = tmp(indices);
            tmp = phis{nChannels_counter}.phis_std(:, condition, :);
            phis{nChannels_counter}.phis_std(:, condition, :) = tmp(indices);
        end
        phis{nChannels_counter}.phis_delta = phis{nChannels_counter}.phis_delta(squeeze(indices));
        phis{nChannels_counter}.phis_delta_std = phis{nChannels_counter}.phis_delta_std(squeeze(indices));
    end
    phis_all = cat(1, phis_all, phis{nChannels_counter}.phis);
    phis_all_stds = cat(1, phis_all_stds, phis{nChannels_counter}.phis_std);
    phis_all_delta = cat(1, phis_all_delta, phis{nChannels_counter}.phis_delta);
    phis_all_delta_std = cat(1, phis_all_delta_std, phis{nChannels_counter}.phis_delta_std);
    channel_ticks = cat(1, channel_ticks, xtick_counter);
    channel_labels = cat(1, channel_labels, phis{nChannels_counter}.nChannels);
    xtick_counter = xtick_counter + size(phis{nChannels_counter}.phis, 1);
end

% Plot for each tau, for each condition, averaging across trials and flies
%figure;
figure('units','normalized','outerposition',[0 0 1 1]) % Source: https://au.mathworks.com/matlabcentral/answers/102219-how-do-i-make-a-figure-full-screen-programmatically-in-matlab
subplot_counter = 1;
for tau = 1 : size(phis_all, 3)
    for condition = 1 : size(phis_all, 2)
        subplot(size(phis_all, 3), size(phis_all, 2) + 1, subplot_counter);
        
        %barwitherr(squeeze(std(mean(phis_all(:, :, :, condition, tau), 2), [], 3)), squeeze(mean(mean(phis_all(:, :, :, condition, tau), 2), 3)), 'LineWidth', 0.001);
        
        bar(phis_all(:, condition, tau));
        if subplot_counter <= size(phis_all, 2) + 1
            title(plot_titles{subplot_counter});
        end
        if errorbars == 1
            hold on;
            errorbar((1:size(phis_all, 1)), phis_all(:, condition, tau), zeros(size(phis_all, 1), 1), phis_all_stds(:, condition, tau), 'k', 'LineStyle', 'none', 'LineWidth', 0.1, 'CapSize', 0);
        end
        axis([-50 size(phis_all, 1)+50 y_limits]);
        xticks(channel_ticks); xticklabels(channel_labels);
        set(gca,'yticklabel',num2str(get(gca,'ytick')'))
        
        if subplot_counter == labelled_subplot
            xlabel('channel set');
            ylabel([ylabel_text ' tau=' num2str(tau_labels(tau))]);
        elseif mod(subplot_counter, size(phis_all, 3)) == 1
            ylabel(['tau=' num2str(tau_labels(tau))]);
        end
        
        subplot_counter = subplot_counter + 1;
    end
    
    % Plot delta
    subplot(size(phis_all, 3), size(phis_all, 2) + 1, subplot_counter);
    bar(phis_all_delta(:, tau));
    if subplot_counter <= size(phis_all, 2) + 1
        title(plot_titles{subplot_counter});
    end
    if errorbars == 1
        hold on;
        errorbar((1:size(phis_all, 1)), phis_all_delta(:, tau), zeros(size(phis_all, 1), 1), phis_all_delta_std(:, tau), 'k', 'LineStyle', 'none', 'LineWidth', 0.1, 'CapSize', 0);
    end
    axis([-50 size(phis_all, 1)+50 y_limits]);
    xticks(channel_ticks); xticklabels(channel_labels);
    set(gca,'yticklabel',num2str(get(gca,'ytick')'))
    
    if subplot_counter + 1 - size(phis_all, 3) == labelled_subplot
        ylabel(['delta ' ylabel_text]);
    end
    
    subplot_counter = subplot_counter + 1;
end

%     function [] = sort_phis(phis)
%         % Sort based on first condition (awake)
%         [~, indices] = sort_linear_index(phis, 1, 'descend');
%         for sort_condition = 1 : size(phis, 2) % sort_condition = condition; new name due to nested sharing
%             condition_phis = phis(:, sort_condition, :);
%             phis(:, sort_condition, :) = condition_phis(indices);
%         end
%     end

end

%% Function: t-tests for each channel set

function [sigs_corrected, sigs] = phi_tests(phis, q, sort_sets)
% Conducts a t-test at each channel set, and corrects using FDR
% Also plots significances


phis_all = [];
% Concatenate results
for nChannels_counter = 1 : numel(phis)
    if sort_sets == 1
        % Get sorting indices for condition 1
        [~, indices] = sort_linear_index(phis{nChannels_counter}.phis_raw(:, :, :, 1, :), 1, 'descend');
        for condition = 1 : size(phis{nChannels_counter}.phis_raw, 4)
            tmp = phis{nChannels_counter}.phis_raw(:, :, :, condition, :);
            phis{nChannels_counter}.phis_raw(:, :, :, condition, :) = tmp(indices);
        end
    end
    phis_all = cat(1, phis_all, phis{nChannels_counter}.phis_raw);
end

% Average across trials
phis_all = (squeeze(mean(phis_all, 2)));

% Conduct t-tests across flies, comparing conditions
sigs = zeros(size(phis_all, 1), size(phis_all, 4));
sigs_corrected = zeros(size(sigs));
for tau = 1 : size(phis_all, 4)
    for set = 1 : size(phis_all, 1)
        air = phis_all(set, :, 1, tau);
        iso = phis_all(set, :, 2, tau);
        %[decision, sigs(set, tau)] = ttest(air(:), iso(:), 'Tail', 'right'); % para paired
        [sigs(set, tau), decision] = signrank(air(:), iso(:), 'Tail', 'right'); % non-para paired
        %[decision, sigs(set, tau)] = swtest(air(:) - iso(:)); % normality
    end
    
    % FDR correction for multiple comparisons (don't correct for normality testing)
    sigs_corrected(:, tau) = fdr_correct(sigs(:, tau), q);
    
end

end

%% Function: plot significances

function [] = plot_sigs(sigs, height, height_nonsig)
% Adds asterisks to each subplot

alpha = 0.1;% 0.1; %0.025;

for tau = 1 : size(sigs, 2)
    subplot(3, 3, tau*3); hold on;
    
    xs = (1:size(sigs, 1));
    
    scatter(xs(logical(sigs(:, tau))), sigs(logical(sigs(:, tau)), tau)*height, 10, 'k*', 'MarkerEdgeAlpha', alpha); % sig
    scatter(xs(not(logical(sigs(:, tau)))), sigs(not(logical(sigs(:, tau))), tau)+height_nonsig, 10, 'k*', 'MarkerEdgeAlpha', alpha);% non-sig
end

end