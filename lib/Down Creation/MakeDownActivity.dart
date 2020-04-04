import 'package:flutter/material.dart';

const color1 = const Color(0xff26c586);

class Fifth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      body: Stack(
        children: <Widget>[
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            //CircleAvatar(
                              //backgroundImage: AssetImage('assets/user.png'),
                            //),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.search, color: Colors.white, size: 27),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Recommendations',
                              style: TextStyle(color: Colors.white, fontSize: 27),
                            )
                          ],
                        ),
                        //Icon(Icons.add_circle_outline, color: Colors.white, size: 31)
                      ],
                    ),
                  ),
                  Container(
                    //height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 12, left: 21),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Friends',
                            style: TextStyle(
                                color: Colors.black.withOpacity(.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        SizedBox(
                          height: 3,
                        ),
                        Container(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              story('Hossin', 'assets/user.png'),
                              story('Mary', 'assets/person1.jpg'),
                              story('Nat', 'assets/person2.jpg'),
                              story('Stella', 'assets/person3.jpg'),
                              story('Yassine', 'assets/person1.jpg'),
                              story('Hossin', 'assets/user.png'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 21),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.2),offset: Offset(3, 19),blurRadius: 12,spreadRadius: 2)
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget story(String name, image) {
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
