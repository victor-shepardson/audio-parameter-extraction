function [F1, F2] = feature_difference( A1, A2, samplerate, overlap )

[F1, E1] = audio_to_features_cepstrum(A1, samplerate, overlap);
[F2, E2] = audio_to_features_cepstrum(A2, samplerate, overlap);

end

