function Constants()
%save constants.mat with the values given in this script

sample_rate = 44100;
train_set_size = 10000;
window_samps = 512;

save 'data/constants';

end

