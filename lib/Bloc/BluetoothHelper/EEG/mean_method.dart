import 'package:scidart/numdart.dart' as np;

double mean_method(np.Array? sig){
  double sum = 0.0;
  double mean_val = 0.0;
  if (sig == null) {
    print('value is null');
  }
  else {
    for (int i = 0; i < sig.length; i++) {
      sum = sum + sig[i];
    }
    mean_val = sum/sig.length;
  }
  return mean_val;
}