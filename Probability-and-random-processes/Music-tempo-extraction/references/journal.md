**Abstract:**
The aim of this project is to extract the tempo information from EEG(Electroencephalogram) recordings\textsuperscript{1}  using Music Information Retrieval(MIR) technique which is originally used for extracting the tempo from audio music signal. Tempo in a music signal is the speed of beats. It is possible to track listeners attention to different speakers and music signals and even extract music or rhythmic information from EEG waves when the person is listening to music stimuli.

**Introduction:**
comment{we transform a signal into a tempogram _T_ which is a time-tempo representation of a signal. The tempogram reveals the periodicities in a given signal, similar to a spectrogram. An EEG tempogram reveals how dominant different tempi are at a given point in time.}
It has been shown in recent research that oscillatory neural activity is sensitive to accented tones in a rhythmic sequence. Neural oscillations synchronize to rhythmic sequences and increase in anticipation of strong tones in a non-isochronous (not evenly spaced), rhythmic sequence. When subjects hear rhythmic sequences, the magnitude of the oscillations changes for frequencies related to the metrical structure of the rhythm [1].


**Method:**
There are two methods for tempo extraction in EEG waves - 1) Energy Method 2) Spectral Method in which the latter is more refined as compared to the former. Hence we will use the Spectral Method for our project which is described below.
The Computation of Tempo Information involves first transforming the signal(either music audio or EEG signal) into a tempogram T which is a time-tempo representation of a signal. Using 64 EEG channels placed on the scalp of user, one signal will be aggregated using Channel Aggregation Filter which is weighted sum of the channels followed by a tanh function. The Channel Aggregation filter weights are in turn learned using a Convolutional Neural Network(CNN) trained on the EEG dataset provided and the resulting aggregated EEG signal captures the important characteristics of the music or signal. From the aggregated EEG time curve obtained, we will find the novelty curve but assuming the beat periodicities which we want to measure are already present in the time-domain EEG signal, letting us to interpret EEG signal as novelty curve. For pre-processing we will normalize the EEG signal by subtracting a local average curve which will make sure that the EEG signal is centered around zero and less frequent components are attenuated. The tempogram is computed using Short-term Fourier Analysis of the novelty curve.
Now after computing the tempogram of a given music or EEG signal, we can extract a single tempo value from it by computing a tempo histogram H(T) which represents how much present a certain tempo T is within the entire signal. The highest peak in the tempo histogram will give the tempo value which is most dominant. But for EEG tempograms H\textsuperscript{EEG} is much noisier as compared to music histogram. Hence we will take first highest peak, make the histogram zero within \+-\10 BPM of that peak and then do this for n subsequent peaks. Suppose B1 = {b1}, B2 = {b1,b2}... Bn = {b1,b2,...bn} where bi = top ith peak after doing the above process. The Minimum absolute BPM deviation compared to audio tempo E(Bn, p) = minbEBn |b-p|^2.
We will quantify different error classes with an error tolerance d>0.So the BPM error rate is defined for each class which is the percentage of absolute BPM deviations with error(Bn, p)>d.


we will find the peak positions of the novelty curve which indicate the note onset candidates i.e, the time positions where major changes happen in the signal spectrum. 