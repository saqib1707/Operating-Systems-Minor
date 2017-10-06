import numpy as np
import scipy.io

if __name__ == '__main__':
	# after saving the data in .mat files extract in python files
    mat_raw_eeg = scipy.io.loadmat('raw_eeg.mat')          # 69 x 2478166
    mat_events_eeg = scipy.io.loadmat('events_eeg.mat')    # 540 x 3
    print np.shape(mat_raw_eeg['data'])
    print np.shape(mat_events_eeg['data'])