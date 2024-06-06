import 'dart:convert' show base64;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'MapsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyRCControlPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyRCControlPage extends StatefulWidget {
  @override
  _MyRCControlPageState createState() => _MyRCControlPageState();
}

class _MyRCControlPageState extends State<MyRCControlPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  final DatabaseReference _lampRef =
      FirebaseDatabase.instance.reference().child('control/lampu');
  final DatabaseReference _klaksonRef =
      FirebaseDatabase.instance.reference().child('control/klakson');
  final DatabaseReference _kameraRef =
      FirebaseDatabase.instance.reference().child('kamera/mobil');
  CameraController? _cameraController;
  bool _isHonking = false;
  bool CameraOn = false;
  String enkode_base64 = '';
 

  void _movingDatabase(String controlType, int data) {
    _databaseReference.child('control').child(controlType).set(data);
  }

  void _toggleLamp(bool isTurnedOn) {
    _lampRef.set(isTurnedOn ? 1 : 0);
  }

  void _toggleHonkHorn() {
    setState(() {
      _isHonking = !_isHonking;
    });
    if (_isHonking) {
      _klaksonRef.set(1);
    } else {
      _klaksonRef.set(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _kameraRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      var gambar_base64 = snapshot.value.toString();
      if (gambar_base64.isNotEmpty) {
        setState(() {
          enkode_base64 = gambar_base64;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RC Car Controller'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
                icon: Icon(Icons.videocam,
                color: Colors.green,),
                onPressed: () {
                  setState(() {
                    CameraOn = !CameraOn;
                    print('Kamera : ${CameraOn? "Nyala" : "Mati"}');
                  });
                },
              ),
              SizedBox(width: 30.0),
          IconButton(
            icon: Icon(
              Icons.map,
              color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationScreen()), 
              );
            },
          ),
          SizedBox(width: 10.0),
        ],
      ),

      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 420,
            child: AnimatedOpacity(
              opacity: CameraOn ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: enkode_base64.isNotEmpty
                  ? Container(
                      width: 250.0,
                      height: 250.0,
                      child: Image.memory(
                        base64.decode(enkode_base64),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Container(
                      child: Icon(
                        Icons.photo,
                        size: 60.0,
                      ),
                    ),
                ),
              ),
          Positioned(
            bottom: 90.0,
            right: 30.0,
            child: LongPressButton(
              onPressed: () {
                _movingDatabase('motor belakang', 1);
                print('MAJU');
              },
              onLongPressUp: () {
                _movingDatabase('motor belakang', 0);
                print('STOP');
              },
              backgroundColor: Colors.black45,
              arrowIcon: Icons.arrow_drop_up_outlined,
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 30.0,
            child: LongPressButton(
              onPressed: () {
                _movingDatabase('motor belakang', -1);
                print('MUNDUR');
              },
              onLongPressUp: () {
                _movingDatabase('motor belakang', 0);
                print('STOP');
              },
              backgroundColor: Colors.black45,
              arrowIcon: Icons.arrow_drop_down_outlined,
            ),
          ),
          Positioned(
            bottom: 50.0,
            left: 110.0,
            child: LongPressButton(
              onPressed: () {
                _movingDatabase('motor depan', 1);
                print('KANAN');
              },
              onLongPressUp: () {
                _movingDatabase('motor depan', 0);
                print('STOP');
              },
              backgroundColor: Colors.black45,
              arrowIcon: Icons.arrow_right_outlined,
            ),
          ),
          Positioned(
            bottom: 50.0,
            left: 30.0,
            child: LongPressButton(
              onPressed: () {
                _movingDatabase('motor depan', -1);
                print('KIRI ');
              },
              onLongPressUp: () {
                _movingDatabase('motor depan', 0);
                print('STOP');
              },
              backgroundColor: Colors.black45,
              arrowIcon: Icons.arrow_left_outlined,
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 280.0,
            right: 250.0,
            child: StreamBuilder(
              stream: _lampRef.onValue,
              builder: (context, snapshot) {
                bool isLampOn = (snapshot.data?.snapshot.value == 1);
                return ElevatedButton(
                  onPressed: () {
                    _toggleLamp(!isLampOn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: StadiumBorder(),
                    fixedSize: Size(80, 30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 15,
                        color: isLampOn? Colors.yellow : Colors.grey,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(isLampOn ? 'Lampu ON' : 'Lampu OFF'),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 40.0,
            left: 280.0,
            right: 250.0,
            child: ElevatedButton(
              onPressed: _toggleHonkHorn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: StadiumBorder(),
                fixedSize: Size(80, 30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up,
                    size: 15,
                    color: _isHonking ? Colors.red : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isHonking ? 'Klakson ON' : 'Klakson OFF',
                    style: TextStyle(
                    color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

class LongPressButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressUp;
  final Color? backgroundColor;
  final IconData arrowIcon;

  const LongPressButton({
    Key? key,
    this.onPressed,
    this.onLongPressUp,
    this.backgroundColor,
    required this.arrowIcon,
  }) : super(key: key);

  @override
  _LongPressButtonState createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        if (widget.onLongPressUp != null) widget.onLongPressUp!();
      },
      child: Container(
        width: 70.0,
        height: 70.0,
        decoration: BoxDecoration(
          color: isPressed ? widget.backgroundColor : Colors.black,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            widget.arrowIcon,
            size: 40.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

