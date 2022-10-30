// void autoConnect() async {
//   printBlueLog("AutoConnecting");
//
//   this
//       .flutterReactiveBle
//       .scan(
//           withServices: [Guid(this._deviceServiceID)],
//           scanMode: ScanMode.lowLatency,
//           timeout: Duration(seconds: BLEConstants.scanDuration))
//       .listen((event) {})
//       .onDone(() {
//         printBlueLog("Finished Scanning");
//       });
//
//   this.flutterReactiveBle.scanResults.listen((devices) {
//     // filters only devices which has names
//     availableDevices = devices
//         .where((element) => element.device.name.length != 0)
//         .toList()
//         .map((device) => device.device)
//         .toList();
//     int paired = this.findPairedDeviceIfAny(availableDevices);
//     printBlueLog("Devices Available : Paired : ${paired} ${devices} ");
//     if (paired != -1) {
//       this._pairedDevice = this.availableDevices.firstWhere(
//           (element) => element.id.id.toString() == this._pairedDeviceId);
//       this.connectDevice(
//           device: this._pairedDevice,
//           onSuccess: (ble) => printBlueLog("Auto Connected to Device ${device}"),
//           onFailure: (ble) =>
//               printBlueLog("Auto Failed Connecting to Device ${device}"),
//           onConnecting: (ble) => printBlueLog(" Connecting to Device ${device}"),
//           onDisconnecting: (ble) =>
//               printBlueLog("DisConnecting from Device ${device}"));
//     }
//   }).onError((error) => {printBlueLog("Error Auto Connecting...")});
// }
