// 编译用入口：生成 web/drift_worker.js（drift 在 Web 上打开数据库所需的后台 Worker）。
// 编译命令：dart compile js -O4 -o web/drift_worker.js web/drift_worker.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
