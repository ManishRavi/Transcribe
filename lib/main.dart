import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transcribe',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final key = GlobalKey<ScaffoldState>();
  VoidCallback sheet;
  SpeechRecognition speech;
  bool isAvail = false;
  bool isLis = false;
  String res = "";
  bool close = false;
  ScrollController scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    sheet = sheet;
    init();
  }

  void init() async {
    await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    speech = SpeechRecognition();
    speech.setAvailabilityHandler(
      (bool r) => setState(() => isAvail = r),
    );
    speech.setRecognitionStartedHandler(
      () => setState(() => isLis = true),
    );
    speech.setRecognitionResultHandler((String s) {
      setState(() => res = s);
      scroll.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 100),
      );
    });
    speech.setRecognitionCompleteHandler(
      () => setState(() => isLis = false),
    );
    speech.setErrorHandler(() {
      isLis = false;
      init();
    });
    speech.activate().then(
          (r) => setState(() => isAvail = r),
        );
  }

  void _showSheet() {
    setState(() {
      sheet = null;
    });

    key.currentState
        .showBottomSheet((context) {
          return Container(
            height: MediaQuery.of(context).size.height * .7,
            child: Scaffold(
              body: Container(
                  color: Colors.black12,
                  height: MediaQuery.of(context).size.height * 1,
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(fontSize: 35),
                  )),
            ),
          );
        })
        .closed
        .whenComplete(() {
          close = false;
          if (mounted) {
            setState(() {
              sheet = sheet;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF625DD1),
        child: !close
            ? Icon(
                Icons.keyboard,
                color: Colors.white,
                size: 30,
              )
            : Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
        onPressed: () {
          if (!close) {
            _showSheet();
            close = true;
          } else {
            Navigator.pop(context);
            close = false;
          }
        },
      ),
      appBar: AppBar(
        title: Text("Transcribe"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * .96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .75,
              padding: EdgeInsets.all(5),
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                controller: scroll,
                children: <Widget>[
                  Text(
                    res,
                    style: TextStyle(fontSize: 35),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                backgroundColor: Color(0xFFB15B60),
                child: !isLis
                    ? Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 30,
                      )
                    : SpinKitWave(
                        color: Colors.white,
                        size: 23,
                        type: SpinKitWaveType.center,
                      ),
                onPressed: () {
                  if (isAvail && !isLis) {
                    speech.listen(locale: "en_US");
                    isLis = true;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
