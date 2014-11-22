# Naming Convention
lowercase.m - helper function with input/output arguments  
Uppercase.m - top-level function with filesystem i/o

# Resynthesize
given an audio file, directory to store .mat files, and number of stages to skip

programmatically generate file names and call Constants, Preprocess, Train, Evaluate and Synthesize

e.g. Resynthesize('audio/gtr.wav', 'data', 0) will run every step to reconstruct gtr.wav and store the result in audio/gtr_resynth.wav

# ResynthesizeFrom
takes separate arguments for example and target audio

# Preprocess
given audio, generate matrix of features and store in a .mat

# Constants
set hyperparameters here to be stored in .mat

# Train
given name of example feature .mat, generate labeled feature/parameter training set and store as .mat

# Evaluate
given name of .mat containing feature/parameter training set, and .mat containing features of audio to resynthesize, store sequence of synth parameters in .mat

# Synthesize
given .mat containing synth parameters and feature .mat which contains envelope information, synthesize new audio and write an audio file