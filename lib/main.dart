import 'dart:async';
import 'dart:math';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:ntx/Bloc/BluetoothHelper/BlueToothHelper.dart';
import 'package:ntx/Bloc/PermissionHandler.dart';
import 'Bloc/Printer.dart';
import 'dart:math' as math;

List<String> photos = [
"https://ntx1.s3.amazonaws.com/ntx4.png",
"https://ntx1.s3.amazonaws.com/ntx3.png",
"https://ntx1.s3.amazonaws.com/ntx2.png",
"https://ntx1.s3.amazonaws.com/ntx1.png",
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const HomeScreen();

  @override
  State<HomeScreen> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothHelper bluetoothHelper =  BluetoothHelper();

  @override
  void initState() {
   PermissionHandler.seekPermissions().then((value) => {
     printer("Permission granted"),
     ListBLEDevices(),
   }).catchError((onError)=>{
     printer("Permission Denied")
   });
   super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Game')),
      body: Center(
        child: ElevatedButton(
          child: const Text(
            'Start',
            style: TextStyle(fontSize: 24.0),
          ),
          onPressed: () {
            _navigateToNextScreen(context);
          },
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage(photos)),);
  }

  ListBLEDevices(){
    this.bluetoothHelper.onDisconnectListener = ()=>{
    ListBLEDevices()
    };
   
    this.bluetoothHelper.ensureBingeConnected(
        onDisconnected: ()=>{
          ListBLEDevices()
        },
        
        onDataAvailable: (data)=>{
        });
    
    this.bluetoothHelper.onConnectListener = ()=>{
      Navigator.of(context).pop()
    };

   if(!this.bluetoothHelper.isDeviceConnected) {
     this.bluetoothHelper.listDevices((availableDevices) => {}, (p0) => {});
     showDialog(
         context: (context),
         barrierDismissible: false,
         builder: (context){
       return AlertDialog(
         title: const Text("Bluetooth :"),
         content: StreamBuilder<bool>(
           initialData: false,
           stream: this.bluetoothHelper.flutterReactiveBle.isScanning,
           builder: (context,snapShot){

             if(!snapShot.hasData){
               return CircularProgressIndicator.adaptive();
             }
             final state = snapShot.data;
             printer(state);

             if(state == true){
               return StreamBuilder<List>(
                   initialData: [],
                   stream: Stream.periodic(Duration(milliseconds: 500)).asyncMap((event) => this.bluetoothHelper.availableDevices),
                   builder: (context,snapShot){
                     final state = this.bluetoothHelper.bleState;
                     if(this.bluetoothHelper.availableDevices.length>0){
                       return IntrinsicHeight(
                         child: Column(
                           children: List.generate(
                               this.bluetoothHelper.availableDevices.length,
                                   (index) => BluetoothListViewItem(index)
                           ),
                         ),
                       );
                     }
                     return CircularProgressIndicator.adaptive();
                   }
               );
             }

             return StreamBuilder<FlutterBlueState>(
                 initialData: FlutterBlueState.SCANNING,
                 stream: Stream.periodic(Duration(milliseconds: 500)).asyncMap((event) => this.bluetoothHelper.bleState),
                 builder: (context,snapShot){
                   final state = this.bluetoothHelper.bleState;

                   if(state == FlutterBlueState.CONNECTING){
                     return IntrinsicHeight(
                       child: Column(
                         children: [
                           const Text("Connecting Device"),
                         ],
                       ),
                     );
                   }

                   if(state == FlutterBlueState.CONNECTED){
                    this.bluetoothHelper.writeToCharacteristic("1");
                    var timer= Timer.periodic(Duration(seconds: 10), (timer) {
                       Navigator.of(context).pop();
                       timer.cancel();
                    });

                     return Container(
                       child: IntrinsicHeight(
                         child: Column(
                           children: [
                             Icon(
                               Icons.check_circle,
                               color: Colors.green,
                             ),
                             Text("Connected to ${this.bluetoothHelper.device.name}")
                           ],
                         ),
                       ),
                     );
                   }


                   if(this.bluetoothHelper.availableDevices.length>0){
                     return IntrinsicHeight(
                       child: Column(
                         children: [
                           ...List.generate(
                               this.bluetoothHelper.availableDevices.length,
                                   (index) => BluetoothListViewItem(index)
                           ),
                           Padding(
                             padding: EdgeInsets.all(8.0),
                             child: TextButton(
                               onPressed: (){
                                 this.bluetoothHelper.listDevices((availableDevices) =>
                                 {}, (p0) => {});
                               },
                               child: const Text("Retry"),
                             ),
                           )
                         ],
                       ),
                     );
                   }
                   return Container(
                     child: Padding(
                       padding: EdgeInsets.all(8.0),
                       child: IntrinsicHeight(
                         child: Column(
                           children: [
                             const Text("No Devices Found"),
                             TextButton(
                               onPressed: (){
                                 this.bluetoothHelper.listDevices((availableDevices) =>
                                 {}, (p0) => {});
                               },
                               child: const Text("Retry"),
                             )
                           ],
                         ),
                       ),
                     ),
                   );
                 }
             );

           },
         ),
      );
     });
   }

  }

  Widget BluetoothListViewItem(int index){
   return GestureDetector(
     onTap: (){
       printer("Connection ${this.bluetoothHelper.availableDevices[index]}");
       this.bluetoothHelper.connectDevice(
           device: this.bluetoothHelper.availableDevices[index],
           onSuccess: (device) => {
             printer("${device.name} Connected"),

             Navigator.of(context).pop()
           },
           onFailure: (device) => {},
           onConnecting: (device)=>{},
           onDisconnecting: (device)=>{});
     },
     child: Padding(
       padding: EdgeInsets.all(6.0),
       child: Text(this.bluetoothHelper.availableDevices[index].name),
     ),
   );
  }

}

class MyHomePage extends StatefulWidget {
  List<String> photos;
  MyHomePage(this.photos);

  @override
  State<MyHomePage> createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 int _pos = 0;
 late Timer _timer;
 bool _loading = false;
 int offset = 0;
 int time = 800;
 BluetoothHelper bluetoothHelper =  BluetoothHelper();
 List imagesList = [];
 getImages() {
    setState(() {
      _loading = true;
    });
    Timer(Duration(seconds: 5), () => {
      imagesList.add(photos[0]),
      setState(() {
        _loading = false;
      })
    });
  }

 @override
  void initState() {

    getImages();
    this.bluetoothHelper.writeToCharacteristic("1");
    _timer = Timer.periodic(Duration(seconds: math.Random().nextInt(10) + 5), (Timer t) {
      setState(() {
        _pos = (_pos + 1) % widget.photos.length;
        if(_pos == 0){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ResultsScreen()),);
        }
        
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)?
        Container(
          color: Colors.white,
          child: SafeArea(
            child: ListView.builder(
              padding: EdgeInsets.all(5),
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                offset += 5;
                time = 800 + offset;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Shimmer.fromColors(
                    highlightColor: Colors.white,
                    baseColor: Colors.grey,
                    child: Container(
                      margin: EdgeInsets.only(right : 0),
                      height: 865,
                      width: 270,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    period: Duration(seconds: 5),
                  )
                );
              },
            ),
          )
        ):
         Image.network(
                    widget.photos[_pos],
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
           );
    
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
   
  readData(data) {
    List<String> currentData = data;

        // if the last value is not empty, then it means that the last value is not complete
        // so we need to keep it in the buffer
        // and remove it from the currentData
        if (currentData.last.isNotEmpty) {
          data = currentData.last;
          currentData.removeLast();
        } else {
          data = "";
        }
        currentData = currentData.where((element) => element.isNotEmpty).toList();
        //print(currentData);
  }
}

class ResultsScreen extends StatelessWidget{
  const ResultsScreen({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: ElevatedButton(
          child: const Text(
            'Restart Game',
            style: TextStyle(fontSize: 24.0),
          ),
          onPressed: () {
            _navigateToNextScreen(context);
          },
        ),
      ),
    );
  }
  void _navigateToNextScreen(BuildContext context) {
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen()),);
  }
}