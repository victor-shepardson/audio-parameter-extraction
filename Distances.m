function Distances( input_set_file_name, train_set_file_name, out_name )
% load a matrix of audio parameters, save an audio file

load('data/constants');
load(input_set_file_name, 'F');
load(train_set_file_name, 'X');

D = pdist2(F, X);

%imagesc(D);
plot(min(D, [], 2));

save(out_name, 'D');

end