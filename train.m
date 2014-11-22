function Train(data_features_name, train_set_file_name)
% given a file to read data (as features) from,
% and a file to save training features/outputs to,
% generate a training set by sampling

%load constants from file
load('data/constants');

%load feature matrix from file
load(data_features_name, 'F'); 

%generate train set
rng(0);
[X,Y] = gen_train_set_adaptive(F, window_samps, sample_rate, oscs, octaves, ...
    use_inst_freq, culling_iterations,initial_samples, samples_per_it, ...
    num_nearest_culling, num_components);

save(train_set_file_name, 'X', 'Y');
end