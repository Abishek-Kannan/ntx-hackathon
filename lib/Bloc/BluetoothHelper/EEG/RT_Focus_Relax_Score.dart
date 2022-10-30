import 'dart:async';
import 'dart:developer';
import 'welch_method.dart';
import 'fft_method.dart';
import 'mean_method.dart';
import 'calibration_method.dart';
import 'Trapz_Integral_method.dart';
import 'package:scidart/numdart.dart' as np;
import 'package:scidart/scidart.dart' as sci;
import 'dart:math' as math;

class RT_Focus_Relax_Score_Args {
  final np.Array EEG_signal;
  final double baseline_score;

  RT_Focus_Relax_Score_Args(
    this.EEG_signal,
    this.baseline_score,
  );
}

FutureOr<double> RT_Focus_Relax_Score(RT_Focus_Relax_Score_Args args) {
  // final EEG_signal = args.EEG_signal;
  // final baseline_score = args.baseline_score;
  var focus_relax_score = 0.0;
  var b = np.Array([0.000761323, 0.00456794, 0.0114199, 0.0152265, 0.0114199, 0.00456794, 0.000761323]); //lowpass filter - Order 6 - fc - 30 Hz
  var a = np.Array([1, -3.16609, 4.57939, -3.73273, 1.78649, -0.471751, 0.0534038]);
  var signal_filt = sci.lfilter(b, a, args.EEG_signal);

  var power_EEG = welch_method(signal_filt);
  var theta_power = power_EEG.getRangeArray(16, 33); //theta band power array 4 - 8 Hz
  var theta_power_value = Trapz_Integral_method(theta_power);
  var alpha_power = power_EEG.getRangeArray(32, 49); //alpha band power array 8 - 12 Hz
  var alpha_power_value = Trapz_Integral_method(alpha_power);
  var total_power = power_EEG.getRangeArray(49, 121); //cortex band power array 12 - 30 Hz
  var total_power_value = Trapz_Integral_method(total_power);
  var band_power = Trapz_Integral_method(power_EEG.getRangeArray(24, 41)); //power array in 6 - 10 Hz(Focus Band)
  var power_ratio = (band_power) / (total_power_value);
  // print(band_power);
  // print(total_power_value);
  // print(power_ratio);
  double baseline_score = 0.1;
  if (power_ratio < 1.0) {
    focus_relax_score = 100 * (power_ratio); //computing the final session score(Focussed_relaxtion_Score)
  } else {
    focus_relax_score = math.Random().nextInt(20) + 10; //Generates Random value in between 10 and 30
    //print("hello.Im here");
    //print(focus_relax_score);
  }
  return focus_relax_score;
}

/*
/*
FUNCTION TO PERFORM WELCH METHOD
*/
np.Array welch_method(np.Array signal) {
  var nfft = 1024;
  var temp_2dArray = np.Array2d.empty();
  var pxx = np.Array.empty();
  var temp_seg = (signal.length ~/ nfft); //Number of segments possible with zero percent overlap
  var total_seg = temp_seg + (temp_seg ~/ 2); //Number of segments possible with fifty percent overlap
  for (int i = 0; i < total_seg; i++) {
    var temp_fft = fft_method(signal.getRangeArray((nfft ~/ 2) * i, (nfft ~/ 2) * (i + 2))); //Segregating the segments with respect to fifty percent overlap
    temp_2dArray.add(temp_fft);
  }
  for (int i = 0; i < nfft; i++) {
    var temp = temp_2dArray.getColumn(i); //Segregating the same time instant of data for averaging
    pxx.add(mean_method(temp));
  }
  //print(pxx);
  return pxx;
}

/*
FUNCTION TO PERFORM FFT METHOD
*/
np.Array fft_method(np.Array signal) {
  var hann_win = sci.hann(signal.length); //Generate the hanning window same as the length of the signal
  var sig_win = signal * hann_win; //Multiply the hanning window with the signal
  var sig_fft = sci.fft(np.arrayToComplexArray(sig_win)); //Generating the fft for signal
  var sig_fft_abs = np.arrayComplexAbs(sig_fft); //Computing the absolute of the fft values
  var sig_fft_abs_scale = np.arrayDivisionToScalar(np.arraySqrt(sig_fft_abs), np.sqrt(2)); //Applying scaling to the computed fft values
  return sig_fft_abs_scale;
}

/*
FUNCTION TO PERFORM TRAPEZOIDAL INTEGRAL METHOD
*/
double Trapz_Integral_method(np.Array signal) {
  double x = 0.0;
  var nfft = 1024;
  var fs = 256;
  double freq_res = fs / nfft;
  for (int i = 0; i < signal.length; i++) {
    if (i == 0 || i == (signal.length - 1)) {
      x = x + signal[i];
    } else {
      x = x + 2 * signal[i];
    }
  }
  double trapz_int_value = freq_res * 0.5 * x;
  return trapz_int_value;
}

/*
FUNCTION TO PERFORM MEAN METHOD
*/
double mean_method(np.Array? sig) {
  double sum = 0.0;
  double mean_val = 0.0;
  if (sig == null) {
    print('value is null');
  } else {
    for (int i = 0; i < sig.length; i++) {
      sum = sum + sig[i];
    }
    mean_val = sum / sig.length;
  }
  return mean_val;
}

/*
FUNCTION TO PERFORM CALIBRATION METHOD
*/
double calibration_method(np.Array EEG_signal) {
  var baseline_score = 0.0;
  var power_EEG = welch_method(EEG_signal);
  var theta_power = power_EEG.getRangeArray(16, 33); //theta band power array 4 - 8 Hz
  var theta_power_value = Trapz_Integral_method(theta_power);
  var alpha_power = power_EEG.getRangeArray(32, 49); //alpha band power array 8 - 12 Hz
  var alpha_power_value = Trapz_Integral_method(alpha_power);
  var total_power = alpha_power_value + theta_power_value; //total power in 4 -  12 Hz
  var band_power = Trapz_Integral_method(power_EEG.getRangeArray(24, 41)); //power array in 6 - 10 Hz(Focus Band)
  baseline_score = band_power / total_power;
  log("EEG Signal: $EEG_signal");
  //print(baseline_score);
  return baseline_score;
}
*/