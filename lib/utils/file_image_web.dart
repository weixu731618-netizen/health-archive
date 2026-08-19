import 'package:flutter/material.dart';

/// Web 平台：本地文件路径不可读，返回空占位（请在数据库回退显示占位文案）。
Widget buildLocalFileImage(String path,
    {double? height, BoxFit fit = BoxFit.contain}) {
  return const SizedBox();
}
