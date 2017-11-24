import matplotlib.pyplot as plt 
from matplotlib.pyplot import specgram
import numpy as np 
from scipy import signal
import scipy.io

channel_aggr_out_without_avg = np.load('pltfile2.npy')
channel_aggr_out_with_avg = np.load('pltfile3.npy')

channel_aggr_out_without_avg = channel_aggr_out_without_avg.flatten()
channel_aggr_out_with_avg = channel_aggr_out_with_avg.flatten()
#print(channel_aggr_out_without_avg.shape)
#plt.plot(range(length), channel_aggr_out, 'ro')
#plt.axis([0,length,-1e-2, +1e-2])
#plt.show()
#print(length)

# compute spectrogram of signal
time = np.arange(0,channel_aggr_out_without_avg.shape[0])
#ax1 = plt.subplot(211)
max_val = np.amax(channel_aggr_out_without_avg)
min_val = np.amin(channel_aggr_out_without_avg)
plt.plot(time,channel_aggr_out_without_avg)   # for this one has to either undersample or zoom in 
plt.axis([0, channel_aggr_out_without_avg.shape[0], min_val, max_val])
plt.savefig('images/channel_aggr_out_without_avg.png')
#plt.xlim([0,15])
#plt.subplot(212)  # don't share the axis
#Pxx, freqs, bins, im = plt.specgram(channel_aggr_out.flatten(), NFFT=256, Fs=256)
plt.show()

max_val = np.amax(channel_aggr_out_with_avg)
min_val = np.amin(channel_aggr_out_with_avg)
plt.plot(time,channel_aggr_out_with_avg)   # for this one has to either undersample or zoom in 
plt.axis([0, channel_aggr_out_with_avg.shape[0], min_val, max_val])
plt.savefig('images/channel_aggr_out_with_avg.png')
plt.show()


#scipy.io.savemat('MATLAB-Tempogram-Toolbox_1.0/test.mat', dict(x=channel_aggr_out_without_avg,y=channel_aggr_out_with_avg))

#specgram(channel_aggr_out_with_avg.flatten(), NFFT=256, Fs=256)
#f, t, Sxx = signal.spectrogram(channel_aggr_out, fs)
#plt.pcolormesh(t, f, Sxx)
#plt.ylabel('Frequency [Hz]')
#plt.xlabel('Time [sec]')
#plt.show()