import 'package:colan_cmdline/colan_cmdline.dart';
import 'package:logger/logger.dart';

Logger logger = Logger(
  filter: MyFilter(),
  printer: PrettyPrinter(methodCount: 0, noBoxingByDefault: true),
);

Logger loggerBox = Logger(
  filter: MyFilter(),
  printer: PrettyPrinter(methodCount: 0),
);

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

Future<int> main() async {
  loggerBox.i('Commandline tool');

  final server =
      await const CLServer(name: 'udesktop.local', port: 5000).withId;
  if (server == null || server.id == null) {
    _infoLogger('Server not found');
    return -1;
  }
  _infoLogger('Server found: id: ${server.id}');
  // ignore: unused_local_variable
  /* final cachedServer = await CachedServer.create(
    name: server.name,
    port: server.port,
    id: server.id!,
    isOnline: await server.hasConnection,
    cacheDir: './test_db',
    onReload: () {},
  ); */

  return 0;
}

/*


/*
  
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

const _filePrefix = 'cmdline_tool: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
