import 'package:scidart/numdart.dart' as np;
import 'package:scidart/scidart.dart' as sci;
import 'dart:math' as math;

np.Array fft_method(np.Array signal){
  var hann_win = sci.hann(signal.length);                                                 //Generate the hanning window same as the length of the signal
  var sig_win = signal*hann_win;                                                          //Multiply the hanning window with the signal
  var sig_fft = sci.fft(np.arrayToComplexArray(sig_win));                                 //Generating the fft for signal
  var sig_fft_abs = np.arrayComplexAbs(sig_fft);                                          //Computing the absolute of the fft values
  //var sig_fft_abs_scale = np.arrayDivisionToScalar(np.arraySqrt(sig_fft_abs), np.sqrt(2));//Applying scaling to the computed fft values
  return sig_fft_abs;
}
/*
np.ArrayComplex fft(np.Array signal){
  var X_temp  = np.Complex(real:0, imaginary:0);
  np.ArrayComplex fft_complex = np.ArrayComplex.empty();
  var N = signal.length;
  var i = np.Complex(real:0, imaginary:1);
  for(int k=0; k<N; k++){
    for(int n=0; n<N; n++){
      var factor = np.complexMultiplyScalar(i, -1*2*np.pi*k*n/N);
      var exp_val = np.complexExp(factor);
      X_temp = X_temp + np.complexMultiplyScalar(exp_val, signal[n]);
    }
    fft_complex[k] = X_temp;
    X_temp = np.Complex(real:0, imaginary:0);
  }
  return fft_complex;
}*/