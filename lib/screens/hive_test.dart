import 'package:api_local_storage/services/hive_service.dart';
import 'package:flutter/material.dart';

class HiveTest extends StatefulWidget {
  const HiveTest({super.key});

  @override
  State<HiveTest> createState() => _HiveTestState();
}

class _HiveTestState extends State<HiveTest> {
  // data
  String? _data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            MaterialButton(
              onPressed: () {
               // HiveService().writeData();
              },
              color: Colors.blue[200],
              child: const Text('Write'),
            ),
            MaterialButton(
              onPressed: () async {
                var data = await HiveService().readData();
                setState(() {
                  _data = data;
                });
              },
              color: Colors.blue[200],
              child: const Text('Read'),
            ),
            const SizedBox(height: 30,),
            if(_data != null) Text('Data: $_data')
          ],
        ),
      ),
    );
  }
}
