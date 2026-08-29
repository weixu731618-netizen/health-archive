// A3：PDF 报告导入的纯逻辑测试。
// renderPdfFirstPageToPng 依赖 pdfx 的平台绑定（pdfium），headless 单元测试跑不了，
// 只在这里测文件名判断；真机渲染在设备验收时确认。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/utils/pdf_support.dart';

void main() {
  test('isPdfFileName：大小写不敏感、忽略首尾空白', () {
    expect(isPdfFileName('体检报告.pdf'), isTrue);
    expect(isPdfFileName('REPORT.PDF'), isTrue);
    expect(isPdfFileName('  scan.Pdf  '), isTrue);
    expect(isPdfFileName('化验单.jpg'), isFalse);
    expect(isPdfFileName('report.png'), isFalse);
    expect(isPdfFileName('pdf'), isFalse);
    expect(isPdfFileName(''), isFalse);
  });
}
