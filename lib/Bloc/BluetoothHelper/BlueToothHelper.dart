import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Printer.dart';
import 'EEG/RT_Focus_Relax_Score.dart';
import 'Res/BLEConstants.dart';
import 'Res/BLESession.dart';
import 'Res/BluetoothException.dart';
import 'Res/BluetoothSpecification.dart';
import 'package:scidart/numdart.dart' as np;
import 'dart:math';
import 'HRV estimation.dart';
import 'Global_Variables_PPG.dart';
import 'LF_HF_Computation.dart';

enum Nullable { NULL }

class BubbleConstants {
  static double RADIUS = 50.0;

  static String deviceListTitle = "Device Not Connected";
  static String deviceListButton = "Search for Devices";
}

abstract class BluetoothListener {
  void setOnDisconnectListener({required Function() onDisconnectListener});

  late Function() onDisconnectListener;

  void setOnConnectListener({required Function() onConnectListener});

  late Function() onConnectListener;

  late Function() bingeConnectionListener;

  void setOnDataAvailable(
      {required Function(List<double> data) onDataAvailable});

  late Function(List<double> data) onDataAvailable;
  //
  // late Future<Function> onAutoConnectionListener;


}

enum FlutterBlueState {
  SCANNING,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  DISCONNECTING
}

class BluetoothHelper implements BluetoothListener {
  final flutterReactiveBle = FlutterBlue.instance;
  static final BluetoothHelper _sharedInstances = BluetoothHelper._();

  FlutterBlueState bleState = FlutterBlueState.DISCONNECTED;

  BluetoothSpecification bluetoothSpec = BluetoothSpecification("100");
  
  // String _deviceServiceID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  String _deviceServiceID = "49535343-fe7d-4ae5-8fa9-9fafd205e455";
  String deviceID = "";
  String deviceName = "";
  //remote
  // String _deviceCharacteristicID = "49535343-1e4d-4bd9-ba61-23c647249616";
  String _deviceCharacteristicID = "0000FFE1-0000-1000-8000-0080-5F9B34FB";
  // String _deviceCharacteristicID = "0000ffe1-0000-1000-8000-00805f9b34fb";

  late BluetoothCharacteristic characteristic;

  bool _binge = false;

  @override
  Function() onConnectListener = () {
    print("BLE Device Connected Callback");
  };

  @override
  Function() onDisconnectListener = () {
    print("BLE Device Disconnected Callback");
  };

  @override
  Function() bingeConnectionListener = () {
    print("Binge Connection Listener");
  };




  @override
  Function(List<double> data) onDataAvailable = (data) {};

  List<BluetoothDevice> availableDevices = [];
  List<BluetoothDevice> pairedDevices = [];

  late BluetoothDevice device;

  bool _DeviceConnected = false;

  late SharedPreferences _sharedPreferences;

  bool get isDeviceConnected => _DeviceConnected;
  String bluetoothResponseText = "";

  List<String> bluetoothSessionResults = [];
  double _realTimeStressScore = 0;
  List<double> _signal = [];
  List<String> _scores = [];
  List<BLESession> bleSessions = [];
  int _sessionStressScore = 0;

  late BLESession latestBLESession;

  BluetoothHelper._() {
    printBlueLog("Instance");
    bleState = FlutterBlueState.DISCONNECTED;


    SharedPreferences.getInstance().then((value) => {
      this._sharedPreferences = value
    });

    ///Auto Connect Logic
    ///
    /// Listens to connected Devices and updates state if Discoverable
    this.flutterReactiveBle.connectedDevices.asStream().listen((devices) {

      printBlueLog("Auto Connect Flutter Devices");
      printBlueLog(devices);
      if (devices.length > 0) {
        this._setDeviceParams(devices[0]);
        this.listenDevice();
        _monitorDeviceState(devices[0]);
      }
    });
  }

  factory BluetoothHelper() => _sharedInstances;

  StreamSubscription? connection;
  StreamSubscription? scan;

  void enableReadWriteModeToThisDevice(
      {required String deviceId,
      // required Uuid serviceId,
      // required Uuid characteristicId,
      required Function onSuccess}) {}

  /// [isConnected] Returns whether the Device is connected to BLE
  ///
  /// @throws error if the device is connected
  ///
  /// else
  ///
  /// Nothing
  ///
  /// [Peace!]
  isConnected() async {
    try {
      if (!this.isDeviceConnected)
        throw BluetoothNotConnectedException(
            "Bluetooth Not Connected. Ensure that Bluetooth is Connected");
      // await characteristic.write(utf8.encode("1"));
    } catch (error) {
      throw BluetoothNotConnectedException(
          "Bluetooth Not Connected. Ensure that Bluetooth is Connected");
    }
  }

  /// [ensureBingeConnected] is a function which Monitors Bluetooth status during transaction of data
  ///
  /// @IMPORTANT - Must be Called before Starting a continuous Bluetooth Session
  ///
  /// @help Called before starting a Session to Ensure ble is connected through the Session
  ///
  /// @param
  ///
  /// onDisconnected - A Callback When the bluetooth turns off or when Data is unavailable
  ///
  /// onDataAvailable - A Callback to share the latest Received Data from BLE
  ensureBingeConnected(
      {required Function() onDisconnected,
      required Function(List<double> data) onDataAvailable}) {
    this._binge = true;
    this.bingeConnectionListener = onDisconnected;
    this.onDataAvailable = onDataAvailable;
    printer("Binge Connected Enabled");
  }

  /// [ignoreBingeConnected] is a function which must be called once the Session is Completed
  ///
  /// @IMPORTANT - Must be Called at the End of Every Session whenever Binge Session is Enabled
  ///
  /// @help Called After a Session completes
  ///
  /// @param
  ///
  ignoreBingeConnected() {
    this._binge = false;
    this.bingeConnectionListener = () {
      print("Binge Connection Listener");
    };
  }

  /// [connectDevice]
  ///
  /// @params
  ///
  /// [BluetoothDevice] device - BLE must be connected
  ///
  /// onSuccess - A CallBack for successful connection
  ///
  /// onFailure - A CallBack for Failed connection
  ///
  /// onConnecting - A CallBack while Connecting
  ///
  /// onDisconnecting - A CallBack while Disconnecting
  void connectDevice({
    required BluetoothDevice device,
    required Function(BluetoothDevice) onSuccess,
    required Function(BluetoothDevice) onFailure,
    required Function(BluetoothDevice) onConnecting,
    required Function(BluetoothDevice) onDisconnecting,
  }) async {
    // await disconnectAllConnectedDevice();
    flutterReactiveBle.stopScan();
    _connectDevice(device, onSuccess, onFailure, onConnecting, onDisconnecting);
  }

  /// Refer [connectDevice]
  void _connectDevice(
    BluetoothDevice device,
    Function(BluetoothDevice) onSuccess,
    Function(BluetoothDevice) onFailure,
    Function(BluetoothDevice) onConnecting,
    Function(BluetoothDevice) onDisconnecting,
  ) async {
    bleState = FlutterBlueState.CONNECTING;
    printBlueLog("Connection Attempt to ${this.bleState}");

    this.device = device;

    ///ENSURES TIME ZONED EXCEPTION.
    ///
    ///CATCH TIMEOUT EXCEPTION
    ///
    ///TIMEOUT EXCEPTION IS NOT SUPPORTED IN CURRENT FLUTTER_BLUE VERSION
    runZoned(
        () => {
              this
                  .device
                  .connect(
                      timeout:
                          Duration(seconds: BLEConstants.connectionDuration),
                      autoConnect: true)
                  .then((value) => {
                        printBlueLog("Connected t0 Device ${device}"),
                        this._setDeviceParams(device),
                        this.listenDevice(),
                        this._saveDevice(device),
                        onSuccess.call(device),
                        _monitorDeviceState(device)
                        // this.listenDevice("1")
                      })
            }, onError: (error) {
      printBlueLog("Error Connecting ${device.name}"
          "Error : ${error}");
      bleState = FlutterBlueState.DISCONNECTED;
      onFailure.call(device);
    });
  }

  ///
  /// List Available Devices
  ///
  /// @param
  /// [onListAvailable] A Callback which lists available Devices
  ///
  /// [onError] A Callback when an error is Encountered
  void listDevices(
      Function(List<BluetoothDevice> availableDevices) onListAvailable,
      Function(dynamic) onError) async {
    try {
      await this.device.disconnect();
      // await this.disconnectAllConnectedDevice();
    } catch (error) {
      printBlueLog(error);
    }
    await connection?.cancel();

    //CANCEL BEFORE SCANNING
    await scan?.cancel();

    // availableDevices.clear();
    printBlueLog("Available Devices Cleared");

    this._listDevices(onListAvailable, onError);
  }

  ///
  /// Disconnect from all Connected or Non-Connected Devices
  ///
  Future<void> disconnectAllConnectedDevice() async {
    var res = await this.flutterReactiveBle.connectedDevices;
    await res.map((e) async => await e.disconnect());
    printBlueLog("Disconnected All Connected Devices");
  }

  ///
  /// Refer to [listDevices]
  void _listDevices(Function(List<BluetoothDevice> availableDevices) callback,
      Function(dynamic) onError) async {
    printBlueLog("Scanning Devices");
    availableDevices.clear();
    this.flutterReactiveBle.scan(
        withServices: [
          // Guid(this._deviceServiceID)
        ],
        scanMode: ScanMode.lowLatency,
        allowDuplicates: false,
        timeout:
            const Duration(seconds: BLEConstants.scanDuration)).listen((event) {
      callback.call(availableDevices);
    }).onDone(() {
      printBlueLog("Finished Scanning");
    });

    flutterReactiveBle.scanResults.listen((devices) {
      // filters only devices which has names

      availableDevices = devices
          .where((element) => element.device.name.isNotEmpty)
          .toList()
          .map((device) => device.device)
          .toList();

      this.autoConnect();

      printBlueLog("Available Devices ${availableDevices}");
    }).onError((error) => {onError.call(error)});
  }

  ///
  /// Monitors the device state until it is connected to device
  ///
  void _monitorDeviceState(BluetoothDevice device) {
    device.state.listen((state) {
      printBlueLog("${device.name} Blestate ${state}");
      switch (state) {
        case BluetoothDeviceState.connecting:
          printBlueLog("Connecting ${device.name}");
          this.bleState = FlutterBlueState.CONNECTING;
          break;

        case BluetoothDeviceState.connected:
          printBlueLog("Connected ${device.name}");
          this.bleState = FlutterBlueState.CONNECTED;
          this._setDeviceParams(device);
          break;

        case BluetoothDeviceState.disconnecting:
          printBlueLog("Disconnecting ${device.name}");
          this.bleState = FlutterBlueState.DISCONNECTING;
          break;

        case BluetoothDeviceState.disconnected:
          printBlueLog("Disconnected ${device.name}");
          onDisconnectListener.call();
          this.bleState = FlutterBlueState.DISCONNECTED;
          this._reset();
          break;
      }
    });
  }

  ///
  /// Listen to the values sent from BlE
  ///
  /// Identifies the Generic Service and Characteristic to Read, Write and Listen to Changes
  ///
  /// Sets Characteristic ID of the to-connect Device, Starts Listening to Incoming Data
  Future<bool> listenDevice() {
    return _subscribe();
  }

  /// Refer to [listenDevice]
  Future<bool> _subscribe() async {
    try {
      bluetoothSessionResults = [];

      printBlueLog("Discovering Ble Services and Characteristics");
      await _discoverServices();

      printBlueLog("Listening to Characteristic ${this.characteristic}");

      if (!this.characteristic.isNotifying)
        await this.characteristic.setNotifyValue(true);

      printBlueLog("Notification On ${this.characteristic.isNotifying}");

      this.characteristic.value.listen((event) {
        String res = utf8.decode(event);
        try {
          // ${event}
          printBlueLog("Listening..... ${res}");
          if(res.length > 0){
            List<double> data =
          res.split("\n").where((element) => element.length > 0).map((e) {
            try {
              return double.parse(e);
            } catch (error) {
              return 0.0;
            }
          }).toList();
          this.onDataAvailable.call(data);
          //calculateRealTimeScore(data[0]);
          }
          
        } catch (error) {
          printer("Error");
          printer(error);
        }
        this.bluetoothResponseText = res;
        this.bluetoothSessionResults.add(res);
      });
      return true;
    } catch (error) {
      printBlueLog("Error ${error}");
      return false;
    }
  }

  void calculateRealTimeScore(dynamic val) async {
    final startTime = DateTime.now();
    
    late final List<double> signalSlice;
    _signal.add(val);
    if (_signal.length > 2048) {
      signalSlice = _signal.sublist(_signal.length - 2048);
    } else {
      return;
    }
  //  _sessionStressScore = (await compute(
  //         RT_Focus_Relax_Score,
  //         RT_Focus_Relax_Score_Args(
  //           np.Array(_signal),
  //           Random().nextInt(10) + 30,
  //         ),
  //       ))
  //           .toInt();
  //   print("session score" + _sessionStressScore.toString());
    
  }

  ///
  /// Every Bluetooth has Services associated with it
  /// Discovering the services and its characteristics with the bluetooth
  ///
  Future<void> _discoverServices() async {
    List<BluetoothService> blueServices = await this.device.discoverServices();

    for (var value in blueServices) {
      for (var characteristic in value.characteristics) {
        if (characteristic.properties.notify == true &&
            characteristic.properties.write == true) {
          this.characteristic = characteristic;
          printBlueLog("Characteristic Found ${this.characteristic}");
          break;
        }
      }
      print("\n\n");
    }
  }

  ///
  /// Command to Write to obtained Characteristic
  ///
  /// @param String
  ///
  bool writeToCharacteristic(String s) {
    try {
      this.characteristic.write(utf8.encode(s), withoutResponse: false);
      return true;
    } catch (error) {
      this._DeviceConnected = false;
      this._reset();
      return false;
    }
  }

  /// Function which Logs Bluetooth Events and Callbacks
  void printBlueLog(Object? object) {
    print("Bluetooth : ${object.toString()}");
  }

  ///
  /// stop() - BLUETOOTH RESET AND STOPS ANY ON GOING PROCESS
  ///
  void stop() async {
    this._reset();
    printBlueLog("Bluetooth Stopped");
  }

  ///
  /// DISCONNECT DEVICE
  ///
  /// @param onDisconnected
  void disconnectDevice({Function? onDisconnected}) {
    if (this.deviceID != "" && this.deviceName != "") {
      this.device.disconnect();
    }
  }

  ///
  /// Set Device Params of the Connected Device
  void _setDeviceParams(BluetoothDevice device) {
    this.deviceID = device.id.id;
    this.deviceName = device.name;
    this.device = device;
    this._DeviceConnected = true;
  }

  ///
  /// Reset * Values
  ///
  /// Associated with [FlutterBlue], [BluetoothHelper] etc.
  void _reset() async {
    if (this.deviceID.length > 0 && this.deviceID.length != '') {
      await this.device.disconnect();
      printBlueLog("Disconnected from Device Blue ");
      onDisconnectListener.call();
      _DeviceConnected = false;
      bleState = FlutterBlueState.DISCONNECTED;
      if (_binge) {
        bingeConnectionListener();
        ignoreBingeConnected();
      }
      this.onDataAvailable = (data) {};
      this.onConnectListener = () {};
      this.onDisconnectListener = () {};
    }
    this.deviceID = "";
    this.deviceName = "";
    printBlueLog("Reset Successfully");
  }

  @override
  void setOnConnectListener({required Function() onConnectListener}) {
    // TODO: implement setOnConnectListener'
    this.onConnectListener = onConnectListener;
  }

  @override
  void setOnDisconnectListener({required Function() onDisconnectListener}) {
    // TODO: implement setOnDisconnectListener
    this.onDisconnectListener = onDisconnectListener;
  }

  @override
  void setOnDataAvailable(
      {required Function(List<double> data) onDataAvailable}) {
    this.onDataAvailable = onDataAvailable;
  }

  _saveDevice(BluetoothDevice device) async {

    _sharedPreferences.setString(BLEConstants.bluetoothSharedPreferenceString, device.id.id);

    printBlueLog("Shared Preference to ${device.name} set Successfully. "
        "This device will be auto connected while scanning");
  }

  void autoConnect() {

    int res =
    this.availableDevices.indexWhere((ble) => ble.id.id == this._sharedPreferences.get(BLEConstants.bluetoothSharedPreferenceString));
    if(res!=-1)
    connectDevice(
        device: this.availableDevices[res],
        onSuccess: (device)=>printBlueLog("Auto Connected ${device.name}"),
        onFailure: (device)=>printBlueLog("Failed Auto Connection ${device.name}"),
        onConnecting: (device)=>printBlueLog("Auto Connecting ${device.name}"),
        onDisconnecting: (device)=>printBlueLog("Auto DisConnecting ${device.name}"));
  }


}


double RT_Stress_Score(double val, int i) //here we are taking two inputs one is the samples value and other is the sample index.
{
  f_bp_n = val; //assigning the new sample received to first buffer
  if (k < 50) {
    k = k + 1;
    ppg_diff.add(0);
  } else {
    ppg_diff.add(f_bp_n - f_bp_n26); //differential filtering
  }

  if (ppg_diff[i] > //checking for positive clipping in the signal
      3000) {
    ppg_clip.add(3000);
  } else if (ppg_diff[i] < -3000) {
    //checking for negative clipping
    ppg_clip.add(-3000);
  } else {
    ppg_clip.add(ppg_diff[i]);
  }

  ppg_sq_n.add(ppg_clip[i]); //storing the clipped and filtered sample to the temporary buffer array
  ppg_filt.add((ppg_sq_n[i] +
          ppg_sq_n1 +
          ppg_sq_n2 +
          ppg_sq_n3 +
          ppg_sq_n4 + //averaging/integrating the recent and previous 9 samples .
          ppg_sq_n5 +
          ppg_sq_n6 +
          ppg_sq_n7 +
          ppg_sq_n8 +
          ppg_sq_n9) /
      10);
  ppg_filt1.add(np.pow(ppg_filt[i], 2).toDouble()); //squaring the signal to convert it from bipolar to unipolar

  ppg_mean = ppg_prev_mean + (ppg_filt1[i] - ppg_prev_mean) / (i + 1); //computing the running mean of the data
  ppg_sd_temp = ppg_sd_temp_prev + ((ppg_filt1[i] - ppg_prev_mean) * (ppg_filt1[i] - ppg_mean)); //computing the running std deviation of the data
  ppg_sd_temp_prev = ppg_sd_temp;
  ppg_sd = sqrt(ppg_sd_temp / (i + 1));
  thresh_sig.add(ppg_mean + ppg_sd);
  ppg_prev_mean = ppg_mean;

  if ((ppg_filt1[i] > thresh_sig[i])) {
    //looking out for peaks by detecting the signal value with the threshold
    double R_pk_time_temp = i.toDouble(); //if the crossing is detected the sample index is store
    if ((R_pk_time_temp - R_pk_time_prev) >= 79) {
      //post detecting the crossing ,we need to make sure that the next peak detected is atleast 0.3 sec post the previous peak , to avoid inaccuracy in heart rate detection
      R_pk_time.add(i.toDouble()); //this array will  be storing index of the peaks detected in the ppg signal.
      j = j + 1; //j will be storing the number of peaks detected.

      if (j > 1) {
        interpolated_signal.addAll(hrv_detection(R_pk_time, fs, j)); //interpolated_signal array will be storing the interpolated HRV curve coordinate values
        RT_stress_score = LF_HF_Computation(interpolated_signal.getRangeArray(j * 70, 70 * (j + 1))); //real time stress score calculation
      }
      R_pk_time_prev = R_pk_time_temp;
    }
  }

  //below is a cycle of updating the buffer values
  ppg_sq_n9 = ppg_sq_n8;
  ppg_sq_n8 = ppg_sq_n7;
  ppg_sq_n7 = ppg_sq_n6;
  ppg_sq_n6 = ppg_sq_n5;
  ppg_sq_n5 = ppg_sq_n4;
  ppg_sq_n4 = ppg_sq_n3;
  ppg_sq_n3 = ppg_sq_n2;
  ppg_sq_n2 = ppg_sq_n1;
  ppg_sq_n1 = ppg_sq_n[i];
  f_bp_n26 = f_bp_n25;
  f_bp_n25 = f_bp_n24;
  f_bp_n24 = f_bp_n23;
  f_bp_n23 = f_bp_n22;
  f_bp_n22 = f_bp_n21;
  f_bp_n21 = f_bp_n20;
  f_bp_n20 = f_bp_n19;
  f_bp_n19 = f_bp_n18;
  f_bp_n18 = f_bp_n17;
  f_bp_n17 = f_bp_n16;
  f_bp_n16 = f_bp_n15;
  f_bp_n15 = f_bp_n14;
  f_bp_n14 = f_bp_n13;
  f_bp_n13 = f_bp_n12;
  f_bp_n12 = f_bp_n11;
  f_bp_n11 = f_bp_n10;
  f_bp_n10 = f_bp_n9;
  f_bp_n9 = f_bp_n8;
  f_bp_n8 = f_bp_n7;
  f_bp_n7 = f_bp_n6;
  f_bp_n6 = f_bp_n5;
  f_bp_n5 = f_bp_n4;
  f_bp_n4 = f_bp_n3;
  f_bp_n3 = f_bp_n2;
  f_bp_n2 = f_bp_n1;
  f_bp_n1 = f_bp_n;

  return RT_stress_score;
}