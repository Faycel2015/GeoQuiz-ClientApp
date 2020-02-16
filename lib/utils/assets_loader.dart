
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class AssetsLoader {

  static final AssetsLoader _instance = AssetsLoader._();
  factory AssetsLoader() => _instance;
  AssetsLoader._();

  Map<String, PictureInfo> _cache = {};



  Future<PictureInfo> loadSvg(AssetBundle assetBundle, String name, Color color) async {
    if (_cache.containsKey(name))
      return _cache[name];

    await Future.delayed(Duration(seconds: 2));

    final bytedata = await assetBundle.load(name);
    final buffer = bytedata.buffer;
    final bytes = buffer.asUint8List(bytedata.offsetInBytes, bytedata.lengthInBytes);
    

    final pictureInfo = await SvgPicture.svgByteDecoder(
      bytes, 
      ColorFilter.mode(color, BlendMode.srcIn), 
      name
    );
    

    _cache[name] = pictureInfo;
    return pictureInfo;
  }
}


class Test {


  Map<String, Picture> _cache = {};

  Future<Picture> loadSvg(BuildContext context, String name, Color color) async {
    if (_cache.containsKey(name)) return _cache[name];

    await Future.delayed(Duration(seconds: 2));

    // final assetBundle = DefaultAssetBundle.of(context);
    // final bytedata = await assetBundle.load(name);

    // final buffer = bytedata.buffer;
    // final bytes =
    //     buffer.asUint8List(bytedata.offsetInBytes, bytedata.lengthInBytes);

    // final pictureInfo = await SvgPicture.svgByteDecoder(
    //     bytes, ColorFilter.mode(color, BlendMode.srcIn), name);

    Completer completer = Completer<Picture>();
    var provider = ExactAssetPicture(
      SvgPicture.svgStringDecoder, 
      name,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn)
    );

    var stream = provider.resolve(createLocalPictureConfiguration(context));
    stream.addListener((image, synchronousCall) {
      print("");
    });

    // _cache[name] = pictureInfo.picture;
    // return pictureInfo.picture;
    return null;
  }
}

