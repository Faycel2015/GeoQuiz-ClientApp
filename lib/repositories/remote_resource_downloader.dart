import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';



abstract class IRemoteResourceHandler {

  Future downloadResources();
  Future<String> get storageDirectory;
}



class FirebaseResourceDownloader  implements IRemoteResourceHandler {

  final _storage = FirebaseStorage.instance.ref();
  var dio = Dio();


  @override
  Future downloadResources() async {
    final tmpDir = await _tmpDirectory;
    final resourceFiles = await _storage.child("resources").listAll();
    final resourcesFileIterable = resourceFiles["items"].values;
    for (var zipFile in resourcesFileIterable) {
      final path = zipFile["path"];
      final name = zipFile["name"];
      final localPath = "$tmpDir/$name";
      final ref = _storage.child(path);
      final url = await ref.getDownloadURL();
      await dio.download(url, localPath);
      _unzip(localPath);
    }

    // return await _storage.ref().child("resources/$filename").getDownloadURL();
  }

  _unzip(String path) async {
    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final storageDestination = await storageDirectory;

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File("$storageDestination/$filename")
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }  
  }

  Future<String> get storageDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/resources";
  }

  Future<String> get _tmpDirectory async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

}