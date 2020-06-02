import Foundation
import Accelerate

@available(OSX 10.15, *)
struct SwiftMelcepstrum {
    //https://stackoverflow.com/questions/58995021/how-to-get-a-floating-point-number-interval-of-fixed-length-and-bounds-in-swift
    // linspace in Swift is off by one from Python version, that is, use python_in - 1 for 3rd parameter.
    func linspace<T>(from start: T, through end: T, in samples: Int) -> StrideThrough<T>
        where T : FloatingPoint, T == T.Stride {
        return Swift.stride(from: start, through: end, by: (end - start) / T(samples))
    }

    func mel(sampleRate: Int, nFFT: Int, nMels: Int, slaney: Bool = true) -> [Double] {
        let melNyquist = (2595 * log10(1 + (Double(sampleRate) / 2.0) / 700))
        let melPoints = Array(linspace(from: 0, through: melNyquist, in: nMels + 1))
        let hzPoints = melPoints.map { (mel) -> Double in
            700 * (pow(10, mel / 2595) - 1)
        }
        let freqFFT = Array(linspace(from: 0, through: Float(sampleRate / 2), in: nFFT / 2))
        var filterBank: [[Double]] {
            var a = [[Double]](repeating: [Double](repeating: 0, count: nFFT / 2 + 1), count: nMels)
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
        let flatFilterBank = filterBank.reduce([], +)
        return flatFilterBank
    }
    
    // every element that isn't index 0 or N/2 needs to be scaled by 1/4, as Accelerate FFT is 2 times regular FFT. 0 and N/2 must be scaled by 1/8 because N/2 is packed into the imaginary component of 0. For more information, consult this lost piece of documentation: https://developer.apple.com/library/archive/documentation/Performance/Conceptual/vDSP_Programming_Guide/UsingFourierTransforms/UsingFourierTransforms.html
    func getSpectrogram(magnitudes: [Float]) -> [Float] {
        var scaledMagnitudes = Array(magnitudes[0..<magnitudes.count / 2]).map {x in x * x}
        let nyquist = scaledMagnitudes.removeFirst() / 8
        scaledMagnitudes = scaledMagnitudes.map {x in x / 4}
        scaledMagnitudes.insert(nyquist, at: 0)
        scaledMagnitudes.append(nyquist)
        return scaledMagnitudes
    }

//    func spectrogramLibrosa(signal: [Float]) -> [Float] {
//        var window:[Float] = [Float](repeating: 0.0, count: signal.count)
//        vDSP_hann_window(&window, 8, Int32(vDSP_HANN_DENORM))
//        vDSP_vmul(signal, 1, window, 1, &signal, 1, UInt(signal.count))
//
//
//        // code from: https://gist.github.com/jeremycochoy/45346cbfe507ee9cb96a08c049dfd34f
//        var length = vDSP_Length(signal.count)
//        var log2n = vDSP_Length(ceil(log2(Float(length * 2))))
//        var fftSetup = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)!
//
//        // input and output arrays
//        var forwardInputReal = [Float](signal)
//        var forwardInputImag = [Float](repeating: 0, count: Int(length))
//        var forwardOutputReal = [Float](repeating: 0, count: Int(length))
//        var forwardOutputImag = [Float](repeating: 0, count: Int(length))
//        var magnitudes = [Float](repeating: 0, count: Int(length))
//
//        // compute FFT
//        forwardInputReal.withUnsafeMutableBufferPointer { forwardInputRealPtr in
//          forwardInputImag.withUnsafeMutableBufferPointer { forwardInputImagPtr in
//            forwardOutputReal.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
//              forwardOutputImag.withUnsafeMutableBufferPointer { forwardOutputImagPtr in
//
//                let forwardInput = DSPSplitComplex(realp: forwardInputRealPtr.baseAddress!, imagp: forwardInputImagPtr.baseAddress!)
//                var forwardOutput = DSPSplitComplex(realp: forwardOutputRealPtr.baseAddress!, imagp: forwardOutputImagPtr.baseAddress!)
//
//                fftSetup.forward(input: forwardInput, output: &forwardOutput)
//                vDSP.absolute(forwardOutput, result: &magnitudes)
//              }
//            }
//          }
//        }
//
//        return getSpectrogram(magnitudes: magnitudes)
//    }
}
