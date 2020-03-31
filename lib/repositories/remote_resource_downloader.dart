import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';



abstract class IRemoteResourcesDownloader {

  Future<Map<String, String>> downloadResources();
  Future<String> get storageDirectory;
}




class FirebaseResourceDownloader  implements IRemoteResourcesDownloader {

  final _storage = FirebaseStorage.instance.ref();
  var dio = Dio();
  final Logger logger;

  FirebaseResourceDownloader(this.logger);


  @override
  Future<Map<String, String>> downloadResources() async {
    final filesOnTheUserDevice = Map<String, String>();
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
      try {
        filesOnTheUserDevice.addAll(await _unzip(localPath));
      } catch (e) {} 
    }
    return filesOnTheUserDevice;

    // return await _storage.ref().child("resources/$filename").getDownloadURL();
  }

  Future<Map<String, String>> _unzip(String path) async {
    final files = Map<String, String>();

    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final storageDestination = await storageDirectory;

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        try {
          var path = "$storageDestination/$filename";
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          files[filename] = path;
        } catch (_) { }
      }
    }
    return files;
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