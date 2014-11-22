function Preprocess( data_audio_name, data_features_name )
% given an audio file name, generate a matrix of features and save it as
% data_features_name

load('data/constants');

raw = audioread(data_audio_name);

[len, channels] = size(raw);

% read audio and convert to mono row vector
audio = (1/channels).*sum(raw, 2)'; 

A = chop_audio(audio, window_samps, overlap);

[F, E] = audio_to_features_cepstrum(A, sample_rate, overlap, use_inst_freq, spectra_or_cepstra);

imagesc(F);
title('Cepstral Feature - Resynth gtr.wav, 24 oscs');
xlabel('Feature');
ylabel('Time Window');
colorbar();
truesize();

save(data_features_name, 'F', 'E');

end

