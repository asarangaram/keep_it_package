import 'dart:developer';

import 'package:online_store/online_store.dart';
import 'package:store/store.dart';

void main() async {
  final url =
      StoreURL(Uri.parse('http://127.0.0.1:5001'), identity: null, label: null);

  final server = await CLServer(storeURL: url).withId();

  final response = await server.post('/entity', fileName: null, form: {
    'isCollection': '1',
    'label': 'TestCollection',
    'description': 'test description',
  });
  log(response);

  final response2 = await server.post('/entity',
      fileName: 'assets/0e71e306fdd2435c494afa5f6ccd1e60.jpg',
      form: {
        'isCollection': '0',
        'label': 'TestMedia',
        'description': 'test description',
      });
  log(response2);
}
