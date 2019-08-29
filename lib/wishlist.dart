import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/produk.dart';
import 'widgets/widgets.dart';
import 'utils/utils.dart';
import 'detail_produk.dart';

class Wishlist extends StatefulWidget {
  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  FocusNode _searchFocusNode;
  TextEditingController _searchController;
  bool _searchBarVisible;
  bool _isLoaded = false;

  List<String> _myWishlist = [];
  List<Produk> _listWishlist = [];
  List<Produk> _listWishlistFiltered = [];

  final key = GlobalKey<ScaffoldState>();

  Future<dynamic> _getMyWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myWishlist = prefs.getStringList('myWishlist') ?? [];
    _getListWishlist();
  }

  Future<dynamic> _getListWishlist() async {
    return getListWishlist(_myWishlist.join(",")).then((responseJson) {
      print("DATA WISHLIST RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        print("DATA WISHLIST EXCEPTION NULL!");
        setState(() {
          _listWishlist = [];
          _listWishlistFiltered = [];
        });
        h.showAlert("Gagal Memuat", Text("Harap periksa koneksi internet Anda!"), customButton: FlatButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("Kembali"),
        ));
      } else {
        var result = responseJson["result"];
        List<Produk> listWishlist = [];
        for (Map res in result) { listWishlist.add(Produk.fromJson(res)); }
        setState(() {
          _listWishlist = listWishlist;
          _listWishlistFiltered = listWishlist;
        });
        print("DATA WISHLIST BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA WISHLIST ERROOOOOOOOOOOOR: $e");
      setState(() {
        _listWishlist = [];
        _listWishlistFiltered = [];
      });
    }).whenComplete(() {
      print("DATA WISHLIST DONEEEEEEEEEEEEE!");
      setState(() {
        _isLoaded = true;
      });
    });
  }

  Future<dynamic> _delMyWishlist(Produk item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myWishlist = _myWishlist;
    myWishlist.remove(item.id.toString());
    await prefs.setStringList('myWishlist', myWishlist);
    print("PANGGIL SETSTATE = _myWishlist");
    _myWishlist = myWishlist;
    setState(() {
      _isLoaded = false;
    });
    _getListWishlist();
    key.currentState.hideCurrentSnackBar();
    key.currentState.showSnackBar(
      SnackBar(
        content: Text("${item.judul} telah dihapus dari favorit!"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSearchTextChanged(String keyword) async {
    if (keyword == null || keyword.isEmpty) {
      print("SEARCH KEYWORD EMPTY");
      setState(() => _listWishlist = []);
      _getListWishlist();
      return;
    }

    print("SEARCH KEYWORD: \"$keyword\" (_listWishlist.length = ${_listWishlist.length})");
    keyword = keyword.toLowerCase();
    List<Produk> _listWishlistFound = [];
    List<Produk> _listWishlistAll = [];
    _listWishlistAll.addAll(_listWishlist);
    _listWishlist.forEach((Produk produk) {
      if (h.searchDo([produk.judul, produk.deskripsi, produk.sku], keyword)) {
        _listWishlistFound.add(produk);
      }
    });

    setState(() {
      _listWishlistFiltered = _listWishlistFound;
      _listWishlist = _listWishlistAll;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
    _searchBarVisible = false;
    _getMyWishlist();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);
    Widget searchBar = TextField(
      controller: _searchController,
      decoration: InputDecoration(hintText: "Cari wishlist", prefixIcon: Icon(Icons.search)),
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchTextChanged,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: key,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HSLColor.fromColor(Colors.red).withLightness(0.85).toColor(),
          titleSpacing: 0.0,
          title: Row(children: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(true),
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                child: Row(children: <Widget>[
                  Icon(Icons.chevron_left, color: Colors.black87,),
                  _searchBarVisible ? Container() : SizedBox(width: 8,),
                  _searchBarVisible ? Container() : Text("Wishlist", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                ],),
              ),
            ),
            Expanded(
              child: _searchBarVisible ? Stack(children: <Widget>[
                searchBar,
                Align(alignment: Alignment.centerRight, child: IconButton(
                  onPressed: () {
                    if (_listWishlist.isEmpty) return;
                    setState(() {
                      _searchBarVisible = !_searchBarVisible;
                      _listWishlist = [];
                    });
                    _searchController.text = "";
                    _getListWishlist();
                  },
                  icon: Icon(Icons.close, size: 16,),
                ),)
              ],) : Container(),
            ),
            _searchBarVisible ? Container() : IconButton(
              color: Colors.black87,
              icon: Icon(Icons.search),
              tooltip: "Cari",
              onPressed: () {
                if (_listWishlist.isEmpty) return;
                setState(() {
                  _searchBarVisible = !_searchBarVisible;
                });
                FocusScope.of(context).requestFocus(_searchFocusNode);
              },
            ),
          ],),
        ),
        body: SafeArea(
          child: Stack(children: <Widget>[
            Container(
              child: _listWishlistFiltered.isNotEmpty ? GridView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _listWishlistFiltered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  Produk item = _listWishlistFiltered[index];
                  return Card(
                      margin: EdgeInsets.all(10),
                      clipBehavior: Clip.antiAlias,
                      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      elevation: 8.0,
                      child: Stack( children: <Widget>[
                        Positioned.fill(child: GestureDetector(
                          child: Hero(
                            tag: "Produk${item.id}",
                            transitionOnUserGestures: true,
                            child: ClipRRect(borderRadius: BorderRadius.circular(15), child:
                              CachedNetworkImage(
                                imageUrl: Uri.encodeFull(item.thumbnail),
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
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProduk(item: item, color: HSLColor.fromColor(Colors.red),)));
                          },
                        ),),
                        Positioned(bottom: 0, left: 0, right: 0, child: Container(
                          color: Colors.black26,
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Text(item.judul, style: TextStyle(color: Colors.white, height: 1.1),),
                        ),),
                        Positioned(top: 4, right: 4, child: IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red,),
                          onPressed: () {
                            h.showConfirm(judul: "Hapus Wishlist", pesan: "Apakah Anda yakin ingin menghapus \"${item.judul}\" dari wishlist?", aksi: () => _delMyWishlist(item));
                          },
                        ),),
                      ],),
                    );
                }
              ) : Center(child: _isLoaded ? EmptyContent(teks: "Daftar favorit Anda kosong!", icon: Icons.favorite,) : SizedBox(),),
            ),
            Positioned.fill(child: _isLoaded ? SizedBox() : Center(child: LoadingCircle(),),),
          ],),
        ),
      ),
    );
  }
}