class BluetoothSpecification{
  String _battery = "100";


  String get battery => _battery;

  set battery(String value) {
    _battery = value;
  }

  BluetoothSpecification(this._battery);

  @override
  String toString() {
    return 'BluetoothSpecfication{_battery: $_battery}';
  }
}