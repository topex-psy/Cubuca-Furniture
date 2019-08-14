import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:transparent_image/transparent_image.dart';
import 'models/produk.dart';
import 'models/promo.dart';
import 'widgets/bubbles.dart';
import 'widgets/buttons.dart';
import 'widgets/shapes.dart';
import 'widgets/progress.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';
import 'utils/utils.dart';
import 'splash.dart';
import 'katalog.dart';
import 'lokasi.dart';
import 'promo.dart';

Future main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: Colors.lightBlue, fontFamily: "Catamaran", textTheme: TextTheme(
        body1: TextStyle(fontSize: 16, height: 1.4),
        body2: TextStyle(fontSize: 14, height: 1.4),
      )),
      //localizationsDelegates: [
      //  GlobalMaterialLocalizations.delegate,
      //  GlobalWidgetsLocalizations.delegate,
      //],
      //supportedLocales: [Locale('id', 'ID'),],
      //locale: Locale('id', 'ID'),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.initialPage = 1}) : super(key: key);
  final int initialPage;

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
  double _pageValue;
  int _page;
  bool _willExit;

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
      _pageKeys[widget.initialPage].currentState?.onPageVisible();
    });
    _willExit = false;
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_page == 0 && _willExit) return h.showConfirm(judul: "Tutup Aplikasi", pesan: "Apakah Anda yakin ingin menutup aplikasi ini?", aksi: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'), doOnCancel: () {
      _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
    }) ?? false;
    if (_page == 1) {
      setState(() => _willExit = true);
      _pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
      return false;
    } else {
      _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: PageView(
            //physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: <Widget>[
              PeoplePage(key: _pageKeys[0], val: _pageValue,),
              Home(key: _pageKeys[1], val: _pageValue - 1.0, pgc: _pageController),
              StatsPage(key: _pageKeys[2], val: _pageValue - 2.0,),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _onPageChanged(_page);
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
      if (page > 0 && _willExit) _willExit = false;
    });
    _pageKeys[_page].currentState.onPageVisible();
  }
}

abstract class MainPageStateMixin<T extends StatefulWidget> extends State<T> {
  void onPageVisible();
}

class Home extends StatefulWidget {
  Home({Key key, this.val, this.pgc}) : super(key: key);
  final double val;
  final PageController pgc;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin, MainPageStateMixin {
  @override
  void onPageVisible() {
    if (_isStarted && Random().nextInt(3) == 1) _getPromoTerbaru();
  }

  List<KategoriProduk> _listKategoriProduk = [];

  Future<dynamic> _getPromoTerbaru() {
    return getPromoTerbaru().then((prm) {
      print("DATA PROMO TERBARU RESPONSE:" + prm.toString());
      Future.delayed(Duration(milliseconds: 2000), () {
        if (widget.val == 0.0) h.showAlert(prm.judul, Column(children: <Widget>[
          FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: prm.gambar, fit: BoxFit.contain,),
          SizedBox(height: 8,),
          Html(data: prm.penawaran),
        ],), customButton: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            Future.delayed(Duration(milliseconds: 500), () => Navigator.push(context, MaterialPageRoute(builder: (context) => Promo())));
            //Navigator.push(context, MaterialPageRoute(builder: (context) => Promo()));
          },
          child: Row(children: <Widget>[
            Text("Cek Promo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            SizedBox(width: 5,),
            Icon(Icons.chevron_right, size: 24,),
          ],),
        ));
      });
      print("DATA PROMO TERBARU BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA PROMO TERBARU ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PROMO TERBARU DONEEEEEEEEEEEEE!");
    });
  }

  Future<dynamic> _getListKategoriProduk() {
    return getListKategoriProduk().then((responseJson) {
      print("DATA KATEGORI PRODUK RESPONSE:" + responseJson.toString());
      var result = responseJson["result"];
      List<KategoriProduk> listKategoriProduk = [];
      for (Map res in result) { listKategoriProduk.add(KategoriProduk.fromJson(res)); }
      setState(() {
        _listKategoriProduk = listKategoriProduk;
        _pageCount = result.length + 1;
      });
      print("DATA KATEGORI PRODUK BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA KATEGORI PRODUK ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA KATEGORI PRODUK DONEEEEEEEEEEEEE!");
    });
  }

  PageController _pageController;
  double _pageValue = 0.0;
  int _pageCount = 0;

  Animation firstAnimation, delayedAnimation, muchDelayedAnimation;
  AnimationController _animationController;
  AnimationController _nudgeController;
  Animation _nudge;

  AnimationController _pulseController;
  Animation _pulse;

  bool _isStarted;

  @override
  void initState() {
    super.initState();
    _getListKategoriProduk();

    _pageController = PageController(viewportFraction: 0.5, initialPage: _pageValue.floor());
    _pageController.addListener(() {
      setState(() => _pageValue = _pageController.page);
    });

    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this);
    firstAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.2, 0.8, curve: Curves.fastOutSlowIn)));
    delayedAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.35, 0.9, curve: Curves.fastOutSlowIn)));
    muchDelayedAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _pulseController.forward();
    }));

    _pulseController = AnimationController(duration: Duration(seconds: 5), vsync: this);
    _pulse = Tween(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController,
      curve: Interval(0.85, 1.0, curve: Curves.easeInOut)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    }));

    _nudgeController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _nudge = Tween(begin: 0.0, end: -10.0).animate(CurvedAnimation(
      parent: _nudgeController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nudgeController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _nudgeController.forward();
      }
    }));
    _nudgeController.forward();
    _isStarted = false;

    Future _splashScreen() async {
      Map results = await Navigator.of(context).push(TransparentRoute(builder: (BuildContext context) => Splash()));
      if (results != null && results.containsKey('isStarted')) {
        setState(() {
          _isStarted = results['isStarted'];
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
      print("LAUNCH SPLASH SCREEN!");
      _splashScreen();
    });
  }
  
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _nudgeController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
  }

  HSLColor _warnaBG() {
    double hue = 190.0;
    return _pageCount == 0 ? HSLColor.fromAHSL(0.85, hue, 0.8, 0.8) : HSLColor.fromAHSL(0.85, (hue + 360.0 * (_pageValue / _pageCount)) % 360.0, 0.8, 0.8);
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    if (_isStarted) Future.delayed(Duration(milliseconds: 500), () => _animationController.forward());

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

    return Container(
      color: Colors.blueGrey.withOpacity(max(0.0, widget.val * -0.4)),
      child: Transform(
        transform: Matrix4.translationValues(widget.val * 200, 0, 0),
        child: Transform(
          alignment: FractionalOffset.center,
          transform: perspective.scaled(scl, scl, scl)
            ..rotateX(0.0)
            ..rotateY(widget.val < 0 ? widget.val * -1.0 : 0.0)
            ..rotateZ(0.0),
          child: Opacity(
            opacity: min(1.0, 1.0 + widget.val / 4),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: _pageCount == 0 ? Alignment(0,0) : Alignment(-1.0 + (_pageValue / _pageCount) * 2.0, 0),
                  image: AssetImage("images/bg.jpg"),
                  fit: BoxFit.cover,
                )
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: Material(color: _warnaBG().toColor())),
                  Positioned.fill(child: Particles(30)),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 0.0,
                      sigmaY: 0.0,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    )
                  ),
                  SafeArea(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.all(13),
                                /* child: PopupMenuButton<String>(
                                  child: Icon(Icons.sort, color: Colors.black87),
                                  tooltip: "Bantuan",
                                  onSelected: a.menuAction,
                                  itemBuilder: (BuildContext context) {
                                    return MenuPojok.listMenu.map<PopupMenuEntry<String>>((menu) {
                                      return menu == ""?PopupMenuDivider(height: 10,):PopupMenuItem(value: menu, child: Text(menu, style: TextStyle(height: 0.75),),);
                                    }).toList();
                                  },
                                ), */
                                child: IconButton(
                                  color: Colors.black87,
                                  icon: Icon(Icons.sort),
                                  tooltip: "Menu",
                                  onPressed: () {
                                    widget.pgc.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                color: Colors.black87,
                                icon: Icon(Icons.search),
                                tooltip: "Cari",
                                onPressed: () {
                                  widget.pgc.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
                                },
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (BuildContext context, Widget child) {
                              return AnimatedBuilder(
                                animation: _pulseController,
                                builder: (BuildContext context, Widget child) {
                                  return Container(
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: Stack(children: <Widget>[
                                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                    Expanded(child: Container(),),
                                    Transform.scale(scale: 1.0 + ((_pageValue - _pageValue.floor()) > 0.5 ? 1.0 - (_pageValue - _pageValue.floor()) : (_pageValue - _pageValue.floor())) / 5.0, child:
                                      /* GestureDetector(
                                        onTap: () => _splashScreen(),
                                        child: Hero(tag: "SplashLogo", child: Image.asset("images/icon.png", width: 120.0),),
                                      ), */
                                      Hero(tag: "SplashLogo", child: Image.asset("images/icon.png", width: 120.0),),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(Kontak.nama, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                    Text(Kontak.slogan, style: TextStyle(fontSize: 18),),
                                    Text(Kontak.deskripsi, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),)
                                  ],),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Transform.scale(
                                      scale: firstAnimation.value * _pulse.value,
                                      child: MenuButton(icon: Icons.favorite, teks: "Wishlist", ukuranIcon: 38.5, warnaIcon: Colors.red, notif: 5, aksi: () {},),
                                    ),
                                  ),
                                  Positioned(
                                    right: 60,
                                    top: 64,
                                    child: Transform.scale(
                                      scale: delayedAnimation.value * _pulse.value,
                                      child: MenuButton(icon: Icons.card_giftcard, teks: "Promo", ukuranIcon: 30.8, warnaIcon: Colors.orange, notif: 2, aksi: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Promo())),),
                                    ),
                                  ),
                                  Positioned(
                                    right: 22,
                                    top: 132,
                                    child: Transform.scale(
                                      scale: muchDelayedAnimation.value * _pulse.value,
                                      child: MenuButton(icon: Icons.map, teks: "Lokasi", ukuranIcon: 24.2, warnaIcon: Colors.lightGreen, aksi: () {
                                        //Navigator.of(context).push(TransparentRoute(builder: (BuildContext context) => Lokasi()));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Lokasi()));
                                      },),
                                    ),
                                  ),
                                ],)
                              );
                                }
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 250.0,
                          child: _pageCount == 0 ? Center(child: LoadingCircle(),) : PageView.builder(
                            controller: _pageController,
                            itemCount: _pageCount,
                            itemBuilder: (BuildContext context, int position) => buildItem(context, position),
                            physics: BouncingScrollPhysics(),
                            pageSnapping: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isStarted ? SizedBox() : Positioned.fill(child: Material(color: Colors.white,)),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Material(color: Colors.black.withOpacity(max(0.0, 0.35 * widget.val))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildItemCard(BuildContext context, int position, {bool showLabel = false}) {
    KategoriProduk item = _listKategoriProduk[position - 1];
    return Padding(
      padding: EdgeInsets.only(top: 60, bottom: 30, left: 8, right: 8),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned.fill(
            child: Card(
              color: Colors.transparent,
              margin: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
              child: Hero(
                tag: "KategoriProduk${item.id}",
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: item.gambar, height: 250, fit: BoxFit.cover,),
                ),
              ),
            ),
          ),
          showLabel ? Padding(
            padding: EdgeInsets.only(bottom: 7.5),
            child: Text(item.judul.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(
              shadows: [
                Shadow(
                  offset: Offset(0.0, 0.0),
                  blurRadius: 8.0,
                  color: Colors.white
                )
              ],
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.normal),
            ),
          ) : Container(),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: Color(0x11BCAAA4),
                onTap: () {
                  h.playSound("butt_press.wav");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Katalog(item: item, color: _warnaBG(),)));
                },
              ),
            ),
          ),
          Positioned(
            top: 5,
            child: Opacity(
              opacity: 1.0 - min(1.0, (_pageValue - position).abs()),
              child: Transform(
                transform: Matrix4.translationValues(0, _nudge.value + (-50.0 * min(1.0, (_pageValue - position).abs()) - 32.0), 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white60,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: Text(item.judul, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),),
                    //child: Text("${item.jumlah} Produk", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),),
                  ),
                  Transform.rotate(angle: pi, child: CustomPaint(
                    painter: TrianglePainter(
                      strokeColor: Colors.white,
                      strokeWidth: 1.0,
                      paintingStyle: PaintingStyle.fill,
                    ),
                    child: Container(
                      height: 6,
                      width: 9,
                    ),
                  ),)
                ],)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int position) {
    double scaleFactor = (position - _pageValue).abs();
    double scaleVal = 4 - scaleFactor;
    scaleVal /= 3.5;

    return AnimatedBuilder(
      animation: _nudgeController,
      builder: (BuildContext context, Widget child) {
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()..scale(scaleVal, scaleVal),
          child: position == 0 ? Opacity(opacity: 1.0 - min(1.0, _pageValue), child: Transform(transform: Matrix4.translationValues((-50.0 * min(1.0, _pageValue)), 0, 0), child: FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => _pageController.animateToPage(1, duration: Duration(milliseconds: 800), curve: Curves.easeOutExpo),
            child: Transform.translate(
              offset: Offset(_nudge.value, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chevron_left, color: Colors.black, size: 40,),
                  SizedBox(width: 4),
                  Expanded(child: Text("Pilihan produk tersedia", style: TextStyle(color: Colors.black, fontSize: 14, height: 1.1),),),
                  SizedBox(width: 14),
                ],
              ),
            ),
          ),),) : buildItemCard(context, position),
        );
      }
    );
  }
}

class PeoplePage extends StatefulWidget {
  PeoplePage({Key key, this.val}) : super(key: key);
  final double val;

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
      scale: 1.0, // - widget.val / 3.0,
      child: Opacity(
        opacity: max(0.0, -widget.val + 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerRight,
              end: FractionalOffset.centerLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.4),
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                0.3,
                1.0,
              ]
            )
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 75),
            child: Center(
              child: Transform.rotate(
                angle: widget.val * 20.0,
                child: Icon(Icons.settings, size: 100, color: Colors.grey[400],),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatsPage extends StatefulWidget {
  StatsPage({Key key, this.val}) : super(key: key);
  final double val;

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
      offset: Offset((widget.val + 1.0) * 120.0, 0.0),
      child: Material(
        elevation: 20,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerRight,
              end: FractionalOffset.centerLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.2),
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                0.3,
                1.0,
              ]
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 8, left: 22, right: 22),
                  child: Text("Halo!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: ListBody(
                      children: <Widget>[
                        Transform.translate(offset: Offset(widget.val * -100, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: ListMenuDrawer(Icons.rate_review, "Beri Rating", () {}))),
                        Transform.translate(offset: Offset(widget.val * -200, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: ListMenuDrawer(Icons.info, "Tentang Kami", () {}))),
                        Transform.translate(offset: Offset(widget.val * -300, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: ListMenuDrawer(Icons.bookmark, "Syarat & Privasi", () {}))),
                        Transform.translate(offset: Offset(widget.val * -400, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: ListMenuDrawer(Icons.people, "Jadi Mitra", () {}))),
                        Transform.translate(offset: Offset(widget.val * -450, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: Divider(color: Colors.black38,))),
                        Transform.translate(offset: Offset(widget.val * -500, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: ListMenuDrawer(Icons.help, "Bantuan", () {}))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}