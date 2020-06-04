
import 'package:flutter/material.dart';
import '../Widgets/HeaderWidget.dart';
import '../DownCreation/MakeDownHome.dart' as Fourth;
import '../DownCreation/MakeDownActivity.dart' as Fifth;
import '../DownCreation/MakeDownTime.dart' as MyHomePage;

class CreateDown extends StatefulWidget {
  @override
  _PageViewDemoState createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<CreateDown> {
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