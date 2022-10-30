import 'package:scidart/numdart.dart' as np ;
import 'temp_fft.dart';
import 'Global_Variables_PPG.dart';

LF_HF_Computation(np.Array signal)
/*This function will be used to calculate the stress score for the Heart Meditation session , post the session
is complete.
As we will be detecting peaks in real time and displaying the stress score in real time , we will use the interpolated_signal variable which has the
interpolated HRV data .
We convert the interpolated HRV curve to frequency domain and compute the Low frequency and high frequency power ,normalize them and use the HF power
 to compute the stress score
*/
{
  int window = 64;//window size
  int nfft = 64;//number of fft point
  double fs_2 = 4;//sampling freq for hrv
  double f_res = fs_2/nfft;//frequency resolution
  double t_res = 1/f_res;
  np.Array hrv_power = psd(signal,fs_2,window,nfft);
  np.Array LF_power = hrv_power.getRangeArray((0.04*t_res).toInt(),(0.15*t_res).toInt());
  double LF_power_value = np.trapzArray(LF_power);//calculating LF power by AUC
  np.Array HF_power = hrv_power.getRangeArray((0.15*t_res).toInt(),(0.4*t_res).toInt());
  double HF_power_value = np.trapzArray(HF_power);//calculating HF power by AUC
  double  Total_power = LF_power_value + HF_power_value;//calculating total power
  double LF_norm = LF_power_value/Total_power;//nomalizing LF power
  double HF_norm = HF_power_value/Total_power;//normalizing HF power
  double Stress_score = (HF_norm*100000);//final stress score
  if(Stress_score>100)
  {
    Stress_score = 100;
  }
  return Stress_score;
}