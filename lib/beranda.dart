import 'package:flutter/material.dart';

void main() => runApp(TestApp());

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialPage;

  MainScreen({Key key, this.initialPage = 1}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();

  static MainScreenState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<MainScreenState>());
  }
}

class MainScreenState extends State<MainScreen> {
  final List<GlobalKey<MainPageStateMixin>> _pageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  PageController _pageController;
  int _page;
  double _pageValue;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage ?? 1;
    _pageController = PageController(viewportFraction: 0.999, initialPage: _page);
    _pageController.addListener(() {
      setState(() => _pageValue = _pageController.page);
    });
    _pageValue = widget.initialPage.toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageKeys[widget.initialPage].currentState.onPageVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Custom PageView"),
      ),
      body: Container(
        child: PageView(
          //physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: <Widget>[
            PeoplePage(key: _pageKeys[0], val: _pageValue, bgColor: Colors.purple,),
            TimelinePage(key: _pageKeys[1], val: _pageValue - 1.0, bgColor: Colors.green,),
            StatsPage(key: _pageKeys[2], val: _pageValue - 2.0, bgColor: Colors.amber,),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: _onBottomNavItemPressed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text('people'),
            icon: Icon(Icons.people),
          ),
          BottomNavigationBarItem(
            title: Text('timeline'),
            icon: Icon(Icons.history),
          ),
          BottomNavigationBarItem(
            title: Text('stats'),
            icon: Icon(Icons.pie_chart),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _onPageChanged(_page);
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _pageKeys[_page].currentState.onPageVisible();
  }

  void _onBottomNavItemPressed(int index) {
    setState(() => _page = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }
}

abstract class MainPageStateMixin<T extends StatefulWidget> extends State<T> {
  void onPageVisible();
}

class PeoplePage extends StatefulWidget {
  PeoplePage({Key key, this.val, this.bgColor}) : super(key: key);
  final double val;
  final Color bgColor;

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> with MainPageStateMixin {

  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 - widget.val / 3.0,
      child: Container(
        color: widget.bgColor?.withOpacity(0.2),
        child: Center(
          child: Text('Halaman People ${widget.val}'),
        ),
      ),
    );
  }
}

class TimelinePage extends StatefulWidget {
  TimelinePage({Key key, this.val, this.bgColor}) : super(key: key);
  final double val;
  final Color bgColor;

  @override
  TimelinePageState createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> with MainPageStateMixin {
  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 _pmat(num pv) {
      return Matrix4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, pv * 0.001,
        0.0, 0.0, 0.0, 1.0,
      );
    }

    Matrix4 perspective = _pmat(1.0);
    double scl = widget.val < 0 ? 1.0 + widget.val / 3.0 : 1.0;

    return Transform(
      transform: Matrix4.translationValues(widget.val * 200, 0, 0),
      child: Transform(
        alignment: FractionalOffset.center,
        transform: perspective.scaled(scl, scl, scl)
          ..rotateX(0.0)
          ..rotateY(widget.val < 0 ? widget.val * -1.0 : 0.0)
          ..rotateZ(0.0),
        child: Container(
          color: widget.bgColor?.withOpacity(0.2),
          child: Center(
            child: Text('Halaman Timeline ${widget.val}'),
          ),
        ),
      ),
    );
  }
}

class StatsPage extends StatefulWidget {
  StatsPage({Key key, this.val, this.bgColor}) : super(key: key);
  final double val;
  final Color bgColor;

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> with MainPageStateMixin {
  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset((widget.val + 1.0) * 100.0, 0.0),
      child: Container(
        color: widget.bgColor?.withOpacity(0.2),
        child: Center(
          child: Text('Halaman Stats ${widget.val}'),
        ),
      ),
    );
  }
}