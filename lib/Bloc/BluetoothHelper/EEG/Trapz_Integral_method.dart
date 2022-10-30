import 'package:scidart/numdart.dart' as np;
//import 'Global_Variables_EEG.dart';

double Trapz_Integral_method(np.Array signal) {
  double x = 0.0;
  double freq_res = 0.25;  //fs/nfft: 256/1024 = 0.25
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
