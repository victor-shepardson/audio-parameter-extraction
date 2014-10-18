function Evaluate( train_set_file_name, input_set_file_name, params_file_name )
% load a training set and input set, produce a set of synth parameters, and
% save under params_file_name

load(train_set_file_name, 'X', 'Y');
load(input_set_file_name, 'F');

[input_size, feature_dim] = size(F);

P = evaluate_features(F, X, Y);

save(params_file_name, 'P');

end

