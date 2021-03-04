import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:newapplication/constants/global.dart' as global;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newapplication/bloc/authBloc.dart';
import 'package:newapplication/constants/beizerContainer.dart';
import 'package:newapplication/constants/constantTextField.dart';
import 'package:newapplication/constants/constant_colors.dart';
import 'package:newapplication/models/userModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapplication/screens/homeScreen.dart';
import 'package:newapplication/logins/signUp_page.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserData _userData = UserData();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  final formkeyForget = GlobalKey<FormState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoginPressed = false;
  bool _passwordVisible = true;
  bool isLoading = false;

  @override
  Future<void> resetPassword(String email) async {
    _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
      showScaffold("Change Password link is send to your mail");
    }).catchError((error) {
      switch (error.code) {
        case "ERROR_USER_NOT_FOUND":
        case "ERROR_INVALID_EMAIL":
          {
            this.showScaffold("This email Id is not exist ");
            setState(() {
              isLoading = false;
            });
            break;
          }
      }
    });
  }

  dialogBox(String exception, String code) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Sign In failed"),
              content: Container(
                height: 170,
                child: Column(
                  children: [Text(exception), Text(code)],
                ),
              ),
              actions: [
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      isLoading = false;
                    });
                    _emailController.clear();
                    _passwordController.clear();
                  },
                  child: Text("OK"),
                  color: UniversalVariables.background,
                )
              ],
            ));
  }

  Future<UserData> signInWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    await _getUserDatatoFirestore(authResult.user.uid);
//    _tokenRegister(authResult.user.uid);
//    _saveUserDatatoFirestore(authResult);
//    _userFromFirebase(authResult.user);
//    add(AuthBlocEvent.setUpdate);
    return _userData;
  }

  Widget _submitButton(
      TextEditingController email, TextEditingController password) {
    return GestureDetector(
      onTap: () async {
        if (formKey.currentState.validate()) {
          setState(() {
            isLoading = true;
          });
          try {
            await signInWithEmailAndPassword(
              _emailController.text,
              _passwordController.text,
            );
//              .then((value) {
            print("qwertyu");
//            _userData = context.bloc<AuthBloc>().getCurrentUser();
//            print("qqqqqqqqqqqq${_userData.accessList.length}");
//            if (_userData != null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return HomeScreen();
            }));
//            } else {}

          } on PlatformException catch (e) {
            print("exception is ${e.message}");
            dialogBox(e.message, e.code);
//            return null;
          }
        }
      },
      child: Container(
        padding: new EdgeInsets.symmetric(vertical: 5.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: UniversalVariables.background,
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Future<UserData> signInWithFacebook() async {
    try {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(
        ['public_profile'],
      );
      if (result.accessToken != null) {
        final authResult = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          ),
        );
//      _userFromFirebase(authResult.user);
        _saveUserDatatoFirestore(authResult);
//      add(AuthBlocEvent.setUpdate);
      } else {
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
    } on PlatformException catch (e) {
      print("exception is $e");
      dialogBox(e.message, e.code);
    }
  }

  Widget _facebookButton() {
    return GestureDetector(
      onTap: () {
        signInWithFacebook();
//         _getUserData();
      },
      child: Container(
        height: 40,
//        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1959a9),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('f',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff2872ba),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('Log in with Facebook',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLoading = true;
        });

        googleLogin();
      },
      child: Container(
        height: 40,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('G',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('Log in with Google',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: UniversalVariables.background,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'My',
          style: GoogleFonts.portLligatSans(
            color: UniversalVariables.background,
            fontSize: 35,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: 'D',
              style: TextStyle(color: Colors.black, fontSize: 35),
            ),
            TextSpan(
              text: 'en',
              style:
                  TextStyle(color: UniversalVariables.background, fontSize: 35),
            ),
          ]),
    );
  }

  Widget _wlcmtitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Wel',
          style: GoogleFonts.portLligatSans(
            color: UniversalVariables.background,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: 'Come',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: ' To',
              style:
                  TextStyle(color: UniversalVariables.background, fontSize: 30),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Stack(children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: height * .17),
                          Row(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _wlcmtitle(),
                                  Row(children: [
                                    SizedBox(
                                      width: 80,
                                    ),
                                    _title()
                                  ])
                                ])
                          ]),
                          SizedBox(height: 50),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                constantTextField().InputField(
                                    "Enter Email id",
                                    "abc@gmail.com",
                                    validationKey.email,
                                    _emailController,
                                    false,
                                    IconButton(
                                        icon: Icon(Icons.arrow_drop_down),
                                        onPressed: null),
                                    1,
                                    1,
                                    TextInputType.emailAddress,
                                    false),
                                SizedBox(
                                  height: 10,
                                ),
                                constantTextField().InputField(
                                    "Enter Password",
                                    "abc@gmail.com",
                                    validationKey.password,
                                    _passwordController,
                                    true,
                                    IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    1,
                                    3,
                                    TextInputType.emailAddress,
                                    _passwordVisible)
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          _submitButton(_emailController, _passwordController),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  _emailController.text == ""
                                      ? showScaffold("Enter your email id")
                                      : resetPassword(_emailController.text);
                                },
                                child: Text('Forgot Password ?',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              )),
                          _divider(),
                          _facebookButton(),
                          _googleButton(),
                          SizedBox(
                            height: 5,
                          ),
                          _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              Positioned(
                child: isLoading
                    ? Container(
                        color: Colors.transparent,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ));
  }

  Future<UserData> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );

        _saveUserDatatoFirestore(authResult);
        _userData = await _userFromFirebase(authResult.user);
        print(jsonEncode(_userData));
        print("aaaa");
//        add(AuthBlocEvent.setUpdate);
        return _userData;
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  Future<UserData> _getUserDatatoFirestore(String uid) async {
    var path = "users";
    var documentReference = Firestore.instance.collection(path).document(uid);

    DocumentSnapshot documentSnapshot =
        await documentReference.get(source: Source.serverAndCache);

    if (!documentSnapshot.exists) {
      documentSnapshot = await documentReference.get(source: Source.server);
      if (!documentSnapshot.exists) {
        _userData = null;
      } else {
        _userData = UserData.fromMap(documentSnapshot.data);
        print(_userData.uid);
      }
    } else {
      print('cache');
      print('DocumentSnapshotdata ------- ${documentSnapshot.data}');
      _userData = UserData.fromMap(documentSnapshot.data);
      print(_userData.uid);
      print('Email ------- ${documentSnapshot.data['email']}');
      print("name is --- ${_userData.name}");
    }
//    add(AuthBlocEvent.setUpdate);
    return _userData;
//    globals.userdata = _userData;
  }

  Future<UserData> _userFromFirebase(FirebaseUser user) async {
    _userData = UserData();
    if (user != null) {
      print('user exists');
      print(user.isEmailVerified);
      _userData = await _getUserDatatoFirestore(user.uid);
      print(_userData.uid);
      _userData.emailVerified = user.isEmailVerified;
      return _userData;
    } else {
      print('user dont exists');
      _userData = null;
//      add(AuthBlocEvent.setUpdate);
      return _userData;
    }
  }

  Future<void> _saveUserDatatoFirestore(AuthResult result) async {
    var path = "users";
    var documentReference =
        Firestore.instance.collection(path).document(result.user.uid);
    _userData = getGoogleAttributes(result);
    print(_userData);
    print("AuthBlock");
//    globals.userdata = _userData;
    await documentReference.setData(_userData.toJson(), merge: true);
  }

  UserData getGoogleAttributes(AuthResult result) {
    UserData userData = UserData(
      uid: result.user.providerData[0].uid,
      email: result.user.providerData[0].email,
      phoneNo: result.user.providerData[0].phoneNumber ?? '',
      name: result.user.providerData[0].displayName ?? '',
      profilePhoto: result.user.providerData[0].photoUrl ?? '',
    );

    return userData;
  }

  Future googleLogin() async {
    try {
      var value = signInWithGoogle();
//        .then((value) {
//      print(jsonEncode(value));
//      print("userData");
      if (value != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      } else {}
//      if (value.accessList != null) {
//        if (value.accessList.length == 1) {
//          var socityId = value.accessList[0].id;
//          _getToken(socityId, value.uid);
//          Navigator.pushReplacement(context,
//              MaterialPageRoute(builder: (context) {
//            return TabBarScreen();
//          }));
//        } else {
//          print("accesslist");
//          Navigator.pushReplacement(context,
//              MaterialPageRoute(builder: (context) {
//            return accessList();
//          }));
//        }
//      } else {
//        Navigator.pushReplacement(context,
//            MaterialPageRoute(builder: (context) {
//          return ActivationScreen();
//        }));
//      }
    } on PlatformException catch (e) {
      print("exception is $e");
      dialogBox(e.message, e.code);
    }
//    });
  }
}
