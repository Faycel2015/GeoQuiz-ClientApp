import 'dart:io';

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
    var paths = await _storage.child("resources").listAll();
    var dir = await new Directory(await storageDirectory).create();
    var files = paths["items"] as Map;
    for (Map file in files.values) {
      var path = file["path"];
      var name = file["name"];
      var ref = _storage.child(path);
      var url = await ref.getDownloadURL();
      dio.download(url, "${dir.path}/$name");
    }
    // return await _storage.ref().child("resources/$filename").getDownloadURL();
  }

  Future<String> get storageDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/resources";
  }

}