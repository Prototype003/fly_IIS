%% Description

%{
Reformat partitions from cells to matrices, to hopefully reduce the results
file size
%}


%% Setup

data_directory = 'results/';
data_file = 'split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim_detrend0_zscore0_nChannels2t4_medianSplit0_phistar_allPartitions_big.mat';

results_directory = 'results/';
results_file = 'split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim_detrend0_zscore0_nChannels2t4_medianSplit0_phistar_allPartitions.mat';

%% Load big file

disp('loading');
load([data_directory data_file]);
disp('loaded');

%% Convert all partitions from cells to matrices

for nChannels = 1 : length(phis)
    disp(['nChannels ' num2str(nChannels)]);
    for partition = 1 : numel(phis{nChannels}.mips)
        if length(phis{nChannels}.mips(partition)) == 2
            phis{nChannels}.mips(partition) = partition_cell2mat(phis{nChannels}.mips(partition));
        end
    end
    disp('MIPs done');
    for partition = 1 : numel(phis{nChannels}.partitions)
        if length(phis{nChannels}.partitions(partition)) == 2
            phis{nChannels}.partitions(partition) = partition_cell2mat(phis{nChannels}.partitions(partition));
        end
    end
    disp('State partitions done');
end

%% Save the (hopefully) smaller file

disp('saving');
save([results_directory results_file], 'phis', '-v7.3');
disp('saved');