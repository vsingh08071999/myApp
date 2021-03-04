import 'dart:async';
import 'dart:ffi';

import 'package:newapplication/bloc/AuthBloc.dart';
import 'package:newapplication/constants/constant_colors.dart';
import 'package:newapplication/constants/beizerContainer.dart';
import 'package:newapplication/models/userModel.dart';
//import 'package:MyDen/resources/firebase_repository.dart';
//import 'package:MyDen/screens/tabScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapplication/screens/homeScreen.dart';

//import 'ActivationScreen.dart';

class EmailVerification extends StatefulWidget {
  final name;

  const EmailVerification({Key key, this.name}) : super(key: key);

  @override
  _emailVerificationState createState() => _emailVerificationState();
}

class _emailVerificationState extends State<EmailVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  bool _isUserEmailVerified;
  bool isLoading = false;
  final interval = const Duration(seconds: 1);

  final int timerMaxSeconds = 20;

  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  UserData _userData = UserData();

  @override
  void initState() {
    _userData = context.bloc<AuthBloc>().getCurrentUser();
    startTimeout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                CustomPaint(
                  child: Container(
                    height: 300.0,
                  ),
                  painter: CurvePainter(),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // color: UniversalVariables.background,
                          Padding(
                            padding: EdgeInsets.all(9),
                            child: Text(
                              "Email verification link has been send to your mail,  please click on the link to verify  ",
                              style: TextStyle(
                                  color: UniversalVariables.ScaffoldColor,
                                  fontWeight: FontWeight.w800,
                                  wordSpacing: 5),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              timerText == "00: 00"
                                  ? GestureDetector(
                                      onTap: () {
                                        context
                                            .bloc<AuthBloc>()
                                            .resendEmailVerification();
                                        showScaffold(
                                            "Link is send to your EmailId");
                                      },
                                      child: Text(" Resend link",
                                          style: TextStyle(
                                            color: UniversalVariables
                                                .ScaffoldColor,
                                            fontWeight: FontWeight.w800,
                                          )),
                                    )
                                  : Text(timerText,
                                      style: TextStyle(
                                        color: Colors.red[500],
                                        fontWeight: FontWeight.w800,
                                      )),
                            ],
                          )
                        ],
                      ),
                      RaisedButton(
                        color: UniversalVariables.background,
                        //elevation: 10,
                        onPressed: () async {
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          await user.reload();
                          print(user.email);
                          print(user.isEmailVerified);
                          if (!user.isEmailVerified) {
                            showScaffold("First Verify Your email id");
                          } else {
                            showScaffold("Email id is verify");
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          }

                          //  context.bloc<AuthBloc>().checkEmailVerification(context);
                          // // checkEmilVerifiedOrNot();
                        },
                        child: Text(
                          "Email Verifiedwwwww",
                          style: TextStyle(
                            color: UniversalVariables.ScaffoldColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}
