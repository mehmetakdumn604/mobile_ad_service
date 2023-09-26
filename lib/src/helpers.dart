import 'dart:io';
import 'dart:math';

import 'package:andesgroup_common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:validators/validators.dart';

enum MediaType {
  network,
  asset,
  file,
}

void debug(dynamic message, {dynamic error, StackTrace? stackTrace,bool enableLog = true}) {
  if (isTesting == false && enableLog) {
    logger.d(message, error, stackTrace);
  }
}

MediaType getMediaType(String? mediaSrc) {
  if (isURL(mediaSrc, allowUnderscore: true)) {
    return MediaType.network;
  } else if (mediaSrc!.startsWith('assets')) {
    return MediaType.asset;
  } else {
    try {
      final uri = Uri.file(mediaSrc, windows: Platform.isWindows);
      if (uri.hasAbsolutePath) {
        return MediaType.file;
      }
      throw Exception('Invalid Media Type');
    } catch (e) {
      throw Exception('Invalid Media Type');
    }
  }
}

T getRandomElement<T>(List<T> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

/// random int from [start,end]
int getRandomRange(int start, int end) {
  return start + Random().nextInt(end - start + 1);
}

///////PARSER////////////
List<T?>? parseList<T extends Object?>({
  required List<dynamic>? json,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  return (json)?.map((e) => e == null ? null : fromJson(e as Map<String, dynamic>)).toList();
}

List<T> parseListNotNull<T extends Object?>({
  required List<dynamic> json,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  return (json).map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

Map<String, T?> parseMap<T extends Object?>({
  required Map<String, dynamic> json,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  return json.map((k, e) => MapEntry(k, e == null ? null : fromJson(e as Map<String, dynamic>)));
}

Map<String, T> parseMapNotNull<T extends Object?>({
  required Map<String, dynamic> json,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  return json.map((k, e) => MapEntry(k, fromJson(e as Map<String, dynamic>)));
}
////////////////////////

String? getNameFromEmail(String? email) {
  if (email == null) {
    return null;
  }
  if (email.contains('@')) {
    return email.split('@')[0];
  }
  return null;
}

Future<bool?> toast(
  String value, {
  Color? backgroundColor,
  Color? textColor,
  double? fontSize = 16,
}) {
  return Fluttertoast.showToast(
      msg: value,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize);
}

Future<void> copyToClipboard(String value) {
  return Clipboard.setData(ClipboardData(text: value));
}

void showSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  int milliseconds = 4000,
  SnackBarAction? action,
  Function? onClosed,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(milliseconds: milliseconds),
        action: action,
      ),
    ).closed.then((value) => onClosed?.call());
}

final inputNumber = [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
