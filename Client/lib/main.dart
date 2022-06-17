import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

Future<int> predict() async {
  String url = 'http://192.168.105.126:5000/getPredict';
  dynamic response = await http.get(Uri.parse(url));
  dynamic responseData = json.decode(response.body);
  return responseData["value"];
}

void updateValue() async {
  predicted = await predict();
}

int pointColor = 0xFFF;
bool flag = true;
late Timer timer;
int predicted = 0;
List<int> previousData = [];
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

@override
void initState() async {
  predicted = await predict();
  initState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Indoor Localization"),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Center(
                child: Container(
                  color: Color.fromARGB(255, 248, 248, 248),
                  width: 450,
                  height: 950,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return CustomPaint(
                        painter: MyPainter(),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                child: Icon(Icons.start),
                label: 'Start',
                onTap: () {
                  flag = false;
                  timer = Timer.periodic(Duration(seconds: 5), (timer) {
                    setState(() {
                      updateValue();
                      pointColor = 0xFF0F07FF;
                      print(predicted);
                      previousData.add(predicted);
                    });
                  });
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.replay),
                label: 'Replay',
                onTap: () async {
                  flag = true;
                  timer.cancel();
                  print(previousData.length);
                  if (previousData.length >= 50) {
                    int i = previousData.length - 50;
                    while (i < previousData.length && flag) {
                      print("i=====");
                      await Future.delayed(const Duration(seconds: 2), () {
                        print(i);
                        setState(() {
                          pointColor = 0xFFE6FF07;
                          predicted = previousData[i];
                          print("predicted = " + predicted.toString());
                        });
                      });
                      i++;
                    }
                  }
                },
              )
            ],
          ),
        ));
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()..strokeWidth = 1;

    // vertical lines
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), linePaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), linePaint);

    canvas.drawLine(Offset(180, 0), Offset(180, 180), linePaint);
    canvas.drawLine(Offset(180, 300), Offset(180, size.height), linePaint);
    canvas.drawLine(Offset(160, 500), Offset(160, 550), linePaint);
    canvas.drawLine(
        Offset(size.width - 180, 0), Offset(size.width - 180, 180), linePaint);
    canvas.drawLine(Offset(size.width - 180, 300),
        Offset(size.width - 180, size.height), linePaint);
    canvas.drawLine(Offset(80, 450), Offset(80, 550), linePaint);

    // horizontal lines
    canvas.drawLine(Offset(0, 180), Offset(180, 180), linePaint);
    canvas.drawLine(Offset(0, 300), Offset(180, 300), linePaint);
    canvas.drawLine(Offset(0, 400), Offset(180, 400), linePaint);
    canvas.drawLine(Offset(0, 450), Offset(180, 450), linePaint);
    canvas.drawLine(Offset(160, 500), Offset(180, 500), linePaint);
    canvas.drawLine(Offset(0, 550), Offset(180, 550), linePaint);
    canvas.drawLine(
        Offset(size.width - 180, 150), Offset(size.width, 150), linePaint);
    canvas.drawLine(
        Offset(size.width - 180, 180), Offset(size.width, 180), linePaint);
    canvas.drawLine(
        Offset(size.width - 180, 300), Offset(size.width, 300), linePaint);
    canvas.drawLine(Offset(80, 480), Offset(180, 480), linePaint);

    // Circles
    Paint circlePaint = Paint()..color = Color(pointColor);
    switch (predicted) {
      case 0:
        {
          canvas.drawCircle(Offset(90, 425), 5, circlePaint);
          break;
        }

      case 1:
        {
          canvas.drawCircle(Offset(140, 500), 5, circlePaint);
          break;
        }

      case 2:
        {
          canvas.drawCircle(Offset(size.width - 90, 165), 5, circlePaint);
          break;
        }

      case 4:
        {
          canvas.drawCircle(Offset(size.width / 2, 310), 5, circlePaint);
          break;
        }

      case 5:
        {
          canvas.drawCircle(Offset(size.width / 2, 70), 5, circlePaint);
          break;
        }

      case 6:
        {
          canvas.drawCircle(Offset(size.width / 2, 530), 5, circlePaint);
          break;
        }

      default:
        {
          break;
        }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
