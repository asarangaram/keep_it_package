void main() async {
  /*
  final server =
      await const CLServer(name: 'udesktop.local', port: 5000).withId;
   print(server);
  if (server != null) {
    final String? collectionsPrev;
    final collectionStore = File('data.json');
    if (collectionStore.existsSync()) {
      collectionsPrev = collectionStore.readAsStringSync();
    } else {
      collectionsPrev = null;
    }
    final collections = await server.getEndpoint('/collection');
    //print(collections);
    //print(collectionsPrev);
    if (collectionsPrev != null) {
      final differ = JsonDiffer(collectionsPrev, collections);
      DiffNode diff = differ.diff();
      print(diff.added);
      print(diff.removed);
      print(diff.changed);
      print(diff.moved);
      for (final n in diff.node.entries) {
        print(n.value.added);
        print(n.value.removed);
        print(n.value.changed);
        print(n.value.moved);
      }
    }

    {
      var file = File('data.json');
      await file.writeAsString(collections);
    }
  } */
}


/*
import 'package:json_diff/json_diff.dart';

void main() {
  var json1 = {
    "name": "John",
    "age": 30,
    "city": "New York"
  };
  
  var json2 = {
    "name": "John",
    "age": 31,
    "city": "New York"
  };

  var diff = JsonDiff.diff(json1, json2);
  print(diff);
}
*/
