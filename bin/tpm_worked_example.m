%% Settings

fly = 1;
channels = [5 6]; %[5 6];
trial = 1;
samples = (101:120); %(101:110);
condition = 1;
tau = 1;

%% Load
data_directory = 'workspace_results/';
data_file = 'split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim';

disp('Loading fly data');
loaded_data = load([data_directory data_file '.mat']);
fly_data = loaded_data.fly_data; % Reminder: dimensions are: (samples x channels x trials x flies x conditions)
disp('Fly data loaded')

%%

% Binarise fly_data
%fly_data_binarised = binarise_global_median(fly_data);
n_values = 2;

% Get relevant data
raw_data = fly_data(samples, channels, trial, fly, condition);

% Each channel is binarised based on its median value
middle = median(raw_data, 1);
middle_mat = repmat(middle, [size(raw_data, 1), 1]);
binarised_data = raw_data > middle_mat;
channel_data = binarised_data; %fly_data_binarised(samples, channels, trial, fly, condition);

% Actual TPM
tpm = build_tpm(channel_data, 1, n_values);

% Independent TPM
[tpm_ind, ind_a, ind_b] = build_tpm_independent(channel_data, 1, n_values);

%% Plot data
figure;
data_plot = subplot(5, 6, (1:3));
imagesc(raw_data'); cbar = colorbar;
set(gca, 'YTick', [1 2 3], 'XTickLabel', '');
xlabel(cbar, '\muV');
ylabel('channel');
colormap(data_plot, 'jet');

binarised_plot = subplot(5, 6, (7:9));
imagesc(channel_data');
set(gca, 'YTick', [1 2]);
cbar = colorbar; caxis([0 1]);
set(cbar, 'YTick', [0.25 0.75], 'YTickLabel', {'off (0)', 'on (1)'});
xlabel('time sample'); ylabel('channel');
colormap(binarised_plot, [0 0 0; 1 1 1]);

%% Plot TPMs

states_ind = {'0', '1'};
states = {'00', '01', '10', '11'};

plim = [0 1]; % Probability colourbar

% Empirical TPM
tpm_plot = subplot(5, 6, [4.5 5.2 10.5 11.2]);
imagesc(tpm, plim); cbar = colorbar; xlabel(cbar, 'P');
set(gca, 'XTick', [1 2 3 4], 'YTick', [1 2 3 4], 'YTickLabel', states, 'XTickLabel', states);
xlabel('state t+1'); ylabel('state t');
%colormap(tpm_plot, 'gray');

% Independent channel TPMs
ind_a_plot = subplot(5, 6, [13 13.1]+6);
imagesc(ind_a, plim); cbar = colorbar; cbar.Visible = 'off';
set(gca, 'XTick', [1 2], 'YTick', [1 2], 'YTickLabel', states_ind, 'XTickLabel', states_ind);
xlabel('t+1'); ylabel('t');
%colormap(ind_a_plot, 'gray');
ind_b_plot = subplot(5, 6, [15 15.1]+6);
imagesc(ind_b, plim); cbar = colorbar; cbar.Visible = 'off';
set(gca, 'XTick', [1 2], 'YTick', [1 2], 'YTickLabel', states_ind, 'XTickLabel', states_ind);
xlabel('t+1'); ylabel('t');
%colormap(ind_b_plot, 'gray');

% Independent TPM (product of indepent channel TPMs)
tpm_ind_plot = subplot(5, 6, [4.5 5.2 10.5 11.2]+18);
imagesc(tpm_ind, plim); cbar = colorbar; xlabel(cbar, 'P');
set(gca, 'XTick', [1 2 3 4], 'YTick', [1 2 3 4], 'YTickLabel', states, 'XTickLabel', states);
xlabel('state t+1'); ylabel('state t');
%colormap(tpm_ind_plot, 'gray');

%% Function: build independent TPM from 2 channel data
function [tpm, a, b] = build_tpm_independent(channel_data, tau, n_values)
% For the 2 channel scenario
% Multiplies two (independent) TPMs together using Kronecker Tensor
% multiplication (kron())
% Note that the output is NOT in the required LOLI format for PyPhi

% Build TPM for single channels
a = build_tpm(channel_data(:, 1), tau, n_values);
b = build_tpm(channel_data(:, 2), tau, n_values);

% Multiply single-channel TPMs
tpm = kron(a, b);

end