import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

var storySequence = 1;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wilbur's Adventures",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Wilbur's Adventures"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String imageUrl =
      'https://adventures-of-wilbur-images.s3.eu-west-2.amazonaws.com/WP_20160601_20_38_09_Pro.jpg';
  var isVisible = true;
  var isTextVisible = false;

  var imageWidget;

  String title = "";
  String description = "";

  final _pages = <Widget>[];

  @override
  void initState() {
    _pages.add(
      ListView(
        children: <Widget>[
          Image.network(imageUrl),
          Text(title),
          Text(description),
        ],
      ),
    );

    _pages.add(
      ListView(
        children: <Widget>[
          Image.network(imageUrl),
          Text(title),
          Text(description),
        ],
      ),
    );

    _pages.add(
      ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: AssetImage('/assets/images/placeholder-image.png'),
              ),
            ),
            child: Image.network(imageUrl),
          ),
          Text(title),
          Text(description),
        ],
      ),
    );

    _getLatestImage(_selectedIndex);

    super.initState();
  }

  Future<void> _getRandomImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl =
        'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url =
        '$_wilburApiGatewayBaseUrl?imageTime=random&storyItemNumber=$storySequence';
    await _getImage(url, currentIndex);
  }

  Future<void> _getOrderedImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl =
        'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url =
        '$_wilburApiGatewayBaseUrl?imageTime=ordered&storyItemNumber=$storySequence';
    storySequence++;
    await _getImage(url, currentIndex);
  }

  Future<void> _getLatestImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl =
        'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url =
        '$_wilburApiGatewayBaseUrl?imageTime=latest&storyItemNumber=$storySequence';
    await _getImage(url, currentIndex);
  }

  // This should do the shared stuff
  // Should take a parameter to indicate what sort of image we are looking for
  // Url should be passed in from another method
  Future<void> _getImage(String url, int currentIndex) async {
    setState(() {
      _pages[currentIndex] = CircularProgressIndicator(
        backgroundColor: Colors.blue[100],
      );
      isVisible = false;
    });

    String newImage;
    String newTitle;
    String newDescription;
    var newImageWidget;

    try {
      var response = await http.get(url);

      var status = response.statusCode;

      if (status != 200) {
        newImage =
            'https://adventures-of-wilbur-images.s3.eu-west-2.amazonaws.com/WP_20160601_20_38_09_Pro.jpg';
      } else {
        await http
            .get(url)
            .then((response) => response.body)
            .then((responseImageUrl) {
          var parsedResponse = json.decode(responseImageUrl);
          newImage = parsedResponse["ImageUrl"];
          newImageWidget = Image(image: NetworkImage(newImage));
          newTitle = parsedResponse["Title"];
          newDescription = parsedResponse["Description"];
          var itemCount = parsedResponse["NumberOfItems"];

          if (storySequence > itemCount) {
            storySequence = 1;
          }
        });
      }

      if (currentIndex != _selectedIndex) {
        return;
      }
    } catch (e) {
      newImageWidget = Image(image: AssetImage('assets/images/placeholder-disaster-image.png'));
      newTitle = "Network error";
      newDescription = "Check your connection and try again";
    }


    setState(() {
      isVisible = true;
      imageWidget =  newImageWidget;
      imageUrl = newImage;
      title = newTitle;
      description = newDescription;
      _pages[_selectedIndex] = _setPageContent();
    });
  }

  Stack _setPageContent() {
    var sizeContext = MediaQuery.of(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        SizedBox(
          height: sizeContext.size.height - kToolbarHeight - kBottomNavigationBarHeight - sizeContext.padding.top - sizeContext.padding.bottom,
          width: sizeContext.size.width,
          child: Center(
            child: Container(
              height: sizeContext.size.height - kToolbarHeight - kBottomNavigationBarHeight - sizeContext.padding.top - sizeContext.padding.bottom,
              width: sizeContext.size.width,
              decoration: BoxDecoration(
                color: Colors.blueGrey[300],
                image: DecorationImage(
                  image: AssetImage('assets/images/placeholder-image.png'),
                ),
              ),
              child: FittedBox(
                child: imageWidget,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Visibility(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Color(0x99000000),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 20
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          visible: isTextVisible,
        ),
      ],
    );
  }

  void _onShowInfo() {
    setState(() {
      isTextVisible = !isTextVisible;
      _pages[_selectedIndex] = _setPageContent();
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
      _pages[index] = CircularProgressIndicator(
        backgroundColor: Colors.blue[100],
      );
    });

    if (index == 0) {
      await _getLatestImage(index);
    }

    if (index == 1) {
      await _getOrderedImage(index);
    }

    if (index == 2) {
      await _getRandomImage(index);
    }
  }

  Widget _floatingActionButton(int index) {
    if (index == 1) {
      return Visibility(
        child: FloatingActionButton(
          onPressed: () async {
            _getOrderedImage(index);
          },
          tooltip: 'Next',
          child: Icon(Icons.navigate_next),
        ),
        visible: isVisible,
      );
    }

    if (index == 2) {
      return Visibility(
        child: FloatingActionButton(
          onPressed: () async {
            _getRandomImage(index);
          },
          tooltip: 'Randomize',
          child: Icon(Icons.refresh),
        ),
        visible: isVisible,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isTextVisible ? Icons.info : Icons.info_outline),
            onPressed: _onShowInfo,
          )
        ],
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.today,
            ),
            title: Text('Latest'),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            title: Text('Story'),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            title: Text('Random'),
            backgroundColor: Colors.blue,
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          if (_selectedIndex != value) {
            _onItemTapped(value);
          }
        },
        selectedItemColor: Colors.white,
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      floatingActionButton: _floatingActionButton(_selectedIndex),
    );
  }
}
