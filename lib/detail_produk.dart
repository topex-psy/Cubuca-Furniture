import 'package:flutter/material.dart';
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
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    //centerTitle: true,
                    title: Text(widget.item.judul, style: TextStyle(
                      color: Colors.black,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                    )),
                    background: Hero(tag: "Produk${widget.item.id}", child: Image.network(
                      widget.item.gambar,
                      fit: BoxFit.cover,
                    ),),
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
                    child: Column(children: <Widget>[
                      SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButtonColumn(Colors.lightBlue, widget.item.isTersedia?Icons.shopping_cart:Icons.access_time, widget.item.isTersedia?'BELI':'PRE-ORDER', () => a.beliProduk(widget.item)),
                          _buildButtonColumn(Colors.lightBlue, Icons.forum, 'PERTANYAAN', h.kontakKami),
                          _buildButtonColumn(Colors.lightBlue, Icons.share, 'BAGIKAN', () => h.bagikan(widget.item.link, pesan: "Menurut saya produk ini sangat menarik!")),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(20), child: Text(widget.item.deskripsi),)
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
        padding: EdgeInsets.all(12),
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