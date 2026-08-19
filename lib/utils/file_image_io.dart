import 'dart:io';

import 'package:flutter/material.dart';

/// 按本地文件路径显示图片（Android/iOS/桌面等支持文件系统的平台）。
Widget buildLocalFileImage(String path,
    {double? height, BoxFit fit = BoxFit.contain}) {
  return Image.file(
    File(path),
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => const _Fallback(),
  );
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
