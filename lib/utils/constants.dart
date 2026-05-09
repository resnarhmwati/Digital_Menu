import 'package:intl/intl.dart';

class AppConstants {
  static const String cafeId = 'xK9mN2pQrT';

  static String formatRupiah(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}