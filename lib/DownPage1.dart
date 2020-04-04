
import 'package:flutter/material.dart';
import './HeaderWidget.dart';
import 'Down Creation/MakeDownHome.dart' as Fourth;
import 'Down Creation/MakeDownActivity.dart' as Fifth;
import 'Down Creation/MakeDownTime.dart' as MyHomePage;

class Second extends StatefulWidget {
  @override
  _PageViewDemoState createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<Second> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children:
      <Widget>[
        Fourth.Fourth(),
        Fifth.Fifth(),
        MyHomePage.Sixth(),
        Container(
          color: Colors.pink,
        ),
        Container(
          color: Colors.cyan,
        ),
        Container(
          color: Colors.deepPurple,
        ),
      ],
      scrollDirection: Axis.vertical,
    );
  }
}