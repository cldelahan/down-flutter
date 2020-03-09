import 'package:flutter/material.dart';
import './FeedPage.dart' as first;
import './DownPage1.dart' as second;
import './BurgerPage.dart' as third;

//void main() => runApp(MyApp());

const color1 = const Color(0xff26c586);

void main() {
  runApp(new MaterialApp(
      home: new MyTabs()
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new Text("Body"));
  }

}
class MyTabs extends StatefulWidget {
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {


  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Down"),
            backgroundColor: color1,

        ),
        bottomNavigationBar: new Material(
            color: color1,
            child: new TabBar(
                controller: controller,
                tabs: <Tab>[
                  new Tab(icon: new Icon(Icons.home)),
                  new Tab(icon: new Icon(Icons.arrow_downward)),
                  new Tab(icon: new Icon(Icons.group)),
                ]
            )
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new first.First(),
              new second.Second(),
              new third.Third()
            ]
        )
    );
  }
}