import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (_, __, ___) => LoginScreen(),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Instagram',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          decoration: InputDecoration(hintText: 'Email'),
                          onChanged: (value) => print(value),
                          validator: (value) => !value.contains('@')
                              ? 'Please enter a valid email.'
                              : null,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          decoration: InputDecoration(hintText: 'Password'),
                          onChanged: (value) => print(value),
                          validator: (value) => value.length < 6
                              ? 'Must be at least 6 characters.'
                              : null,
                        ),
                        const SizedBox(height: 28.0),
                        RaisedButton(
                          elevation: 1.0,
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () => print('Login'),
                          child: const Text('Log In'),
                        ),
                        const SizedBox(height: 12.0),
                        RaisedButton(
                          elevation: 1.0,
                          color: Colors.grey[200],
                          textColor: Colors.black,
                          onPressed: () =>
                              print('Navigate to the Signup Screen'),
                          child: const Text('No account? Sign up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
