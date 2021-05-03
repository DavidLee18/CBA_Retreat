import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

class ImagesTabPage extends StatelessWidget {
  final List<String> tabs;
  final String image;
  final String? title;

  const ImagesTabPage({Key? key, required this.tabs, required this.image, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTabController(length: tabs.length, child: Scaffold(
    appBar: AppBar(title: this.title != null ? Text(this.title!) : null,
        bottom: TabBar(tabs: tabs.map((s) => Tab(text: s)).toList())),
    body: TabBarView(children: List.generate(tabs.length, (i) => i+1).map((i) => ImagePage('$image$i.png', appbar: false,)).toList()),
  ));
}

class ImageButton extends StatelessWidget {
  final String assetPath;
  final String? tooltip;
  final VoidCallback? onTap;
  final double size;
  final EdgeInsetsGeometry padding;

  const ImageButton({Key? key, this.tooltip, this.onTap, required this.assetPath, this.size = 24.0, this.padding = const EdgeInsets.all(8.0)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = InkWell(key: key,
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Image.asset(assetPath, width: size, height: size,),
        ));
    if(tooltip != null) {
      result = Tooltip(message: tooltip!, child: result,);
    }
    return result;
  }

}

class ImagePage extends StatefulWidget {
  final String _file;
  final bool appbar;
  final String? title;

  ImagePage(this._file, {this.appbar = true, this.title});
  @override
  _ImagePageState createState() => _ImagePageState(_file);
}

class _ImagePageState extends State<ImagePage> {
  final String _file;
  String? _url;
  bool _error = false;
  dynamic _errorCode;
  Future? _operation;

  _ImagePageState(this._file);

  @override
  void initState() {
    super.initState();
    _operation = FirebaseStorage.instance.ref().child(_file).getDownloadURL().then((url) => _url = url, onError: (error) { _error = true; _errorCode = error; });
    _operation = _operation?.then((_) { if(mounted) setState(() {}); });
  }

  @override
  void dispose() {
    super.dispose();
    _operation = _operation?.timeout(Duration(seconds: 0), onTimeout: () {});
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.appbar ? AppBar(title: widget.title != null ? Text(widget.title!) : null) : null,
    body: Center(child: _url == null ?
    _error ? Row(children:[Icon(Icons.error, color: Colors.red,), Text('error occured: $_errorCode')]) :
    CircularProgressIndicator() :
    Image.network(_url!) ),
  );
}
