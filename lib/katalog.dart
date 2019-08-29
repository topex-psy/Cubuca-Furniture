import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/bubbles.dart';
import 'widgets/widgets.dart';
import 'models/produk.dart';
import 'utils/utils.dart';
import 'detail_produk.dart';

class Katalog extends StatefulWidget {
  Katalog({Key key, this.item, this.color}) : super(key: key);
  final KategoriProduk item;
  final HSLColor color;

  @override
  _KatalogState createState() => _KatalogState();
}

class _KatalogState extends State<Katalog> with TickerProviderStateMixin {

  List<JenisProduk> _listJenisProduk = [];
  List<Produk> _listProduk = [];
  List<Produk> _listProdukFiltered = [];

  AnimationController _animationController;
  Animation _animation;

  AnimationController _searchAnimationController;
  Animation _searchAnimation;

  AnimationController _opacityController;
  Animation<double> _opacity;

  TabController _tabController;
  ScrollController _customScrollController = ScrollController();
  TextEditingController _searchController;
  FocusNode _searchFocusNode;
  bool _searchBarVisible = false;
  bool _isFirstLoad = true;
  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final Map<int, int> _offsetJenisProduk = Map();
  final key = GlobalKey<ScaffoldState>();

  List<String> _myWishlist = [];
  
  Future<dynamic> _getMyWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myWishlist = prefs.getStringList('myWishlist') ?? [];
  }

  Future<dynamic> _setMyWishlist(Produk item, int aksi, {int aksiKe = 0}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myWishlist = _myWishlist;
    if (aksi == 1) myWishlist.add(item.id.toString()); else myWishlist.remove(item.id.toString());
    await prefs.setStringList('myWishlist', myWishlist);
    print("PANGGIL SETSTATE = _myWishlist");
    setState(() { _myWishlist = myWishlist; });
    key.currentState.hideCurrentSnackBar();
    key.currentState.showSnackBar(
      SnackBar(content: Text("${item.judul} telah " + (aksi == 1 ? "ditambahkan ke" : "dihapus dari") + " favorit!"), behavior: SnackBarBehavior.floating, action: SnackBarAction(
        onPressed: () => _setMyWishlist(item, aksi==1?0:1, aksiKe: aksiKe+1),
        label: aksiKe % 2 == 0 ? "Undo" : "Redo",
      ),),
    );
  }

  Widget _createListProdukItem(Produk item) {
    print("_createListProdukItem THUMBNAIL = ${Uri.encodeFull(item.thumbnail)}");
    bool isWishlist = _myWishlist.contains(item.id.toString());
    String urlThumb = item.thumbnail;
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200],
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProduk(item: item, color: widget.color,))),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
              child: Hero(
                tag: "Produk${item.id}",
                transitionOnUserGestures: true,
                child: ClipRRect(borderRadius: BorderRadius.circular(15), child:
                  CachedNetworkImage(
                    imageUrl: Uri.encodeFull(urlThumb),
                    placeholder: (context, url) => Container(width: 100, height: 100, padding: EdgeInsets.all(50), child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(width: 100, height: 100, child: Center(
                      child: Icon(Icons.error, color: Colors.grey,),
                    )),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 14,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5,),
                Text(item.judul, style: TextStyle(fontSize: 14, height: 1.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 5,),
                Text("Kode: ${item.sku}", style: TextStyle(fontSize: 12, height: 1.0, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    UiButton(color: item.isTersedia?Colors.greenAccent[700]:Colors.blue, teks: item.isTersedia?"Beli":"Pre-Order", aksi: () => a.beliProduk(item),),
                    SizedBox(width: 8.0,),
                    IconButton(
                      icon: Icon(isWishlist ? Icons.favorite : Icons.favorite_border, color: isWishlist ? Colors.red : Colors.grey,),
                      tooltip: isWishlist ? "Hapus wishlist" : "Tambahkan ke wishlist",
                      onPressed: () => _setMyWishlist(item, isWishlist?0:1),
                    ),
                  ],
                ),
                item.isTersedia || (item.ketPreOrder??"").isEmpty? Container() : Row(children: <Widget>[
                  Icon(Icons.access_time, color: Colors.black54, size: 14,),
                  SizedBox(width: 3,),
                  Text(item.ketPreOrder, style: TextStyle(color: Colors.black54, fontSize: 14),)
                ],),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createStackProduk(int offset, JenisProduk j) {
    print("_createStackProduk OFFSET = $offset, JUMLAH PRODUK = ${j.jumlah}");
    return SliverStickyHeaderBuilder(
      builder: (context, state) => Container(
        height: 44.0,
        color: widget.color.withLightness(state.isPinned ? 0.85 : 0.9).toColor(), //state.scrollPercentage
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(j.judul, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),),
      ),
      sliver: SliverFixedExtentList(
        itemExtent: 130.0,
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (_listProdukFiltered.isEmpty || index + offset > _listProdukFiltered.length - 1) return Container();
            return Transform(
              transform: Matrix4.translationValues(h.screenSize().width * (1.0 + index / 2.0) * _animation.value, 0, 0),
              child: _createListProdukItem(_listProdukFiltered[index + offset]),
            );
          },
          childCount: j.jumlah,
        ),
      ),
    );
  }

  Widget _createListProduk() {
    print("PANGGIL FUNGSI = _createListProduk()");
    print("OFFSET JENIS PRODUK = $_offsetJenisProduk");
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _onSearchTextChanged(_searchController.text),
      child: CustomScrollView(
        controller: _customScrollController,
        slivers: _listJenisProduk.asMap().map((int i, JenisProduk j) {
          return MapEntry(i, _createStackProduk(_offsetJenisProduk[i], j));
        }).values.toList(),
      ),
    );
  }

  Future<dynamic> _getData() {
    return getListProduk(kategori: widget.item.id, keyword: _searchController.text).then((responseJson) {
      print("DATA PRODUK RESPONSE:" + responseJson.toString());
      var result = responseJson["result"];
      List<Produk> listProduk = [];
      for (Map res in result) { listProduk.add(Produk.fromJson(res)); }
      print("PANGGIL SETSTATE = _listProduk, _listProdukFiltered");
      setState(() {
        _listProduk = listProduk;
        _listProdukFiltered = listProduk;
        _getProductTypes();
      });
      print("DATA PRODUK BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA PRODUK ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PRODUK DONEEEEEEEEEEEEE!");
    });
  }

  _getProductTypes() {
    List<JenisProduk> listJenisProduk = [];
    if (_listProdukFiltered.isNotEmpty) {
      int idJenis = _listProdukFiltered[0].idJenis;
      String jenis = _listProdukFiltered[0].jenis;
      int jumlah = 0;
      int offset = 0;
      int indeks = 0;
      print("GET PRODUCT TYPES _listProdukFiltered = $_listProdukFiltered");
      print("GET PRODUCT TYPES _listProdukFiltered.length = ${_listProdukFiltered.length}");
      _offsetJenisProduk[0] = 0;
      for (int i = 0; i <= _listProdukFiltered.length; i++) {
        if (i == _listProdukFiltered.length || jenis != _listProdukFiltered[i].jenis) {
          JenisProduk jenisProduk = JenisProduk(id: idJenis, judul: jenis, jumlah: jumlah);
          listJenisProduk.add(jenisProduk);
          print("GET PRODUCT TYPES listJenisProduk.add = $jenisProduk");
          
          indeks++;
          _offsetJenisProduk[indeks] = offset;
          if (i == _listProdukFiltered.length) break;
          Produk prd = _listProdukFiltered[i];
          idJenis = prd.idJenis;
          jenis = prd.jenis;
          jumlah = 0;
        }
        jumlah++;
        offset++;
      }
      print("GET PRODUCT TYPES listJenisProduk = $listJenisProduk");
    }
    print("PANGGIL SETSTATE = _tabController, _listJenisProduk, _isLoading");
    setState(() {
      _tabController = TabController(vsync: this, length: listJenisProduk.length);
      _listJenisProduk = listJenisProduk;
      _isLoading = false;
    });
    if (_isFirstLoad && _listProdukFiltered.isNotEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn,)..addStatusListener((status) {
      if (status == AnimationStatus.completed && _isFirstLoad) {
        print("PANGGIL SETSTATE = _isFirstLoad");
        setState(() => _isFirstLoad = false);
      }
    }));

    _searchAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _searchAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeIn,
    ));

    _opacityController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _opacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut));
    _opacityController.forward();

    _tabController = TabController(vsync: this, length: _listJenisProduk.length);
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
    _getMyWishlist().then((result) {
      _getData();
    }).catchError((e) {
      print("GET WISHLIST ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("GET WISHLIST DONEEEEEEEEEEEEE!");
    });
    //_getData();

    _customScrollController.addListener(() {
      double offset = _customScrollController.offset;
      for (int i = _offsetJenisProduk.length - 1; i >= 0; i--) {
        if (offset >= _offsetJenisProduk[i] * 130.0 + 44.0 * i) {
          _tabController.animateTo(i, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
          break;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) { // when widget built
      //_refreshIndicatorKey.currentState.show();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _opacityController.dispose();
    _tabController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _searchAnimationController.dispose();
    _customScrollController.dispose();
    super.dispose();
  }

  Future<void> _onSearchTextChanged(String keyword) async {
    if (_listProduk.isEmpty) return;

    if ((keyword ?? "").isEmpty) {
      print("SEARCH KEYWORD EMPTY");
      _getData();
      return;
    }

    print("SEARCH KEYWORD: \"$keyword\" (_listProduk.length = ${_listProduk.length})");
    List<Produk> _listProdukFound = [];
    List<Produk> _listProdukAll = [];
    _listProdukAll.addAll(_listProduk);
    _listProduk.forEach((Produk produk) {
      if (produk.judul.toLowerCase().contains(keyword.toLowerCase()) ||
          produk.sku.toLowerCase().contains(keyword.toLowerCase()) ||
          produk.jenis.toLowerCase().contains(keyword.toLowerCase()) ||
          produk.kategori.toLowerCase().contains(keyword.toLowerCase())) {
        _listProdukFound.add(produk);
      }
    });
    print("PANGGIL SETSTATE = _listProdukFiltered, _listProduk");
    setState(() {
      _listProdukFiltered = _listProdukFound;
      _listProduk = _listProdukAll;
      _getProductTypes();
    });
  }

  _closeSearch() {
    print("PANGGIL SETSTATE = _searchBarVisible");
    setState(() { _searchBarVisible = false; });
    _searchController.text = "";
    _onSearchTextChanged("");
  }

  Future<bool> _onWillPop() async {
    h.playSound("player_dash.wav");
    if (_searchBarVisible && _searchController.text.isNotEmpty) {
      _closeSearch();
      return false;
    }
    return true;
  }

  Widget _widgetLoading() {
    return _isLoading ? Positioned.fill(child: LoadingCircle()) : Container();
  }

  Widget _widgetTabJenis() {
    return _listJenisProduk.isEmpty ? Container() : TabBar(
      indicatorWeight: 2,
      indicatorColor: widget.color.withLightness(0.7).toColor(),
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.grey,
      tabs: _listJenisProduk.asMap().map((int i, JenisProduk j) {
        return MapEntry(i, GestureDetector(
          onTap: () {
            _customScrollController.animateTo(130.0 * _offsetJenisProduk[i] + 44.0 * i, duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
          },
          child: Container(height: 40.0, alignment: Alignment.center, child: Text(j.judul),),
        ));
      }).values.toList(),
    );
  }

  Widget _widgetListProdukEmpty() {
    return _isFirstLoad ? Container() : Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 24, bottom: 12), child: Icon(MdiIcons.fileDocumentBoxSearchOutline, color: Colors.grey[600], size: 100,),),
            Text("Tidak ada produk yang sesuai", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _widgetListProduk() {
    return _listProdukFiltered.isEmpty ? _widgetListProdukEmpty() : _createListProduk();
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    KategoriProduk katalog = widget.item;

    /* Widget searchBar = TextField(
      controller: _searchController,
      decoration: InputDecoration(hintText: "Cari produk", prefixIcon: Icon(Icons.search), border: InputBorder.none),
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchTextChanged,
    ); */
    Widget searchBar = SearchBar(
      placeholder: "Cari produk",
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: _onSearchTextChanged,
    );

    Widget image = Image.network(
      katalog.gambar,
      width: h.screenSize().width,
      height: h.screenSize().height,
      fit: BoxFit.cover,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
        child: Scaffold(
          key: key,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: widget.color.withLightness(0.85).toColor(),
            titleSpacing: 0.0,
            title: AnimatedBuilder(
              animation: _searchAnimationController,
              builder: (BuildContext context, Widget child) {
                return Row(children: <Widget>[
                  InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                      child: Row(children: <Widget>[
                        Icon(Icons.chevron_left, color: Colors.black87,),
                        _searchBarVisible ? Container() : SizedBox(width: 8,),
                        _searchBarVisible ? Container() : Text(katalog.judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                    ),
                  ),
                  _searchBarVisible ? SizedBox(width: (-1 * _searchAnimation.value + 1) * 150,) : SizedBox(),
                  Expanded(
                    child: _searchBarVisible ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                        color: Colors.white,
                        border: Border.all(
                          color: widget.color.toColor(),
                          width: 1.0,
                        ),
                      ),
                      child: Stack(children: <Widget>[
                        Opacity(opacity: _searchAnimation.value, child: searchBar,),
                        Align(alignment: Alignment.centerRight, child: Opacity(
                          opacity: _searchAnimation.value,
                          child: IconButton(
                            icon: Icon(MdiIcons.closeCircle, size: 20, color: Colors.grey,),
                            onPressed: () => _closeSearch(),
                          ),
                        ),)
                      ],),
                    ) : Container(),
                  ),
                  _searchBarVisible ? Container() : IconButton(
                    color: Colors.black87,
                    icon: Icon(Icons.search),
                    tooltip: "Cari",
                    onPressed: () {
                      if (_isFirstLoad) return;
                      print("PANGGIL SETSTATE = _searchBarVisible");
                      setState(() => _searchBarVisible = true);
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                      _searchFocusNode.requestFocus();
                      _searchAnimationController.reset();
                      _searchAnimationController.forward();
                    },
                  ),
                ],);
              }
            ),
            bottom: PreferredSize(
              preferredSize: Size(h.screenSize().width, 40.0),
              child: Material(
                child: Container(width: h.screenSize().width, child: _widgetTabJenis(),),
                color: Colors.white,
              ),
            ),
          ),
          body: Stack(children: <Widget>[
            image,
            Positioned.fill(child: Material(color: Colors.white.withOpacity(0.6),)),
            Positioned.fill(child: Particles(30)),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return SafeArea(
                  child: _widgetListProduk(),
                );
              }
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _opacity,
                  child: Hero(
                    tag: "KategoriProduk${katalog.id}",
                    transitionOnUserGestures: true,
                    child: image,
                  ),
                ),
              ),
            ),
            _widgetLoading(),
          ]
        ),
      ),
    );
  }
}