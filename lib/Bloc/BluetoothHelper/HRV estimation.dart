import 'package:scidart/numdart.dart' as np ;
import 'Interpolation.dart';
import 'Global_Variables_PPG.dart';

/*
*Post the peak detection , next step is detection of Heart Rate Variability(HRV). Heart Rate Variability is the difference between two consecutive heart beats.
*As the time difference between two heart beats is not constant , we try to interpolate the curve to get a continuous fit of the HRV data points.
 */
np.Array hrv_detection(np.Array peaks,double fs,int i)//this functions takes the sample index of the peaks detected in the ppg signal and the sampling frequency
{
    var interpolated_signal_temp = np.Array.empty();
    peak_differences.add((peaks[i-1] - peaks[i - 2]) /
        fs); //calculating the heart rate variability by calculating the time difference between the two heart beats detected.
    interpolated_signal_temp.addAll(PPG_interpolation(peak_differences[i-2],
        peaks[i -1])); //here we are calling interpolation to fit the newly added HRV point to the interpolated HRV curve
    return interpolated_signal_temp;

}



















