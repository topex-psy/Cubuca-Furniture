const APP_NAME = "Cubuca";
const APP_TAGLINE = "Furniture & Perabot";

//TODO pake url web kalo udah dihosting
//const APP_HOST = "http://10.0.2.2:8000/cubuca/public/"; //android emulator
const APP_HOST = "http://192.168.1.71/cubuca/public/"; //ip4 wifi

class MenuPojok {
  static const String rate = "Beri Rating";
  static const String about = "Tentang Kami";
  static const String help = "Bantuan";
  static const String career = "Jadi Mitra";
  static const List<String> listMenu = [rate, "", about, help, career];
}

class Kontak {
  static String nama = "Cubuca";
  static String slogan = "Furniture yang tepat untukmu.";
  static String deskripsi = "Melayani pengiriman ke seluruh kota di Jawa Timur dan Bali.";
  static String alamat = "Jl. Piranha no. 27";
  static String email = "cubuca@yahoo.com";
  static String noHP = "085954479381";
  static String noWA = "085954479382";
  static double lat = -7.935791;
  static double lng = 112.643415;
}

class Sosmed {
  static const int custom = 0;
  static const int facebook = 1;
  static const int twitter = 2;
  static const int whatsapp = 3;
}