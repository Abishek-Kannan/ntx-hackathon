
class BluetoothNotConnectedException implements Exception{
  final String message;

  BluetoothNotConnectedException(this.message);

  @override
  String toString() {
    return 'Bluetooth Not Connected Exception ${message}';
  }
}