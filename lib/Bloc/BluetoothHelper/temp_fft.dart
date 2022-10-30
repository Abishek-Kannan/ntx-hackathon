import 'package:scidart/numdart.dart' as np;
import 'package:scidart/scidart.dart' as sci;

np.Array psd(np.Array signal,double fs,int nperseg,int nfft)
{
  var signallength = signal.length ;//length of signal
  var noverlap = nperseg/2;//number of overlapping points

  int numberOfSegments = 1 + ((signallength - nperseg) ~/ (nperseg - noverlap)).toInt(); //calculating number of segments depending upon window length , overlap and total length of signal
  var array = np.Array2d.fixed(numberOfSegments, nperseg, initialValue: 0); //initialising an array with fixed size and initial common value to all element
  var window = np.Array.fixed(nfft,initialValue:1);
  for(var i = 0;i < numberOfSegments;i++)
  {
    var temp = signal.getRangeArray((i * (nperseg - noverlap)).toInt(), ((i + 1) * nperseg - i * noverlap).toInt());//extracting the window of signal , and multiplying it by hanning window
    // print(sci.fft(np.arrayToComplexArray(temp))); //taking fft of the windowed signal and storing its abs value
    array[i] = arrayComplexAbs(sci.fft((np.arrayToComplexArray(temp))));
    array[i] = window*array[i];
    array[i] = np.arrayPow(array[i],2);
  }
  //array = array*array;
  np.Array? output = np.Array.fixed(nfft);
  for(int j = 0;j<nfft;j++)
  {
    output[j] = sumofelements(array.getColumn(j));//summing column values , i.e. adding zeroth element of first window, zeroth element of second window .... zeroth element of last window , and similar to all the elements
    output[j] = output[j] / numberOfSegments;//averaging
  }
  //output = output.getRangeArray(0, 257);//uncomment if you want output only for positive frequencies
  // output = np.arrayDivisionToScalar(np.arrayMultiplyToScalar(output, 2), 100000);

  return output;
}


//double roundDouble(double value, int places){
//num mod = pow(10.0, places);
//return ((value * mod).round().toDouble() / mod);
//}



dynamic array2dDivisionToScalar(np.Array2d a, num b,)
{
  for (var i = 0; i < a.row; i++) {
    for (var j = 0; j < a.column; j++) {
      a[i][j] = a[i][j] / b;
    }
  }
  return a;
}

dynamic array2dMultiplyToScalar(np.Array2d a, num b,)
{
  for (var i = 0; i < a.row; i++) {
    for (var j = 0; j < a.column; j++) {
      a[i][j] = a[i][j] *b;
    }
  }
  return a;
}

np.Array arrayComplexAbs(np.ArrayComplex a) {
  var c = np.Array.fixed(a.length);
  for (var i = 0; i < a.length; i++) {
    c[i] = np.complexAbs(a[i]);
  }
  return c;
}

np.Array listComplexAbs(List<np.Complex> a) {
  var c = np.Array.fixed(a.length);
  for (var i = 0; i < a.length; i++) {
    c[i] = np.complexAbs(a[i]);
  }
  return c;
}

double sumofelements(np.Array? a) {
  double sum = 0.0;

  if (a == null) {
    print('value is null');
  }
  else {
    for (int i = 0; i < a.length; i++) {
      sum = sum + a[i];
    }
  }
  return sum;
}
