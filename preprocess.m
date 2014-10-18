function Preprocess( data_audio_name, data_features_name )
% given an audio file name, generate a matrix of features and save it as
% data_features_name

load('data/constants');

% read audio and convert to mono row vector
audio = sum(audioread(data_audio_name), 2)'; 

A = chop_audio(audio, window_samps);

F = audio_to_features(A, sample_rate);

save(data_features_name, 'F');

end

