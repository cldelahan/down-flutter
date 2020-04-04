import 'package:flutter/material.dart';

const color1 = const Color(0xff26c586);

class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                down('run', 'conner', '12:12 a' ),
                down4('run', 'assets/person1.jpg'),
                down4('run', 'assets/person1.jpg'),
                down4('run', 'assets/person1.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


Widget down(String downName, String creatorName, String time, ) {
  return Card(
    elevation: 4.0,
    child: Container(
      decoration: BoxDecoration(
        // lighter gradient effect
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color1,
          ],
        ),
      ),
      // TODO: add child
    ),
  );
}

Widget down2(String name, image) {
  return Padding(
    padding: const EdgeInsets.only(right: 17),
    child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color1, width: 2),
          ),
          child: ClipOval(
              child: Image.asset(
                image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )),
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        )
      ],
    ),
  );
}

Widget down3(String name, image) {
  return Padding(
    padding: const EdgeInsets.only(right: 17),
    child: Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        )
      ],
    ),
  );
}

Widget down4(String name, image) {
  return Padding(
    padding: const EdgeInsets.only(right: 17),
    child: Card(
      child: Column(
        children: <Widget>[
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          )
        ],
      ),
    ),
  );
}