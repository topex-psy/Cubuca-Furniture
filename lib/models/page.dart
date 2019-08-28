import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PageApi {
  PageApi({this.judul, this.konten});
  final String judul;
  final String konten;

    factory PageApi.fromJson(Map<String, dynamic> res) {
    return PageApi(
      judul: res['JUDUL'],
      konten: res['KONTEN'],
    );
  }
}

Future<PageApi> getPage(String page) async {
  final http.Response response = await http.get(
    Uri.encodeFull(APP_HOST + "api/get/page/$page"),
    headers: {"Accept": "application/json"}
  );
  final responseJson = json.decode(response.body)['result'];
  return PageApi.fromJson(responseJson);
}