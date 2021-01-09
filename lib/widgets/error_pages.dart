import 'package:flutter/material.dart';

Widget loadingPage(BuildContext context) {
  return Scaffold(
    body: Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

Widget noCopyrightPage(BuildContext context) {
  return Scaffold(
    body: Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/pika.png'),
              backgroundColor: Colors.transparent,
              radius: 56,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '漫画走丢了\n   去别的地方\n找找吧',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[100]),
            ),
            SizedBox(
              height: 8,
            ),
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    ),
  );
}

Widget failPage(BuildContext context, Function refresh) {
  return Scaffold(
    body: Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/33.gif',
              width: 200,
            ),
            Text(
              '没有wifi !!!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor),
            ),
            IconButton(icon: Icon(Icons.refresh_rounded), onPressed: refresh),
          ],
        ),
      ),
    ),
  );
}
