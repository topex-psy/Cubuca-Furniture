import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_menu/star_menu.dart';
import 'package:transparent_image/transparent_image.dart';
import 'models/produk.dart';
import 'widgets/slivers.dart';
import 'widgets/widgets.dart';
import 'utils/utils.dart';

const double fabButtonHeight = 45.0;
const double fabButtonIconSize = 25.0;

class DetailProduk extends StatefulWidget {
  DetailProduk({Key key, @required this.item, this.color}) : super(key: key);
  final Produk item;
  final HSLColor color;

  @override
  _DetailProdukState createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _myWishlist = [];
  bool _isWishlist = false;
  GlobalKey fabKey1;

  final key = GlobalKey<ScaffoldState>();

  Future<dynamic> _getMyWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _myWishlist = prefs.getStringList('myWishlist') ?? [];
      _isWishlist = _myWishlist.contains(widget.item.id.toString());
    });
  }

  Future<dynamic> _setMyWishlist(int aksi, {int aksiKe = 0}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myWishlist = _myWishlist;
    Produk item = widget.item;

    //simpan wishlist
    if (aksi == 1) myWishlist.add(item.id.toString()); else myWishlist.remove(item.id.toString());
    await prefs.setStringList('myWishlist', myWishlist);
    setState(() {
      _myWishlist = myWishlist;
      _isWishlist = aksi == 1;
    });

    //tampilkan snackbar
    key.currentState.hideCurrentSnackBar();
    key.currentState.showSnackBar(
      SnackBar(content: Text("${item.judul} telah " + (aksi == 1 ? "ditambahkan ke" : "dihapus dari") + " favorit!"), behavior: SnackBarBehavior.floating, action: SnackBarAction(
        onPressed: () => _setMyWishlist(aksi == 1 ? 0 : 1, aksiKe: aksiKe + 1),
        label: aksiKe % 2 == 0 ? "Undo" : "Redo",
      ),),
    );
  }

  void _openGallery(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => GalleryPhotoViewWrapper(
        galleryItems: _listGaleri,
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        initialIndex: index,
      ),
    ));
  }

  List<GalleryItem> _listGaleri = [
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_Sofas-Couches.jpg"),
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_Accent-Chairs.jpg"),
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_TV-Media.jpg"),
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_Sofas-Couches.jpg"),
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_Accent-Chairs.jpg"),
    GalleryItem("https://images-na.ssl-images-amazon.com/images/G/01/img18/home/Harmony/Nav_Tiles/Furniture/Furniture_ASIN-Tile_TV-Media.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    WidgetsBinding.instance.addPostFrameCallback((_) { // when widget built
      _getMyWishlist().then((result) {
      }).catchError((e) {
        print("GET WISHLIST ERROOOOOOOOOOOOR: $e");
      }).whenComplete(() {
        print("GET WISHLIST DONEEEEEEEEEEEEE!");
      });
    });
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
    fabKey1 = GlobalKey(debugLabel: '_fabKey1');

    Widget galleryGrid(GalleryItem item, int indeks) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            bottom: 0,
            child: GridTile(
              child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: item.resource, fit: BoxFit.cover,),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Color(0x11BCAAA4),
                onTap: () => _openGallery(context, indeks),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      key: key,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ButtonTheme(
            height: fabButtonHeight,
            child: UiButton(
              btnKey: fabKey1,
              radius: fabButtonHeight,
              color: Colors.greenAccent[700],
              icon: Icons.shopping_cart,
              ukuranIcon: fabButtonIconSize,
              teks: widget.item.isTersedia ? 'BELI' : 'PRE-ORDER',
              //aksi: () => a.beliProduk(widget.item),
              aksi: () => StarMenuController.displayStarMenu(StarMenu(
                parentKey: fabKey1,
                shape: MenuShape.circle,
                radiusX: 100,
                radiusY: 100,
                radiusIncrement: 5,
                startAngle: 270.0,
                endAngle: 360,
                durationMs: 1000,
                itemDelayMs: 200,
                rotateItemsAnimationAngle: 270.0,
                startItemScaleAnimation: 0.2,
                columns: 1,
                columnsSpaceH: 10,
                columnsSpaceV: 10,
                backgroundColor: Colors.transparent,
                checkScreenBoundaries: true,
                useScreenCenter: false,
                centerOffset: Offset(0, -200),
                animationCurve: Curves.bounceIn,
                onItemPressed: (i) => print("PRESSED $i"),
                items: <Widget>[
                  VendorCard(logo: "images/vendor/tokopedia.png", aksi: () => h.openURL(widget.item.linkTokopedia)),
                  VendorCard(logo: "images/vendor/bukalapak.png", aksi: () => h.openURL(widget.item.linkBukaLapak)),
                  VendorCard(logo: "images/vendor/shopee.png", aksi: () => h.openURL(widget.item.linkShopee)),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => h.bagikan(url: widget.item.link, judul: widget.item.judul, body: "Menurut saya produk ini sangat menarik!"),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.share, color: Colors.blueGrey, size: 40.0,),
                      ),
                    ),
                  ),
                ],
              ), fabKey1),
            ),
          ),
          SizedBox(width: 8.0,),
          ButtonTheme(
            minWidth: fabButtonHeight,
            height: fabButtonHeight,
            child: UiButton(
              radius: fabButtonHeight,
              color: Colors.blueAccent[400],
              icon: Icons.forum,
              ukuranIcon: fabButtonIconSize,
              aksi: h.kontakKami,
            ),
          ),
          SizedBox(width: 8.0,),
          ButtonTheme(
            minWidth: fabButtonHeight,
            height: fabButtonHeight,
            child: UiButton(
              radius: fabButtonHeight,
              color: _isWishlist ? Colors.red[400] : Colors.grey,
              icon: _isWishlist ? Icons.favorite : Icons.favorite_border,
              ukuranIcon: fabButtonIconSize,
              aksi: () => _setMyWishlist(_isWishlist ? 0 : 1),
            ),
          ),
        ],
      ),
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
                    title: Text(h.maxlength(widget.item.judul, 15), style: TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      height: 1.0,
                    )),
                    background: Stack(children: <Widget>[
                      Positioned.fill(child: GestureDetector(
                          onTap: () {
                            //TODO slideshow galeri
                            print("GAMBARNYA = ${Uri.encodeFull(widget.item.gambar)}");
                          },
                          child: Hero(
                            tag: "Produk${widget.item.id}",
                            child: CachedNetworkImage(
                              imageUrl: Uri.encodeFull(widget.item.gambar),
                              placeholder: (context, url) => Container(child: Center(child: SizedBox(width: 100, height: 100, child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())))),
                              errorWidget: (context, url, error) => Container(child: Center(child: SizedBox(width: 100, height: 100, child: Icon(Icons.error, color: Colors.grey,)))),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
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
                  
                  //informasi produk
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text("${widget.item.judul}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      SizedBox(height: 8,),
                      Text("SKU: ${widget.item.sku}", style: TextStyle(fontSize: 14.0, color: Colors.grey[600], fontStyle: FontStyle.italic),),
                      SizedBox(height: 24,),
                      Html(data: widget.item.deskripsi),
                    ],),
                  ),
                  
                  //galeri produk
                  Container(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: _listGaleri.asMap().map((int i, GalleryItem item) {
                        return MapEntry(i, galleryGrid(item, i));
                      }).values.toList(),
                    ),
                  ),

                  //testimoni produk
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.forum, color: Colors.grey, size: 60.0,),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryItem {
  GalleryItem(this.resource);
  final String resource;
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.initialIndex,
      @required this.galleryItems
    }) : pageController = PageController(initialPage: initialIndex);

  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<GalleryItem> galleryItems;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.galleryItems[index].resource),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 1.1,
                  heroTag: "Galeri$index",
                );
              },
              itemCount: widget.galleryItems.length,
              loadingChild: widget.loadingChild,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "${currentIndex + 1} / ${widget.galleryItems.length}",
                style: TextStyle(color: Colors.white, fontSize: 17.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}