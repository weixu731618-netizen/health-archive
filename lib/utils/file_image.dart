// 条件导入封装：在支持文件系统的平台用 Image.file 显示本地图片；
// 在 Web 等无法读取本地文件路径的平台显示占位。
export 'file_image_io.dart'
    if (dart.library.js_interop) 'file_image_web.dart';
