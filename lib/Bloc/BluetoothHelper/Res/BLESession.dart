import 'dart:core';

class BLESession {
  String _packet = "";
  var lists = [];

  List<String> _listPacket = [];
  String _EEG1 = "";
  String _EEG2 = "";
  String _EEG3 = "";
  String _EEG4 = "";
  String _PPG1 = "";
  String _PPG2 = "";
  String _PPG = "";
  String _TEMP = "";
  String _BAT = "";
  String _IMP = "";

  int MAXIMUM = 10;

  BLESession(this._packet) {
    this._packet = this._packet.toString().replaceAll(RegExp("[^0-9,]"), "");
    print("Packet Receiveed ${this._packet}");
    this._listPacket = this._packet.split(",");
    if (this._listPacket.length > 0) {
      this.parseData();
    }
  }

  void parseData() {
    try {
      int diff = MAXIMUM - this._listPacket.length;
      this._listPacket.addAll(List.filled(diff, '-1'));
      _EEG1 = this._listPacket[0];
      _EEG2 = this._listPacket[1];
      _EEG3 = this._listPacket[2];
      _EEG4 = this._listPacket[3];
      _PPG1 = this._listPacket[4];
      _PPG2 = this._listPacket[5];
    } catch (error) {
      print("Error in Parsing Data ${error}");
    }
  }

  String get EEG1 => _EEG1;

  set EEG1(String value) {
    _EEG1 = value;
  }

  String get EEG2 => _EEG2;

  set EEG2(String value) {
    _EEG2 = value;
  }

  String get EEG3 => _EEG3;

  set EEG3(String value) {
    _EEG3 = value;
  }

  String get EEG4 => _EEG4;

  set EEG4(String value) {
    _EEG4 = value;
  }

  String get PPG1 => _PPG1;

  set PPG1(String value) {
    _PPG1 = value;
  }

  String get PPG2 => _PPG2;

  set PPG2(String value) {
    _PPG2 = value;
  }

  String getJson() {
    return '{_EEG1: $_EEG1, _EEG2: $_EEG2, _EEG3: $_EEG3, _EEG4: $_EEG4, _PPG1: $_PPG1, _PPG2: $_PPG2}';
  }

  @override
  String toString() {
    return 'BLESession{_packet: $_packet, _EEG1: $_EEG1, _EEG2: $_EEG2, _EEG3: $_EEG3, _EEG4: $_EEG4, _PPG1: $_PPG1, _PPG2: $_PPG2}';
  }
}
