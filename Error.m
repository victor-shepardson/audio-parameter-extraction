function Error( orig_audio_path )
% given an audio file name, generate a matrix of features and save it as
% data_features_name

split = regexp(orig_audio_path, '[\.]', 'split')
audio_path = strjoin(split(1));
fmt = strjoin(split(2));

resynth_audio_path = [audio_path '_resynth.' fmt];

load('data/constants');

raw = audioread(orig_audio_path);
resynth = audioread(resynth_audio_path);

[len1, channels] = size(raw);

[len2, ~] = size(resynth);

% mix to mono and pad end
orig = [(1/channels).*sum(raw, 2)', zeros(1, len2-len1)]; 

A1 = chop_audio(orig, window_samps, overlap);
A2 = chop_audio(resynth, window_samps, overlap);

[F1, F2] = feature_difference(A1, A2, sample_rate, overlap);


%colormap(parula);

ncolors = 64;
dark = zeros(ncolors,1);
rampup = (1:ncolors)'/ncolors;
rampdown = flip(1:ncolors)'/ncolors;
colormap([rampdown dark dark; dark rampup rampup]);
imagesc([F1 F2 F1-F2]);

end

