import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class KategoriProduk {
  KategoriProduk({this.id, this.judul, this.gambar, this.jumlah});
  final int id;
  final String judul;
  final String gambar;
  final int jumlah;

  factory KategoriProduk.fromJson(Map<String, dynamic> res) {
    return KategoriProduk(
      id: int.parse(res['ID']),
      judul: res['KATEGORI'],
      gambar: res['GAMBAR'],
      jumlah: int.parse(res['JUMLAH_PRODUK']),
    );
  }
}

class JenisProduk {
  JenisProduk({this.id, this.judul, this.jumlah});
  final int id;
  final String judul;
  final int jumlah;

  factory JenisProduk.fromJson(Map<String, dynamic> res) {
    return JenisProduk(
      id: int.parse(res['ID']),
      judul: res['JENIS'],
      jumlah: int.parse(res['JUMLAH_PRODUK']),
    );
  }
}

class Produk {
  Produk({this.id, this.sku, this.idKategori, this.idJenis, this.gambar, this.thumbnail, this.judul, this.kategori, this.jenis, this.deskripsi, this.ukuran, this.harga, this.linkBukaLapak, this.linkTokopedia, this.linkShopee, this.isTersedia, this.link, this.waktuPasang, this.jumlahGambar, this.listGambar, this.ketPreOrder});
  final int id;
  final String sku;
  final int idKategori;
  final int idJenis;
  final String gambar;
  final String thumbnail;
  final String judul;
  final String kategori;
  final String jenis;
  final String deskripsi;
  final String ukuran;
  final int harga;
  final String linkBukaLapak;
  final String linkTokopedia;
  final String linkShopee;
  final bool isTersedia;
  final String link;
  final String waktuPasang;
  final String jumlahGambar;
  final String listGambar;
  final String ketPreOrder;

  factory Produk.fromJson(Map<String, dynamic> res) {
    return Produk(
      id: int.parse(res['ID']),
      sku: res['SKU'],
      idKategori: int.parse(res['ID_KATEGORI']),
      idJenis: int.parse(res['ID_JENIS']),
      gambar: res['GAMBAR'],
      thumbnail: res['THUMBNAIL'],
      judul: res['NAMA'],
      kategori: res['KATEGORI'],
      jenis: res['JENIS'],
      deskripsi: res['DESKRIPSI'],
      ukuran: res['UKURAN'],
      harga: int.parse(res['HARGA']),
      linkBukaLapak: res['LINK_BUKALAPAK'],
      linkTokopedia: res['LINK_TOKOPEDIA'],
      linkShopee: res['LINK_SHOPEE'],
      isTersedia: res['IS_TERSEDIA'] == '1',
      link: res['LINK'],
      waktuPasang: res['TIMEE'],
      jumlahGambar: res['JUMLAH_GAMBAR'],
      listGambar: res['LIST_GAMBAR'],
      ketPreOrder: res['KET_PREORDER'],
    );
  }
}

Future<dynamic> getListWishlist(String ids) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/product?ids=$ids"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListKategoriProduk() async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/catalogue"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListJenisProduk({int kategori = 0, String keyword = ""}) async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/product_type?kategori=$kategori&keyword=$keyword"),
    headers: {"Accept": "application/json"}
  );
  return json.decode(response.body);
}

Future<dynamic> getListProduk({int kategori = 0, int jenis = 0, String keyword = ""}) async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/product?kategori=$kategori&jenis=$jenis&keyword=$keyword"),
    headers: {"Accept": "application/json"}
  );
  return json.decode(response.body);
}

Future<Produk> getProduk({int id}) async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/product?id=$id"),
    headers: {"Accept": "application/json"}
  );
  final responseJson = json.decode(response.body)['result'];
  return Produk.fromJson(responseJson);
}