import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';
import 'package:scidart/numdart.dart' as np;
import 'Global_Variables_PPG.dart';
/*
This function interpolates the HRV data using the CubicSpline interpolation method.
We are taking 3 points to fit a cubic polynomial to it.
Note : Pls refer the Cubic Spline Documentation before having a looking at the code
 */


np.Array PPG_interpolation(double sample,double i)//the functions takes input as the recent sample and the sample index
{
  y_3 = sample;//y_3 stores the current sample value , it needs to be defined as global variable
  x_3 = i/256;//x_3 stores the time index of the sample - what time has been elapsed when we have received the sample, needs to be defines as global variable
  var A = np.Array2d([np.Array([(3*np.pow(x_3,2)).toDouble() ,(2*x_3).toDouble() , 1 , 0 , (-3*np.pow(x_3,2)).toDouble() , (-2*x_3).toDouble() , -1 , 0 ]),
    np.Array([np.pow(x_1,3).toDouble() , np.pow(x_1,2).toDouble() , x_1.toDouble() , 1 , 0 , 0, 0, 0]),
    np.Array([np.pow(x_2,3).toDouble() , np.pow(x_2,2).toDouble() , x_2.toDouble()   , 1 , 0 , 0 , 0, 0]),
    np.Array([ 0 , 0 , 0 , 0 , np.pow(x_2,3).toDouble() , np.pow(x_2,2).toDouble() , x_2.toDouble() , 1]),
    np.Array([ 0 , 0 , 0 , 0 , np.pow(x_3,3).toDouble() , np.pow(x_3,2).toDouble()  , x_3.toDouble() , 1]),
    np.Array([(3*np.pow(x_2,2)).toDouble() , (2*x_2).toDouble() , 1 , 0 , (-3*np.pow(x_2,2)).toDouble() , -2*x_2.toDouble() , -1 , 0]),
    np.Array([(6*x_2).toDouble() , 2 , 0 , 0 , (-6*x_2).toDouble() , - 2 , 0 , 0]),
    np.Array([1 , 0 , 0 , 0, -1 , 0 , 0, 0])]);//These are the conditional equations that we are using to fit the polynomial , each row is one condition
  var B = np.Array([0, y_1.toDouble() , y_2.toDouble() , y_2.toDouble() ,y_3.toDouble() ,0, 0 , 0]);//corresponding output or 'y' of the above equations used
  var temp_matrix = Matrix.fromList(np.matrixPseudoInverse(A));//taking an inverse of the condition matrix
  //var temp_vector = np.arrayToColumnMatrix(B);//converting the output array to a column vector so that we can perform the further computation
  var temp_vector = Vector.fromList(B);
  var X  = temp_matrix * temp_vector;//computing the coefficients of the cubic fit for the given data points
  //  var t1 = np.Array((np.linspace(x_1.toDouble() , x_2.toDouble() , num:  (fs*(x_2-x_1)).toInt() )));
  var t2 = createArrayRange(x_2,x_3,1/fs);//creating a time array for getting the values of the interpolated function at these points
  var temp = np.ones(t2.length);
  var f2 = np.arrayMultiplyToScalar(np.arrayPow(t2, 3), X[4][0]) + np.arrayMultiplyToScalar(np.arrayPow(t2, 2), X[5][0]) + np.arrayMultiplyToScalar((t2), X[6][0])
        + np.arrayMultiplyToScalar(temp, X[7][0]) ;//using the coefficients of the cubic curve we find the HRV in the interval of x_2 to x_3
  t.addAll((t2));
  f_final.addAll((f2));
  x_1 = x_2 ; y_1 = y_2;
  x_2 = x_3; y_2 = y_3;//updation of the sample points
  return f2;//we return the array of HRV values in the interval of x_2 to x_3.
}



np.Array createArrayRange(double start , double stop ,double step ) {

var N = double.parse((stop-start).toStringAsFixed(2))~/step;
var space = np.Array.fixed((N+1).toInt());
for(var i = 0;i < N+1 ; i++)
{
space[i] = start + i*(step);
}
return space;
}
