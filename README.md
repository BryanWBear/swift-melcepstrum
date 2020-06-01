# swift-melcepstrum
Mel filterbanks compatible with Python librosa

# Usage

The function ```SwiftMelcepstrum().mel(sr, n_fft, n_mels, slaney=True)``` is equivalent to ```librosa.filters.mel(sr, n_fft, n_mels, fmin=0.0, fmax=None, htk=True, norm='slaney', dtype=np.float32)```. 

Note that the main difference here is that ```htk=False``` by default in librosa, which means that they are using the Slaney auditory toolbox way of calculating mels. I choose to use the htk (Hidden Markov Toolkit) version because it's less involved. For more information about the formula, check the following link: https://haythamfayek.com/2016/04/21/speech-processing-for-machine-learning.html#fn:1.

Here is the librosa source that I borrowed from: https://librosa.github.io/librosa/_modules/librosa/filters.html. They calculate the filters as an intersection of three line segments, which is why the code looks different from the code provided in the first link.

The function ```SwiftMelcepstrum().spectrogramLibrosa(signal)``` is equivalent to ```librosa.core.spectrum._spectrogram(power=2, window="hann")``` for **one** window; in other words, it's just a FFT, not a true STFT. Will be adding that in the future.



