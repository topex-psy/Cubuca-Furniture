import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:transparent_image/transparent_image.dart';
import 'widgets/buttons.dart';
import 'widgets/progress.dart';
import 'models/promo.dart';

class Promo extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<Promo> {
  FocusNode _searchFocusNode;
  TextEditingController _searchController;
  bool _searchBarVisible;

  List<PromoApi> _listPromo = [];
  List<PromoApi> _listPromoFiltered = [];

  Future<dynamic> _getListPromo() {
    return getListPromo().then((responseJson) {
      print("DATA PROMO RESPONSE:" + responseJson.toString());
      var result = responseJson["result"];
      List<PromoApi> listPromo = [];
      for (Map res in result) { listPromo.add(PromoApi.fromJson(res)); }
      setState(() {
        _listPromo = listPromo;
        _listPromoFiltered = listPromo;
      });
      print("DATA PROMO BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA PROMO ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PROMO DONEEEEEEEEEEEEE!");
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
    _searchBarVisible = false;
    _getListPromo();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchTextChanged(String keyword) async {
    if (keyword == null || keyword.isEmpty) {
      print("SEARCH KEYWORD EMPTY");
      setState(() => _listPromo = []);
      _getListPromo();
      return;
    }

    print("SEARCH KEYWORD: \"$keyword\" (_listProduk.length = ${_listPromo.length})");
    keyword = keyword.toLowerCase();
    List<PromoApi> _listPromoFound = [];
    List<PromoApi> _listPromoAll = [];
    _listPromoAll.addAll(_listPromo);
    _listPromo.forEach((PromoApi promo) {
      if (promo.judul.toLowerCase().contains(keyword)) { //TODO deskripsi, dll
        _listPromoFound.add(promo);
      }
    });

    setState(() {
      _listPromoFiltered = _listPromoFound;
      _listPromo = _listPromoAll;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar = TextField(
      controller: _searchController,
      decoration: InputDecoration(hintText: "Cari promo", prefixIcon: Icon(Icons.search)),
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchTextChanged,
    );

    final key = new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //backgroundColor: Theme.of(context).accentColor,
        backgroundColor: HSLColor.fromColor(Colors.green).withLightness(0.85).toColor(),
        titleSpacing: 0.0,
        title: Row(children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
              child: Row(children: <Widget>[
                Icon(Icons.chevron_left, color: Colors.black87,),
                _searchBarVisible ? Container() : SizedBox(width: 8,),
                _searchBarVisible ? Container() : Text("Promo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ],),
            ),
          ),
          Expanded(
            child: _searchBarVisible ? Stack(children: <Widget>[
              searchBar,
              Align(alignment: Alignment.centerRight, child: IconButton(
                onPressed: () {
                  if (_listPromo.isEmpty) return;
                  setState(() {
                    _searchBarVisible = !_searchBarVisible;
                  });
                  setState(() => _listPromo = []);
                  _searchController.text = "";
                  _getListPromo();
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
              if (_listPromo.isEmpty) return;
              setState(() {
                _searchBarVisible = !_searchBarVisible;
              });
              FocusScope.of(context).requestFocus(_searchFocusNode);
            },
          ),
        ],),
      ),
      body: SafeArea(
        child: _listPromo.isEmpty ? Center(child: LoadingCircle(),) : (_listPromoFiltered.isEmpty ? Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 24, bottom: 12), child: Icon(Icons.face, color: Colors.grey[600], size: 100,),),
              Text("Tidak ada promo untuk saat ini", style: new TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ],
          )
        ) : ListView.builder(
          padding: EdgeInsets.only(bottom: 40),
          itemCount: _listPromoFiltered.length,
          itemBuilder: (context, index) {
            PromoApi item = _listPromoFiltered[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              elevation: 5,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                children: <Widget>[
                  FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: item.gambar, fit: BoxFit.cover,),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${item.judul}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        SizedBox(height: 8,),
                        Html(
                          data: item.penawaran,
                          onLinkTap: (url) {
                            print("Opening $url...");
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.blue.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                      Row(children: <Widget>[
                        Icon(Icons.local_offer),
                        SizedBox(width: 4,),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Catamaran",
                              height: 0.75,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: 'Kode: '),
                              TextSpan(text: item.kodePromo, style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],),
                      UiButton(color: Colors.blue, icon: Icons.filter_none, teks: "Salin Kode", aksi: () {
                        Clipboard.setData(ClipboardData(text: item.kodePromo));
                        key.currentState.showSnackBar(
                          SnackBar(content: Text("Kode telah disalin!"),)
                        );
                      },),
                    ],),
                  ),
                ],
              ),
            );
          },
        )),
      ),
    );
  }
}