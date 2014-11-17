function Constants()
%save constants.mat with the values given in this script

sample_rate = 44100;
train_set_size = 10000;
window_samps = 2048;
overlap = 4;
oscs = 8;
kernel_k = 1;
kernel_width = .1;
use_inst_freq = 0;

save 'data/constants';

end

