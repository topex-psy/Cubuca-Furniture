import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:share/share.dart';
import '../widgets/buttons.dart';
import '../models/produk.dart';
import 'constants.dart';

MyHelper h;
MyAppHelper a;

class MyAppHelper {
  final BuildContext context;
  MyAppHelper(this.context);

  /* menuAction(String menu) {
    //TODO aksi menu pojok
    switch (menu) {
      case MenuPojok.rate: print("rateeee"); break;
      case MenuPojok.about: print("abouuut"); break;
      case MenuPojok.help: print("heeelp"); break;
      case MenuPojok.career: print("careeer"); break;
    }
  } */

  Widget vendorCard(String logo, String link) {
    double cardSize = 0.5 * h.screenSize().width / 2;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => h.openURL(link),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.asset(logo, width: cardSize, height: cardSize, fit: BoxFit.contain,),
        ),
      ),
    );
  }

  beliProduk(Produk item) {
    if (item.isTersedia) {
      print("beli produk: ${item.judul}");
      Widget isi = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        /* AnimatedBuilder(
          animation: _nudgeController,
          builder: (BuildContext context, Widget child) {
            return Transform(
              transform: Matrix4.translationValues(_nudge.value * 20.0, 0, 0),
              child: Icon(Icons.shopping_cart, size: 50, color: Colors.grey[400],),
            );
          },
        ), */
        //Icon(Icons.shopping_cart, size: 50, color: Colors.grey[400],),
        SizedBox(height: 8,),
        RichText(text: TextSpan(
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: "Catamaran",
              height: 1.2,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: 'Belanja '),
              TextSpan(text: item.judul, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' secara mudah dan aman melalui marketplace favoritmu!'),
            ],
          ),
        ),
        SizedBox(height: 12,),
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: <Widget>[
            vendorCard("images/vendor/tokopedia.png", item.linkTokopedia),
            vendorCard("images/vendor/bukalapak.png", item.linkBukaLapak),
            vendorCard("images/vendor/shopee.png", item.linkShopee),
          ],
        ),
        Divider(color: Colors.black38, height: 32.0,),
        Padding(padding: EdgeInsets.only(left: 5, right: 5, bottom: 5), child: Text("Ada pertanyaan atau permintaan khusus?", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14, height: 1.0),),),
        UiButton(color: Colors.greenAccent[700], icon: Icons.phone_in_talk, teks: "Kontak Kami", aksi: h.kontakKami,),
      ],);
      h.showAlert("Beli ${item.judul}", isi, showButton: false, showJudul: false);
    } else {
      h.kontakKami(judul: "Saya ingin memesan produk ${item.judul}");
    }
  }
}

class MyHelper {
  final BuildContext context;
  MyHelper(this.context);

  AudioCache player = AudioCache();
  Size screenSize() => MediaQuery.of(context).size;
  playSound(String sound) => player.play(sound);

  openURL(String urlString) async {
    if (urlString == null) throw 'Tidak ada tautan untuk dibuka!';
    String url = Uri.encodeFull(urlString);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  shareSosmed(int sosmed, String urlString, String pesan) {
    if (sosmed == Sosmed.custom) {
      Share.share("$pesan $urlString".trim());
    } else {
      String uri;
      switch (sosmed) {
        case Sosmed.facebook: uri = "https://www.facebook.com/sharer.php?u=$urlString"; break;
        case Sosmed.twitter: uri = "https://twitter.com/share?url=$urlString&amp;text=$pesan"; break;
        case Sosmed.whatsapp: uri = "https://wa.me/?text="+"$pesan $urlString".trim(); break;
      }
      openURL(uri);
    }
  }

  showAlert(String judul, Widget isi, {bool showButton = true, bool showJudul = true, FlatButton customButton = null}) {
    player.play("butt_press.wav");
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: showJudul ? Text(judul, style: TextStyle(fontWeight: FontWeight.bold),) : null,
              content: SingleChildScrollView(child: isi,),
              actions: showButton ? <Widget>[
                customButton == null ? FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ) : customButton,
              ] : null,
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );


    /* showDialog(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (context) => AlertDialog(
          title: Text(judul, style: TextStyle(fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(child: isi,),
          actions: showButton?<Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ]:null,
        ),
    ); */
  }

  showConfirm({String judul, String pesan, void Function() aksi, void Function() doOnCancel = null}) {
    player.play("butt_press.wav");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: judul == null ? null : Text(judul, style: TextStyle(fontWeight: FontWeight.bold),),
        content: Text(pesan),
        actions: <Widget>[
          FlatButton(child: Text("Tidak", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),), onPressed: () {
            if (doOnCancel != null) doOnCancel();
            Navigator.of(context).pop(false);
          },),
          FlatButton(child: Text("Ya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),), onPressed: aksi,),
        ],
      ),
    );
  }

  kontakKami({String judul = "", String pesan = ""}) {
    showAlert("Hubungi Kami",
      ListBody(
        children: <Widget>[
          UiButton(color: Colors.greenAccent[700], icon: MdiIcons.whatsapp, teks: "WhatsApp", aksi: () => launch("https://wa.me/${Kontak.noWA}?text=${Uri.encodeFull(pesan)}")),
          Divider(color: Colors.black38,),
          ListMenu(Icons.phone, "Telepon", () => launch("tel:${Kontak.noHP}")),
          ListMenu(Icons.message, "SMS", () => launch("sms:${Kontak.noHP}")),
          ListMenu(Icons.email, "Email", () => launch("mailto:${Kontak.email}?subject=${Uri.encodeFull(judul)}&body=${Uri.encodeFull(pesan)}")),
        ],
      ),
      showButton: false,
    );
  }

  bagikan(String urlString, {String pesan = ""}) {
    showAlert("Bagikan",
      ListBody(
        children: <Widget>[
          RaisedButton(child: Row(children: <Widget>[Icon(MdiIcons.whatsapp, color: Colors.white,), SizedBox(width: 8,), Text("WhatsApp", style: TextStyle(color: Colors.white),)],), color: Colors.lightGreen[700], onPressed: () => shareSosmed(Sosmed.whatsapp, urlString, pesan),),
          RaisedButton(child: Row(children: <Widget>[Icon(MdiIcons.facebook, color: Colors.white,), SizedBox(width: 8,), Text("Facebook", style: TextStyle(color: Colors.white),)],), color: Colors.blue[900], onPressed: () => shareSosmed(Sosmed.facebook, urlString, pesan),),
          RaisedButton(child: Row(children: <Widget>[Icon(MdiIcons.twitter, color: Colors.white,), SizedBox(width: 8,), Text("Twitter", style: TextStyle(color: Colors.white),)],), color: Colors.lightBlue[400], onPressed: () => shareSosmed(Sosmed.twitter, urlString, pesan),),
          Divider(color: Colors.black38,),
          RaisedButton(child: Row(children: <Widget>[Icon(MdiIcons.share, color: Colors.white,), SizedBox(width: 8,), Text("Lainnya", style: TextStyle(color: Colors.white),)],), color: Colors.purple, onPressed: () => shareSosmed(Sosmed.custom, urlString, pesan),),
        ],
      ),
      showButton: false,
    );
  }
}

class ListMenu extends StatelessWidget {
  ListMenu(this.icon, this.teks, this.aksi);
  final IconData icon;
  final String teks;
  final void Function() aksi;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Icon(icon),
            SizedBox(width: 8,),
            Text(teks),
          ]
        ),
      ),
      onTap: aksi,
    );
  }
}

class ListMenuDrawer extends StatelessWidget {
  ListMenuDrawer(this.icon, this.teks, this.aksi);
  final IconData icon;
  final String teks;
  final void Function() aksi;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.grey[600],),
            SizedBox(width: 10,),
            Text(teks, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),),
          ]
        ),
      ),
      onTap: aksi,
    );
  }
}