import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PromoApi {
  PromoApi({this.id, this.judul, this.deskripsi, this.gambar, this.penawaran, this.kodePromo});
  final int id;
  final String judul;
  final String deskripsi;
  final String gambar;
  final String penawaran;
  final String kodePromo;

  factory PromoApi.fromJson(Map<String, dynamic> res) {
    return res == null ? PromoApi() : PromoApi(
      id: int.parse(res['ID']),
      judul: res['NAMA'],
      deskripsi: res['DESKRIPSI'],
      gambar: res['GAMBAR'],
      penawaran: res['PENAWARAN'],
      kodePromo: res['KODE_PROMO'],
    );
  }
}

Future<dynamic> getListPromo({keyword = ""}) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/promo?keyword=$keyword"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<PromoApi> getPromo({int id}) async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/promo?id=$id"),
    headers: {"Accept": "application/json"}
  );
  final responseJson = json.decode(response.body)['result'];
  return PromoApi.fromJson(responseJson);
}

Future<PromoApi> getPromoTerbaru() async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/promo?id=terbaru"),
    headers: {"Accept": "application/json"}
  );
  final responseJson = json.decode(response.body)['result'];
  return PromoApi.fromJson(responseJson);
}