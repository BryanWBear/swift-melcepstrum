import Foundation

struct SwiftMelcepstrum {
    //https://stackoverflow.com/questions/58995021/how-to-get-a-floating-point-number-interval-of-fixed-length-and-bounds-in-swift
    // linspace in Swift is off by one from Python version, that is, use python_in - 1 for 3rd parameter.
    func linspace<T>(from start: T, through end: T, in samples: Int) -> StrideThrough<T>
        where T : FloatingPoint, T == T.Stride {
        return Swift.stride(from: start, through: end, by: (end - start) / T(samples))
    }

    func mel(sampleRate: Int, nFFT: Int, nMels: Int, slaney: Bool = true) -> [[Double]] {
        let melNyquist = (2595 * log10(1 + (Double(sampleRate) / 2.0) / 700))
        let melPoints = Array(linspace(from: 0, through: melNyquist, in: nMels + 1))
        let hzPoints = melPoints.map { (mel) -> Double in
            700 * (pow(10, mel / 2595) - 1)
        }
        let freqFFT = Array(linspace(from: 0, through: Float(sampleRate / 2), in: nFFT / 2))
        var filterBank: [[Double]] {
            var a = [[Double]](repeating: [Double](repeating: 0, count: sampleRate / 2 + 1), count: nMels)
            // could do away with the matrix completely, or convert to sparse format.
            for filterIndex in 1..<(nMels + 1) {
                for (freqIndex, freq) in freqFFT.enumerated() {
                    let leftLine = (Double(freq) - hzPoints[filterIndex - 1]) / (hzPoints[filterIndex] - hzPoints[filterIndex - 1])
                    let rightLine = (hzPoints[filterIndex + 1] - Double(freq)) / (hzPoints[filterIndex + 1] - hzPoints[filterIndex])
                    a[filterIndex - 1][freqIndex] = max(0, min(leftLine, rightLine))
                    if slaney {
                        a[filterIndex - 1][freqIndex] *= 2 / (hzPoints[filterIndex + 1] - hzPoints[filterIndex - 1])
                    }
                }
            }
            return a
        }
        return filterBank
    }
}