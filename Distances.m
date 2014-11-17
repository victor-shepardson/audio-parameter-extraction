function Distances( input_set_file_name, train_set_file_name, out_name )
% load a matrix of audio parameters, save an audio file

load('data/constants');
load(input_set_file_name, 'F');
load(train_set_file_name, 'X');

[frames, feats] = size(F);

rng(1);
Xmin = min(min(X)); Xmax = max(max(X));
noise = rand(size(X))*(Xmax-Xmin)+Xmin;

D = pdist2(F, X);
Dref = pdist2(F, noise);

x = 1:frames;

%imagesc(D);
%plot(x, min(D, [], 2), x, max(D, [], 2), x, mean(D, 2));
plot(D);
save(out_name, 'D');
xlabel('Input Example');
ylabel('Distance to Training Example');
title(['Nearness of Input Set to Training Set, size = ' num2str(train_set_size)]);
xlim([1 frames]);
ylim([0 1]);
end