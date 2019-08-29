import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:transparent_image/transparent_image.dart';
import 'models/produk.dart';
import 'widgets/slivers.dart';
import 'utils/utils.dart';

class DetailProduk extends StatefulWidget {
  DetailProduk({Key key, @required this.item, this.color}) : super(key: key);
  final Produk item;
  final HSLColor color;

  @override
  _DetailProdukState createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    String judul = h.maxlength(widget.item.judul, 15);

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: widget.color.withLightness(0.85).toColor(),
                  expandedHeight: 200.0,
                  floating: true,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    title: Text(judul, style: TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      height: 1.0,
                    )),
                    background: Stack(children: <Widget>[
                      Positioned.fill(child: Hero(
                        tag: "Produk${widget.item.id}",
                        child: GestureDetector(
                          onTap: () {
                            //TODO slideshow galeri
                            print("GAMBARNYA = ${Uri.encodeFull(widget.item.gambar)}");
                          },
                          child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: Uri.encodeFull(widget.item.gambar), fit: BoxFit.cover,),
                        ),
                      ),),
                      Positioned.fill(child: IgnorePointer(child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              Colors.white.withOpacity(1.0),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: [
                              0.0,
                              0.65,
                            ]
                          ),
                        ),
                      ),),)
                    ],),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      indicatorWeight: 2,
                      indicatorColor: Colors.lightBlue,
                      controller: _tabController,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: "Detail"),
                        Tab(text: "Galeri"),
                        Tab(text: "Testimoni"),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Container(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text("${widget.item.judul}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      SizedBox(height: 8,),
                      Text("SKU: ${widget.item.sku}", style: TextStyle(fontSize: 14.0, color: Colors.grey[600], fontStyle: FontStyle.italic),),
                      SizedBox(height: 24,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButtonColumn(Colors.lightBlue, widget.item.isTersedia?Icons.shopping_cart:Icons.access_time, widget.item.isTersedia?'BELI':'PRE-ORDER', () => a.beliProduk(widget.item)),
                          _buildButtonColumn(Colors.lightBlue, Icons.forum, 'PERTANYAAN', h.kontakKami),
                          _buildButtonColumn(Colors.lightBlue, Icons.share, 'BAGIKAN', () => h.bagikan(widget.item.link, pesan: "Menurut saya produk ini sangat menarik!")),
                        ],
                      ),
                      SizedBox(height: 24,),
                      Html(data: widget.item.deskripsi),
                    ],),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.photo),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.forum),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonColumn(Color color, IconData icon, String label, void Function() onClick) {
    return FlatButton(
      onPressed: onClick,
      shape: CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            SizedBox(height: 8,),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      )
    );
  }
}