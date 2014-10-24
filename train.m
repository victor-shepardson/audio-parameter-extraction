function Train(data_features_name, train_set_file_name)
% given a file to read data (as features) from,
% and a file to save training features/outputs to,
% generate a training set by sampling

%load constants from file
load('data/constants');

%load feature matrix from file
load(data_features_name, 'F'); 

%generate train set
[X,Y] = gen_train_set(F, train_set_size, window_samps, sample_rate);

save(train_set_file_name, 'X', 'Y');
end