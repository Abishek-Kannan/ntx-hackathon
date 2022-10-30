import 'package:scidart/numdart.dart' as np;
import 'package:scidart/scidart.dart' as sci;
import 'welch_method.dart';
import 'Global_Variables_EEG.dart';
import 'Trapz_Integral_method.dart';

double calibration_method(np.Array EEG_signal) {
  var baseline_score = 0.0;
  var b = np.Array([0.000761323, 0.00456794, 0.0114199, 0.0152265, 0.0114199, 0.00456794, 0.000761323]); //lowpass filter - Order 6 - fc - 30 Hz
  var a = np.Array([1, -3.16609, 4.57939, -3.73273, 1.78649, -0.471751, 0.0534038]);
  var signal_filt = sci.lfilter(b, a, EEG_signal);
  var power_EEG = welch_method(signal_filt);
  var theta_power = power_EEG.getRangeArray(16, 33); //theta band power array 4 - 8 Hz
  var theta_power_value = Trapz_Integral_method(theta_power);
  var alpha_power = power_EEG.getRangeArray(32, 49); //alpha band power array 8 - 12 Hz
  var alpha_power_value = Trapz_Integral_method(alpha_power);
  var total_power_value = power_EEG.getRangeArray(17, 121); //cortex band power array 4 - 30 Hz
  var total_power = Trapz_Integral_method(total_power_value);
  var band_power = Trapz_Integral_method(power_EEG.getRangeArray(24, 41)); //power array in 6 - 10 Hz(Focus Band)
  baseline_score = band_power / total_power;
  //print(baseline_score);
  return baseline_score;
}
