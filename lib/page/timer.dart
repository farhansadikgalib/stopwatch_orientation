import 'dart:math';

import 'package:device_real_orientation/device_orientation.dart';
import 'package:device_real_orientation/device_orientation_provider.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Timers extends StatefulWidget {
  const Timers({Key? key}) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timers> {
  final StopWatchTimer _stopwatch_timer = StopWatchTimer();
  final _isHours = true;
  bool isRunning = true;
  bool IsRecoard = true;

  final _scrollController = ScrollController();
  var orientation = DeviceOrientation.portrait;

  @override
  void dispose() {
    super.dispose();
    _stopwatch_timer.dispose();
    _scrollController.dispose();
  }

  bool orientationChanged = false;

  @override
  void initState() {
    super.initState();
    DeviceOrientationProvider.orientations.listen((orientation) {
      setState(() {
        this.orientation = orientation;
        debugPrint(orientation.toString());

        if (orientation == DeviceOrientation.landscapeLeft ||
            orientation == DeviceOrientation.landscapeRight) {
          isRunning
              ? _stopwatch_timer.onExecute.add(StopWatchExecute.start)
              : _stopwatch_timer.onExecute.add(StopWatchExecute.stop);
          setState(() {
            isRunning = !isRunning;
            IsRecoard = !IsRecoard;
            orientationChanged = true;
          });
        } else if ((orientation == DeviceOrientation.portrait ||
                orientation == DeviceOrientation.upsideDown) &&
            orientationChanged) {
          setState(() {
            _stopwatch_timer.onExecute.add(StopWatchExecute.start);
            orientationChanged = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xffE3EDF7),
      body: SizedBox(
        width: we,
        height: he,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: he * 0.10),
              Container(
                  width: 320,
                  height: 320,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0xffE3EDF7),
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xffecf6ff), Color(0xffcadbeb)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 32,
                          spreadRadius: 1,
                          offset: const Offset(30, 20),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 32,
                          spreadRadius: 1,
                          offset: Offset(-20, -10),
                        ),
                      ]),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      StreamBuilder<int>(
                          stream: _stopwatch_timer.rawTime,
                          initialData: _stopwatch_timer.rawTime.value,
                          builder: (context, snapshot) {
                            final value = snapshot.data;
                            final dilspalyTime = StopWatchTimer.getDisplayTime(
                                value!,
                                hours: _isHours);
                            return (Text(
                              dilspalyTime,
                              style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black.withOpacity(0.7),
                                  fontWeight: FontWeight.bold),
                            ));
                          }),
                      CustomPaint(
                        painter: ClockTimer(),
                      )
                    ],
                  )),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buttonStart(context, "Start", Colors.black.withOpacity(0.7)),
                  const SizedBox(
                    width: 50,
                  ),
                  InkWell(
                      onTap: () {
                        IsRecoard
                            ? _stopwatch_timer.onExecute
                                .add(StopWatchExecute.reset)
                            : _stopwatch_timer.onExecute
                                .add(StopWatchExecute.lap);
                      },
                      child: _buttonStop(context, "Reset", Colors.red))
                ],
              ),
              Container(
                width: we * 0.9,
                height: he * 0.2,
                margin: const EdgeInsets.only(top: 10),
                child: StreamBuilder<List<StopWatchRecord>>(
                  stream: _stopwatch_timer.records,
                  initialData: _stopwatch_timer.records.value,
                  builder: (context, snapshot) {
                    final value = snapshot.data;
                    if (value!.isEmpty) {
                      return Container();
                    }
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut);
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (c, i) {
                        final data = value[i];
                        return _buildCard(
                            context, "${i + 1}", "${data.displayTime}");
                      },
                      itemCount: value.length,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// TODO : timer info ...
  Widget _buildCard(context, String index, String text) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Container(
      width: we * 0.8,
      height: he * 0.07,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFDDEAF8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: we * 0.01,
          ),
          const Text(
            "Lap",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            width: we * 0.43,
          ),
          Text(text,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buttonStart(
    context,
    String text,
    Color color,
  ) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        isRunning
            ? _stopwatch_timer.onExecute.add(StopWatchExecute.start)
            : _stopwatch_timer.onExecute.add(StopWatchExecute.stop);
        setState(() {
          isRunning = !isRunning;
          IsRecoard = !IsRecoard;
        });
      },
      child: Container(
        width: 150,
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffE3EDF7),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[500]!,
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(4, 4),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(-4, -4),
              ),
            ]),
        child: Text(
          isRunning ? text : "Pause",
          style: TextStyle(
              color: color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buttonStop(
    context,
    String text,
    Color color,
  ) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return Container(
      width: 150,
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffE3EDF7),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500]!,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(4, 4),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(-4, -4),
            ),
          ]),
      child: Text(
        IsRecoard ? text : "Recoard",
        style:
            TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ClockTimer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var centerx = size.width / 2;
    var centery = size.height / 2;
    var center = Offset(centerx, centery);
    var radius = min(centerx, centery);
    var outerRadius = radius - 47;
    var innerRadius = radius - 50;

    var hourDashPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 3) {
      double x1 = centerx - outerRadius * 3 * cos(i * pi / 180);
      double y1 = centerx - outerRadius * 3 * sin(i * pi / 180);
      double x2 = centerx - innerRadius * 3 * cos(i * pi / 180);
      double y2 = centerx - innerRadius * 3 * sin(i * pi / 180);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), hourDashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
