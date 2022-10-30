//This file contains all the global variables for EEG data processing
import 'package:scidart/numdart.dart' as np ;

//EEG calibration global variables
int nfft = 1024;
int fs = 256;
int nperseg = nfft;
double freq_res = fs/nfft;
double baseline_score = 0.0;
double focus_relax_score = 0.0;
//Session Focus Score EEG global variables
np.Array filtered_EEG_signal = np.Array.empty();//this variable will be storing the filtered eeg signal post the session completion
double focussed_relaxation_score = 0;

//RT EEG global variables
double f_bp_n5 = 0;//eeg signal buffers
double f_bp_n4 = 0;
double f_bp_n3 = 0;
double f_bp_n2 = 0;
double f_bp_n1 = 0;
double f_bp_n = 0;
double k =0;
var eeg_data = np.Array.empty();//this array will be storing the eeg data
//var eeg_data = np.Array.fixed(1024,initialValue: 0);
var eeg_diff = np.Array.empty();
var eeg_clip = np.Array.empty();
int current_index  = -1;//this is a temporary variable we will be using to keep the count of number of samples received from the EEG sensor
var prev_index_temp = 0; //storing the index of the lower index element in the window , will be used in the formation of windows.
var window_4second = np.Array.fixed(1024,initialValue:0);
var RT_Stress_score = np.Array.empty();

int i = -1;//this variable will be storing the index for the latest stress score from variable score.
//ex : lets say we have recorded data of 20 seconds which will have 5 windows of 4 seconds each and score must have stored 5 stress scores ,score[0] will
//store value of stress score of 1st 4 second accumulated data, score[1] will store stress score from 4 to 8 seconds.