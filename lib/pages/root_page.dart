import 'package:flutter/material.dart';
import 'package:flutter_login_demo/pages/category_page.dart';
import 'package:flutter_login_demo/pages/count_page.dart';
import 'package:flutter_login_demo/pages/login_signup_page.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:flutter_login_demo/pages/home_page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

enum PageType {
  HOME,
  COUNT,
  CATEGORY,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.pageType});

  final BaseAuth auth;
  final PageType pageType;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        switch (widget.pageType) {
          case PageType.HOME:
            if (_userId.length > 0 && _userId != null) {
              return new HomePage(
                userId: _userId,
                auth: widget.auth,
                logoutCallback: logoutCallback,
              );
            } else
              return buildWaitingScreen();
            break;
          case PageType.COUNT:
            return new CountPage(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            );
            break;
          case PageType.CATEGORY:
            return new CategoryPage(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            );
            break;
          default:
            return buildWaitingScreen();
        }
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
