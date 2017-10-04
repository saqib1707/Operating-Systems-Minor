***MIR(Music Information Retriaval)***
Brain beats tempo extraction from eeg data
tempo = speed of beats 
for example fast music have very high speed of beats and hence high tempo while slow music have slow tempo
the music given in video has constant tempo that is the beats were coming at fixed intervals
- different people may tab/clap on different levels hence beat tracking not an easy task(example Happy birthday to you)
- actual beat level not well defined and may be quite subjective
- tempo change throughout the music may happen. continuous tempo changes makes beat tracking really hard
- units of tempo (beats per minute) 

Process - 
1. Spectrogram is a 2-d plot with time on the x-axis and frequency on the y-axis with the third dimension to indicate the amplitude of a particular frequency by varying the intensity of the color used to represent the plot.
2. Logarithmic compression of the magnitude spectrum
3. differentiation of the compressed spectrum since we are only interested in energy increases only the positive differences will matter
4. we sum up the positive differences in a column wise fashion which yields for each frame or time a single positive number.
5. Novelty curve - the peaks of the novelty curve indicate the note onset candidates i.e time positions where major changes happen in signal spectrum
6. Normalized novelty curve
7. the peak of the novelty curve are good candidates for onsets

**Research Paper** : 
- It is possible to track listeners attention to different speakers or music signals. or to identify beat related or rythmic features in EEG recordings of brain activity during music perception.

**Neural Oscillations** : Neural oscillation, or brainwave, is rhythmic or repetitive neural activity in the central nervous system. Neural tissue can generate oscillatory activity in many ways, driven either by mechanisms within individual neurons or by interactions between neurons.

**Electroencephalography (EEG)** : is a non-invasive(not involving the introduction of intruments into the body) brain imaging technique that relies on electrodes placed on the scalp to measure the electrical activity of the brain ERP(Event Related Potential)

**Addressed in the paper**: Can MIR techniques originally developed to detect beats and extract tempo out of music signals could be used for the analysis of corresponding EEG signals.

So the brain transforms the perceived music signals and generates the transformed representation which is captured by the EEG electrodes. Hence the recorded EEG signals are heavily distorted after passing through brain and EEG device.This method is limited by other brain processes unrelated to music signal perception in the brain as well as the capabilities of the brain that can only measure the cortical brain activity(close to the scalp).
*what are the different fusion approaches that can be used to stabilize the tempo extraction on EEG signals??*
Dataset is available - **OpenMIIR(EEG recordings dataset)** available [here](https://github.com/sstober/openmiir).
**what exactly is stimuli??** *Ans* A thing or an event that evokes specific functional reaction in an organ or tissue.

**EEG Proprocessing** : consisted of removal or interpolation of bad channels(??) . Reduction of eye blinks artifacts by removing highly correlated components computed using extended Infomax independent Component Analysis(ICA)(???) with MNE python toolbox

***Now How tempo information can be extracted from both music and EEG signals***
1. Transform the signal to **tempogram(??)**(time tempo representation of signal and reveals time  periodicities in the signal)n
	Tempogram is a function of time and tempo value and can be used for any signal.
***what is normalized EEG curve  ?????***

**Tempogram Extraction for Music Signals**
1. Transform the music audio signal to novelty curve capturing note onset information
2. what are onsets (???)
3. The onsets of the cue clicks are clearly reflected by peaks in the novelty curve
4. For music with soft onsets, the novelty curve may contain some noise in the peak structures.
5. **For tempo extraction, convert novelty curve into an audio tempogram that reveals how dominant different tempi are at a given time point in the audio signal.**

**Tempogram estimation of EEG signals(similar approach compared to music signals)**: (measured when participants listened to music stimulus)
1. Aggregate 64 EEG channels into one signal using a **channel aggregation filter** which is weighted sum of channels followed by tanh for [-1,1]
2. Lot of redundancy in these channels( can be used to reduce SNR ratio) (**How ???**)
3. Use channel aggregation filter learned from CNN
4. **SCE** : Similarity Constraint Encoding
5. we found that the resulting aggregated EEG signals capture important characteristics of the music stimuli such as downbeats
6. From the aggregated EEG curve we compute the novelty curve
7. As pre-processing normalize the signal by subtracting the moving average curve(local avg)
8. resulting signal is used as a novelty curve to compute an eeg tempogram
9. More noise in EEG tempogram as compared to music tempogram making it difficult to determine predominant global tempo
10. Quality of tempo estimation was highly dependent on the quality of music stimulus used

To get a single tempo value from the tempogram plot the histogram and the tempo value with the maximum tempo is the global tempo value.

Used MIR tempo extraction technique originally developed for audio recordings to music signals.

Supplementary material and code [here](https://dx.doi.org/10.6084/m9.figshare.3398545.)

**Certain Questions** :
1. what if the beats are varying with music but the tempo changes right ??