//This file will be containing all the global variables
import 'package:scidart/numdart.dart' as np ;

//The following are the global variables for PPG peak detection
double fs = 256; //sampling frequency of PPG data
double RT_stress_score = 50;//initial stress score,will be used for RT stress score
var ppg_sq_n = np.Array.empty();//defining a sample sequence which will act as a temporary storage for processed samples.
//Below we are initialising sample sequences which we will be using for storing the processed samples and then use for averaging/integration.
double ppg_sq_n1 = 0;
double ppg_sq_n2 = 0;
double ppg_sq_n3 = 0;
double ppg_sq_n4 = 0;
double ppg_sq_n6 = 0;
double ppg_sq_n5 = 0;
double ppg_sq_n7 = 0;
double ppg_sq_n9 = 0;
double ppg_sq_n8 = 0;
//below are the filter buffers
double f_bp_n26 = 0;
double f_bp_n25 = 0;
double f_bp_n24 = 0;
double f_bp_n23 = 0;
double f_bp_n22 = 0;
double f_bp_n21 = 0;
double f_bp_n20 = 0;
double f_bp_n19 = 0;
double f_bp_n18 = 0;
double f_bp_n17 = 0;
double f_bp_n16 = 0;
double f_bp_n15 = 0;
double f_bp_n14 = 0;
double f_bp_n13 = 0;
double f_bp_n12 = 0;
double f_bp_n11 = 0;
double f_bp_n10 = 0;
double f_bp_n9 = 0;
double f_bp_n8 = 0;
double f_bp_n7 = 0;
double f_bp_n6 = 0;
double f_bp_n5 = 0;
double f_bp_n4 = 0;
double f_bp_n3 = 0;
double f_bp_n2 = 0;
double f_bp_n1 = 0;
double f_bp_n = 0;
double R_pk_time_prev = 0;//It will store the sample index of the previous peak detected.
var j = 0;
var k = 0;
var ppg_filt = np.Array.empty();
var ppg_filt1 = np.Array.empty();
double ppg_prev_mean = 0;//previous running mean
double ppg_mean = 0;//current running mean
var thresh_sig = np.Array.empty();//current thresholding value : ppg_mean + ppg_sd
double ppg_sd = 0;//current running std deviation
double ppg_sd_temp_prev = 0;//previous running std deviation
double ppg_sd_temp = 0;//temp variable used for computing std deviation
var ppg_diff = np.Array.empty();
var ppg_clip = np.Array.empty();
var R_pk_time = np.Array.empty();//sample index of the signal when peak is detecting
var interpolated_signal = np.Array.empty();//this array will be storing the data of interpolated HRV curve function values

//The following are global variables for HRV estimation script

var peak_differences = np.Array.empty();
var f = np.Array.empty();
var t = np.Array.empty();
var old_peak = 0;

//The following are the global variables for Interpolation script

double y_3 = 0;
double x_3 = 0;
double x_1 = 0;
double x_2 = 0;
double y_2 = 0;
double y_1 = 0;
np.Array f_final = np.Array.empty();



