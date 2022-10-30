import 'package:scidart/numdart.dart' as np;
import 'package:scidart/scidart.dart' as sci;
import 'fft_method.dart';
import 'mean_method.dart';
import 'Global_Variables_EEG.dart';

np.Array welch_method (np.Array signal){
  var nfft = 1024;
  var temp_2dArray = np.Array2d.empty();
  var pxx = np.Array.empty();
  var temp_seg = (signal.length~/nfft);                                                //Number of segments possible with zero percent overlap
  var total_seg = temp_seg + (temp_seg~/2);                                               //Number of segments possible with fifty percent overlap
  for (int i = 0; i<total_seg; i++){
    var temp_fft = fft_method(signal.getRangeArray((nfft~/2)*i, (nfft~/2)*(i+2)));    //Segregating the segments with respect to fifty percent overlap
    temp_2dArray.add(temp_fft);
  }
  for(int i = 0; i<nfft;i++){
    var temp = temp_2dArray.getColumn(i);                                             //Segregating the same time instant of data for averaging
    pxx.add(mean_method(temp));
  }
  //print(pxx);
  return pxx;
}

