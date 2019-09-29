import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'widgets/widgets.dart';
import 'models/promo.dart';
import 'utils/utils.dart';

class Promo extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<Promo> with TickerProviderStateMixin {
  FixedExtentScrollController fixedExtentScrollController;
  List<PromoApi> _listPromo = [];
  List<PromoApi> _listPromoFiltered = [];
  List<String> _listCode = [];

  Future<dynamic> _getListPromo() {
    return getListPromo().then((responseJson) {
      print("DATA PROMO RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        print("DATA PROMO EXCEPTION NULL!");
        setState(() {
          _listPromo = [];
          _listPromoFiltered = [];
        });
        h.loadFail();
      } else {
        var result = responseJson["result"];
        List<PromoApi> listPromo = [];
        for (Map res in result) { listPromo.add(PromoApi.fromJson(res)); }
        setState(() {
          _listPromo = listPromo;
          _listPromoFiltered = listPromo;
        });
        print("DATA PROMO BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA PROMO ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PROMO DONEEEEEEEEEEEEE!");
    });
  }

  @override
  void initState() {
    super.initState();
    fixedExtentScrollController = FixedExtentScrollController();
    _getMyPromoCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onSearchTextChanged(String keyword) async {
    if (keyword == null || keyword.isEmpty) {
      print("SEARCH KEYWORD EMPTY");
      setState(() => _listPromo = []);
      _getMyPromoCode();
      return;
    }

    print("SEARCH KEYWORD: \"$keyword\" (_listProduk.length = ${_listPromo.length})");
    List<PromoApi> _listPromoFound = [];
    List<PromoApi> _listPromoAll = [];
    _listPromoAll.addAll(_listPromo);
    _listPromo.forEach((PromoApi promo) {
      if (h.searchDo([promo.judul, promo.deskripsi], keyword)) {
        _listPromoFound.add(promo);
      }
    });

    setState(() {
      _listPromoFiltered = _listPromoFound;
      _listPromo = _listPromoAll;
    });
  }

  Future<dynamic> _getMyPromoCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _listCode = prefs.getStringList('myPromoCode') ?? [];
      _getListPromo();
    });
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HSLColor.fromColor(Colors.green).withLightness(0.85).toColor(),
        titleSpacing: 0.0,
        title: NavTitleBar(judul: "Promo", searchHint: "Cari promo", onSearchTextChanged: _onSearchTextChanged,),
      ),
      body: SafeArea(
        child: _listPromo.isEmpty ? Center(child: LoadingCircle(),) : (_listPromoFiltered.isEmpty ? Center(
          child: EmptyContent(teks: "Tidak ada promo untuk saat ini!", icon: Icons.local_offer,),
        ) : ListWheelScrollView(
          controller: fixedExtentScrollController,
          physics: FixedExtentScrollPhysics(),
          children: _listPromoFiltered.map((item) {
            return Card(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              elevation: 10.0,
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
                        h.html(item.penawaran),
                      ],
                    ),
                  ),
                  ScratchCode(kode: item.kodePromo, scaffoldKey: key, isCompleted: _listCode.contains(item.kodePromo)),
                ],
              ),
            );
          }).toList(),
          itemExtent: 60.0,
        )),
      ),
    );
  }
}

class ScratchCode extends StatefulWidget {
  ScratchCode({@required this.kode, @required this.scaffoldKey, this.isCompleted = false});
  final String kode;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isCompleted;

  @override
  _ScratchCodeState createState() => _ScratchCodeState();
}

class _ScratchCodeState extends State<ScratchCode> {
  double _progress = 0.0;

  Future<dynamic> _setMyPromoCode(String kode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myPromoCode = prefs.getStringList('myPromoCode') ?? [];
    if (!myPromoCode.contains(kode)) {
      myPromoCode.add(kode);
      await prefs.setStringList('myPromoCode', myPromoCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget tileContent = Container(
      color: Colors.blue.withOpacity(0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 20.0, right: 6.0),
            child: Icon(Icons.local_offer),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Catamaran",
                  height: 0.75,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: 'Kode promo: '),
                  TextSpan(text: widget.kode, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          (widget.isCompleted || _progress > 70.0) ? InkWell(
            onTap: () {
              h.salin(widget.kode, "Kode promo", widget.scaffoldKey);
            }, child: Container(
              color: Colors.black12,
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: null,
                child: Icon(Icons.filter_none, color: Colors.white,),
              ),
            )
          ) : SizedBox(),
        ],
      ),
    );

    return widget.isCompleted ? tileContent : Stack(children: <Widget>[
      Scratcher(
        accuracy: ScratchAccuracy.medium,
        brushSize: 35,
        threshold: 70,
        color: Colors.blueGrey,
        onChange: (value) {
          print("Scratch progress: $value%");
          setState(() {
            _progress = value; 
          });
        },
        onThreshold: () {
          print("Threshold reached, you won!");
          _setMyPromoCode(widget.kode);
        },
        child: tileContent,
      ),
      _progress > 0.0 ? Container() : Positioned.fill(child:
        IgnorePointer(
          child: Center(
            child: Text("Gosok untuk melihat kode promo!", style: TextStyle(color: Colors.grey[400], fontSize: 15.0, fontStyle: FontStyle.italic)),
          ),
        ),
      ),
    ],);
  }
}