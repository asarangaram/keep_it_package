import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class RestApi {
  RestApi(this._server, {this.connectViaMobile = true, this.client});
  final String _server;
  final bool connectViaMobile;
  final http.Client? client;

  static const uploadimageTimeout = 15;

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /*  dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: REST API Service',
    ); */
  }

  Uri _generateURI(String endPoint) {
    return Uri.parse('$_server$endPoint');
  }

  http.Client get myClient => client ?? http.Client();

  Future<int?> getURLStatus() async {
    //await Future.delayed(const Duration(seconds: 2));
    log('ping server $_server');
    final response = await myClient
        .get(Uri.parse(_server))
        .timeout(const Duration(seconds: 5));
    try {
      if (response.statusCode == 200) {
        final info = jsonDecode(response.body) as Map<String, dynamic>;
        if ((info['name'] as String) == 'colan_server') {
          return info['id'] as int;
        }
        log("Error: ${info['name']}");
        throw Exception(info['name']);
      } else {
        log('Error: ${response.statusCode} ${response.body}');
        throw Exception('${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> call(
    String method,
    String endPoint, {
    String? auth,
    String json = '',
    String? fileName,
    Uint8List? imageData,
    String? langStr,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? form,
  }) async {
    if (form != null && json.isNotEmpty) {
      throw Exception("can't use form and json together");
    }
    final headers = <String, String>{};
    if (method == 'get') {
      headers['Content-Type'] = 'application/json';
    } else if (form != null) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else {
      headers['Content-Type'] = 'application/json';
    }

    if (auth != null) {
      headers['Authorization'] = 'Bearer $auth';
    }
    if (extraHeaders != null) {
      for (final hdrEntry in extraHeaders.entries) {
        headers[hdrEntry.key] = hdrEntry.value;
      }
    }

    final uri = _generateURI(endPoint);

    http.Response? response;
    switch (method) {
      case 'post':
        if (form != null) {
          response = await myClient.post(uri, headers: headers, body: form);
        } else {
          response = await myClient.post(uri, headers: headers, body: json);
        }
      case 'put':
        if (form != null) {
          response = await myClient.put(uri, headers: headers, body: form);
        } else {
          response = await myClient.put(uri, headers: headers, body: json);
        }
      case 'get':
        response = await myClient.get(uri, headers: headers);
      case 'delete':
        response = await myClient.delete(uri, headers: headers);
      case 'download':
        try {
          if (fileName == null) {
            throw Exception('target filename must be provided for download');
          }
          response = await http.get(uri, headers: headers);
          if (response.statusCode == 200) {
            final file = File(fileName);
            await file.writeAsBytes(response.bodyBytes);
            return null;
          } else {
            return response.body;
          }
        } on Exception catch (e) {
          return e.toString();
        }

      /* case 'img_upload':
        if (imageData == null) {
          throw Exception('Image not provider');
        }
        try {
          final uploadUIR = Uri.parse(
            "$_server$endPoint${langStr == null ? "" : "?lang=$langStr"}",
          );

          final request = http.MultipartRequest('POST', uploadUIR);
          request.fields['filename'] = 'TODO';

          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              imageData,
              filename: 'image',
            ),
          );
          final streamedResponse = await request
              .send()
              .then((value) => value.stream.toBytes())
              .timeout(
                const Duration(
                  seconds: uploadimageTimeout,
                ),
                onTimeout: () => throw Exception('Connection timedout'),
              );
          // TODO(anandas): Error handling here...
          final decoded = utf8.decode(streamedResponse);
          return decoded;
        } on Exception catch (e) {
          throw Exception(e);
        }

      case 'audio':
        response = await myClient.post(uri, headers: headers, body: bodyJSON);

        //assert(response.bodyBytes.runtimeType == Uint8List);
        //print("Returning Result");
        return response.bodyBytes; */
    }

    if (response != null) {
      if ([200, 201].contains(response.statusCode)) {
        return response.body;
      }
      throw Exception(
        'http error: code: ${response.statusCode}, ${response.body}',
      );
    }
    throw Exception(
      'Unknown http method $method expected get, post, put or delete',
    );
  }

  Future<String> post(
    String endPoint, {
    String? auth,
    String json = '',
    Map<String, dynamic>? form,
  }) async {
    if (form != null) {
      return (await call('post', endPoint, auth: auth, form: form)) as String;
    } else {
      return (await call('post', endPoint, auth: auth, json: json)) as String;
    }
  }

  Future<String> put(
    String endPoint, {
    String? auth,
    String json = '',
    Map<String, dynamic>? form,
  }) async {
    if (form != null) {
      return (await call('put', endPoint, auth: auth, form: form)) as String;
    } else {
      return (await call('put', endPoint, auth: auth, json: json)) as String;
    }
  }

  Future<String> get(String endPoint, {String? auth}) async {
    return (await call('get', endPoint, auth: auth)) as String;
  }

  Future<String> delete(String endPoint, {String? auth}) async {
    return (await call('delete', endPoint, auth: auth)) as String;
  }

  Future<String?> upload(
    String endPoint,
    String fileName, {
    String? auth,
    Map<String, String>? fields,
  }) async {
    throw UnimplementedError();
  }

  Future<String?> download(
    String endPoint,
    String fileName, {
    String? auth,
    String bodyJSON = '',
  }) async =>
      await call('download', endPoint, auth: auth, fileName: fileName)
          as String?;

  Future<Uint8List> audio(
    String endPoint, {
    String? auth,
    String json = '',
  }) async {
    return (await call(
      'audio',
      endPoint,
      extraHeaders: {'Accept': 'Application/octet-stream'},
      json: json,
      auth: auth,
    )) as Uint8List;
  }

  Future<String> uploadimage({
    required Uint8List imageData,
    required String lang1,
    String? auth,
    String? lang2,
  }) async {
    return ''; // TODO(anandas): Fix this
    /* lang1 = langCodeConversion[lang1] ?? "eng";
    if (lang2 != null) {
      lang2 = langCodeConversion[lang2] ?? "eng";
    }

    final langStr = "$lang1${(lang2 == null) ? "" : ",$lang2"}";

    final xml = await call('img_upload', '/upload/image',
        imageData: imageData, langStr: langStr);
    try {
      return uploadimageValidateServerResponseXML(xml);
    } on Exception catch (e) {
      final error = e.toString().replaceAll("Exception:", "").trim();
      throw Exception(
          "error: \"$error\", image of size: ${imageData.length}, lang(s): $langStr");
    } */
  }
}
