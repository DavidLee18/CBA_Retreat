import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

final _google = GoogleSignIn();
final _auth = FirebaseAuth.instance;

isStaff(String isStaff) => isStaff == '공지' || isStaff == '봉사자';

launchURL(final String url) async {
  if (await canLaunch(url)) await launch(url);
  else throw 'Could not launch $url';
}

class PostListPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Q&A')),
    body: FirebaseAnimatedList(query: FirebaseDatabase.instance.reference().child('2019messages'),
        padding: EdgeInsets.all(8.0),
        defaultChild: Center(child: CircularProgressIndicator()),
        sort: (a, b) => b.key.compareTo(a.key),
        itemBuilder: (context, snapshot, animation, index) => MessagingRow(snapshot: snapshot)), floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/messaging_dialog'),
        child: Icon(Icons.chat)), resizeToAvoidBottomPadding: false,);
}

class MessagingRow extends StatefulWidget {
  final DataSnapshot? snapshot;
  final CircleAvatar avatar;
  final String? text;

  MessagingRow({this.snapshot, this.avatar = const CircleAvatar(child: Icon(Icons.account_circle)), this.text});

  @override
  _MessagingRowState createState() => _MessagingRowState();
}

class _MessagingRowState extends State<MessagingRow> {
  bool _isSelf = false;

  @override
  void initState() {
    super.initState();
    /*_auth.currentUser().then((user) { _isSelf = user?.uid == widget.snapshot.value['uid']; }).whenComplete(() {
      if(mounted) setState(() { });
    });*/
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Row(
        mainAxisAlignment: _isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _isSelf ? CrossAxisAlignment.center : CrossAxisAlignment.end,
        children: <Widget>[
          ListTile(
            leading: Column(children: [
              isStaff(widget.snapshot?.value['isStaff']) ? Image.asset('assets/images/backgroundtext.webp', width: 24.0, height: 24.0,) : Icon(Icons.account_circle),
              Text(widget.snapshot?.value['author']),
            ]),
            title: MessagingBubble(
              text: Linkify(text: widget.snapshot?.value['message'], onOpen: launchURL,),
              color: isStaff(widget.snapshot?.value['isStaff']) ? Colors.green : Colors.white,
            ),
            subtitle: Align(alignment: Alignment.centerRight, child: Text(widget.snapshot?.value['time'], style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.grey),)),
          ),
      ]),
    );
}

class MessagingBubble extends StatelessWidget {
  const MessagingBubble({this.text, this.color});

  final Widget? text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        color: color,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: text,
      /*Text(
        text,
        style: TextStyle(
          color: Colors.white,
          letterSpacing: -0.4,
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
        ),
      ),*/
    );
}

class MessagingAvatar extends StatelessWidget {
  const MessagingAvatar(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            color,
            Color.fromARGB(
              color.alpha,
              (color.red - 60).clamp(0, 255),
              (color.green - 60).clamp(0, 255),
              (color.blue - 60).clamp(0, 255),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
}