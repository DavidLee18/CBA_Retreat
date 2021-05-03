import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class MessagingDialogPage extends StatefulWidget {
  @override
  _MessagingDialogPageState createState() => _MessagingDialogPageState();
}

class _MessagingDialogPageState extends State<MessagingDialogPage> {
  final _key = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _notify = false;
  bool _first = true;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)), ),
      body: Form(key: _key, autovalidate: !_first,
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
            child: Column(children: [
              TextFormField(maxLines: 1, autofocus: true, validator: (s) => s?.length == 0 ? '입력해주세요' : null,
                decoration: InputDecoration(labelText: '이름'), controller: _nameController,),
              TextFormField(maxLines: 4, validator: (s) => s?.length == 0 ? '입력해주세요' : null,
                decoration: InputDecoration(labelText: '메세지'), controller: _messageController,),
            ], crossAxisAlignment: CrossAxisAlignment.start,),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Checkbox(value: _notify, onChanged: (v) => setState(() => _notify = v!)),
              Text('알림'),
              Icon(_notify ? Icons.notifications_active : Icons.notifications_off),
            ]),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              builder: (c) => Align(child: IconButton(icon: Icon(Icons.send), onPressed: () {
                if(_first) setState(() => _first = false);
                Scaffold.of(c).hideCurrentSnackBar();
                Scaffold.of(c).showSnackBar(SnackBar(content: Text('${_nameController.text}: ${_messageController.text}')));
              }), alignment: Alignment.centerRight,),
            ),
          ),
        ],),
      ));
}

class LoginDialogPage extends StatefulWidget {
  @override
  _LoginDialogPageState createState() => _LoginDialogPageState();
}

class _LoginDialogPageState extends State<LoginDialogPage> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _first = true;
  bool _hidePass = true;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)), ),
      body: Form(key: _key, autovalidate: !_first,
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
            child: Column(children: [
              TextFormField(autofocus: true, keyboardType: TextInputType.emailAddress, validator: (s) => s?.length == 0 ? '입력해주세요' :
              !s!.contains(r'(@)(.+)$') ? '이메일 주소를 입력하세요' : null,
                decoration: InputDecoration(labelText: '이메일'), controller: _emailController,),
              TextFormField(validator: (s) => s?.length == 0 ? '입력해주세요' : null,
                decoration: InputDecoration(labelText: '비밀번호',
                    suffixIcon: GestureDetector(child: Icon(Icons.visibility), onTapDown: (_) { setState( () => _hidePass = false ); },
                      onTapUp: (_) { setState( () => _hidePass = true ); },
                      onTapCancel: () { setState( () => _hidePass = true ); },)),
                controller: _passwordController, obscureText: _hidePass,),
            ], crossAxisAlignment: CrossAxisAlignment.start,),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              builder: (c) => Align(child: RaisedButton(child: Text('로그인'), onPressed: () async {
                if(_first) setState(() => _first = false);
                Scaffold.of(c).hideCurrentSnackBar();
                try {
                  FirebaseUser _user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                  Scaffold.of(c).showSnackBar(SnackBar(content: Text('${_user.displayName ?? _user.email}: Logged In')));
                }
                catch(e) {
                  Scaffold.of(c).showSnackBar(SnackBar(content: Text('ERROR: ${e.code} ${e.message}')));
                }
              }), alignment: Alignment.centerRight,),
            ),
          ),
        ],),
      ));
}