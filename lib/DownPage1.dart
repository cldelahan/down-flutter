import 'package:flutter/material.dart';
import './MakeDownHome.dart' as Fourth;
import './MakeDownActivity.dart' as Fifth;
import './MakeDownTime.dart' as MyHomePage;

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
        MyHomePage.MyHomePage(),
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
