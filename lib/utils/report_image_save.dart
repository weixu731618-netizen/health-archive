// 条件导入封装：平台相关地把报告原图字节落盘。
export 'report_image_save_io.dart'
    if (dart.library.js_interop) 'report_image_save_web.dart';
