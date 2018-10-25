import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/bo/UserBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/UserResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/services/InstanceIDService.dart';
import 'package:amadeus/utils/DialogUtils.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  final String initialHost;
  final String initialEmail;
  final String initialPassword;
  final bool rememberPassword;
  LoginPage({Key key, this.initialHost, this.initialEmail, this.initialPassword, this.rememberPassword}) : super(key: key);
  @override
  LoginPageState createState() => new LoginPageState(initialHost, initialEmail, initialPassword, rememberPassword);
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  bool _loggingIn = false;
  String _tokenFB;
  String email;
  String password;
  String host;

  LoginPageState(this.initialHost, this.initialEmail, this.initialPassword, this.passwordCheckboxValue);

  static String emailKey = "EMAIL_KEY";
  static String hostKey = "HOST_KEY";
  static String passwordKey = "PASSWORD_KEY";
  static String rememberPasswordKey = "REMEMBER_PASSWORD_KEY";

  String initialEmail;
  String initialHost;
  String initialPassword;
  bool passwordCheckboxValue;

  AnimationController animationController;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _loggingIn = false;
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
    animationController.repeat();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token){
      print(token);
      _tokenFB = token;
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.onTokenRefresh.listen((token) {
      print("Refreshed: $token");
      _tokenFB = token;
    });
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    
    setState(() {
      _loggingIn = true;
    });

    try{
      UserResponse userResponse = await UserBO().login(context, host, email, password);
      
      if(userResponse != null) {
        if(userResponse.success && userResponse.number == 1) {
          UserModel user = userResponse.data;
          await UserCacheController.setUserCache(context, user);
          TokenResponse token = await TokenCacheController.getTokenCache(context);

          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString(emailKey, email);
          sharedPreferences.setString(hostKey, host);
          if(passwordCheckboxValue) {
            sharedPreferences.setString(passwordKey, password);
          } else {
            sharedPreferences.remove(passwordKey);
          }
          sharedPreferences.setBool(rememberPasswordKey, passwordCheckboxValue);

          InstanceIDService id = new InstanceIDService();
          await id.sendRegistrationServer(context, user, _tokenFB);

          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
              settings: const RouteSettings(name: 'home-page'), 
              builder: (context) => new HomePage(user: user, token: token),
            ),
          );
          return;
        } else {
          if(userResponse.title != null && userResponse.title.isNotEmpty && userResponse.message != null && userResponse.message.isNotEmpty) {
            DialogUtils.dialog(context, title: userResponse.title, message: userResponse.message);
          } else {
            DialogUtils.dialog(context);
          }
        }
      } else {
        DialogUtils.dialog(context, message: Translations.of(context).text("errorBoxMsgLogin"));
      }
    } on FormatException {
      DialogUtils.dialog(context, message: Translations.of(context).text("errorBoxMsgHost"));
    } on SocketException catch(_) {
      DialogUtils.dialog(context, message: Translations.of(context).text("errorBoxMsgHost"));
    } on TimeoutException catch(_) {
      DialogUtils.dialog(context, message: Translations.of(context).text("errorBoxMsgHost"));
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
    }
    setState(() {
      initialEmail = email;
      initialHost = host;
      if(passwordCheckboxValue) {
        initialPassword = password;
      } else {
        initialPassword = "";
      }
      _loggingIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final Container logoImg = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/logo.png"),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: null,
      height: 200.0,
    );

    final TextFormField hostInput = new TextFormField(
      initialValue: initialHost,
      validator: (value) {
        if(value.isEmpty) {
          return Translations.of(context).text('errorFieldRequired');
        } else {
          host = value;
        }
      },
      keyboardType: TextInputType.url,
      autofocus: false,
      style: TextStyle(
        color: primaryWhite,
      ),
      decoration: InputDecoration(
        labelText: Translations.of(context).text('promptUrl'),
        labelStyle: TextStyle(
          color: primaryWhite,
        ),
      ),
    );

    final TextFormField emailInput = new TextFormField(
      initialValue: initialEmail,
      validator: (value) {
        if(value.isEmpty) {
          return Translations.of(context).text('errorFieldRequired');
        } else if(!value.contains('@')) {
          return Translations.of(context).text('errorInvalidEmail');
        } else {
          email = value;
        }
      },
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      style: TextStyle(
        color: primaryWhite,
      ),
      decoration: InputDecoration(
        labelText: Translations.of(context).text('promptEmail'),
        labelStyle: TextStyle(
          color: primaryWhite,
        ),
      ),
    );

    final TextFormField passwordInput = new TextFormField(
      initialValue: initialPassword,
      validator: (value) {
        if(value.isEmpty) {
          return Translations.of(context).text('errorInvalidPassword');
        } else {
          password = value;
        }
      },
      autofocus: false,
      obscureText: true,
      style: TextStyle(
        color: primaryWhite,
      ),
      decoration: InputDecoration(
        labelText: Translations.of(context).text('promptPassword'),
        labelStyle: TextStyle(
          color: primaryWhite,
        ),
      ),
    );

    var passwordCheckbox = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Theme(
          data: new ThemeData(
            toggleableActiveColor: primaryGreen,
            unselectedWidgetColor: primaryWhite,
          ),
          child: new Checkbox(
            value: passwordCheckboxValue,
            onChanged: (bool value) => setState(() {
              passwordCheckboxValue = value;
            }),
          ),
        ),
        new GestureDetector(
          onTap: () => setState(() {
            passwordCheckboxValue = !passwordCheckboxValue;
          }),
          child: new Text(
            Translations.of(context).text("rememberPassword"),
            style: new TextStyle(color: primaryWhite),
          ),
        ),
      ],
    );

    final loginBtn = new Material(
      borderRadius: BorderRadius.circular(10.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 50.0,
        color: primaryGreen,
        onPressed: () {
          if(_formKey.currentState.validate()) {
            _attemptLogin();
          }
        },
        child: Text(Translations.of(context).text('actionSignIn'), style: TextStyle(color: primaryWhite, fontSize: 20.0),),
      ),
    );

    Widget _getBody() {
      if(_loggingIn) {
        return new Center(
          child: new AnimatedBuilder(
            animation: animationController,
            child: new Container(
              width: 80.0,
              height: 80.0,
              child: new Image.asset("images/logo.png"),
            ),
            builder: (BuildContext context, Widget _widget) {
              return new Transform.rotate(
                angle: animationController.value * 18.9,
                child: _widget,
              );
            },
          ),
        );
      } else {
        EdgeInsetsGeometry padding45 = new EdgeInsets.symmetric(horizontal: 45.0);
        return new Center(
          child: new Form(
            key: _formKey,
            child: new ScrollConfiguration(
              behavior: new MyBehavior(),
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  logoImg,
                  new SizedBox(height: 15.0),
                  new Padding(
                    padding: padding45,
                    child: hostInput,
                  ),
                  new SizedBox(height: 15.0),
                  new Padding(
                    padding: padding45,
                    child: emailInput,
                  ),
                  new SizedBox(height: 15.0),
                  new Padding(
                    padding: padding45,
                    child: passwordInput,
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: passwordCheckbox,
                  ),
                  new Padding(
                    padding: padding45,
                    child: loginBtn,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return new Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: _getBody(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}