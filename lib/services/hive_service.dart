import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // reference box
  final _myBox = Hive.box('mybox');

  // write data
  Future<void> writeData(String token) async {
    _myBox.put('token', token);
    print('token saved: ${token}');
  }

  // write data
  Future<String?> readData() async {
    return _myBox.get('token');
  }

}
