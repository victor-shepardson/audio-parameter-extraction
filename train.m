function train(data_features_name, train_set_file_name)
% given a file to read data (as features) from,
% and a file to save training features/outputs to,
% generate a training set by sampling

%load constants from file
load('constants');

%load feature matrix from file
load(data_features_name, 'F'); 

%define features and synthesis process, generate training set
f_synth = @(x) synth(x, window_samps, sample_rate);
f_feat = @(x) audio_to_features(x, sample_rate);
[X,Y] = gen_train_set(f_synth, f_feat, F, train_set_size, window_samps, sample_rate);

save(train_set_file_name, 'X', 'Y');
end