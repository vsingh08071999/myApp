import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newapplication/screens/homeScreen.dart';
import 'package:newapplication/constants/global.dart' as global;
import 'package:newapplication/bloc/authBloc.dart';
import 'package:newapplication/constants/beizerContainer.dart';
import 'package:newapplication/constants/constant_colors.dart';
import 'package:newapplication/models/userModel.dart';

import 'emailVerificationScreen.dart';
import 'loginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<UserData> _getUserData() async {
    print("getUserData -----------------");
//    BlocBuilder<AuthBloc,AuthBlocState>(builder: (context,state){
//      return state.currentUser();
//    },);

    return await context.bloc<AuthBloc>().currentUser();
  }

//  Future<UserData> currentUser() async {
//    print("current user");
//    var user = await FirebaseAuth.instance.currentUser();
//    return await context.bloc<AuthBloc>().userFromFirebase(user);
//  }
  @override
  void initState() {
//    _getUserData().then((fUser) {
//      if (fUser != null) {
//        if (!fUser.emailVerified) {
//          Navigator.pushReplacement(context,
//              MaterialPageRoute(builder: (context) => EmailVerification()));
//        } else {
//          Navigator.pushReplacement(
//              context, MaterialPageRoute(builder: (context) => HomeScreen()));
//        }
//      } else {
//        print('Login Page');
//        Navigator.pushReplacement(
//            context, MaterialPageRoute(builder: (context) => LoginPage()));
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
//                        CircularProgressIndicator(),
                        RaisedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          },
                          child: Text("next screen"),
                        ),
                        Text(
                          "MY Den",
                          style: TextStyle(
                              fontSize: 35,
                              color: UniversalVariables.background,
                              fontWeight: FontWeight.w800),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}
