import 'package:flutter_test/flutter_test.dart';
import 'package:health_archive/utils/patient_name_match.dart';

void main() {
  group('normalizePersonName', () {
    test('去空格标点与称谓', () {
      expect(normalizePersonName(' 张 三 '), '张三');
      expect(normalizePersonName('张三（先生）'), '张三');
      expect(normalizePersonName('李四 女士'), '李四');
      expect(normalizePersonName('WANG, LI'), 'wangli');
    });
  });

  group('personNamesLooselyEqual', () {
    test('宽松相等', () {
      expect(personNamesLooselyEqual('张 三', '张三先生'), isTrue);
      expect(personNamesLooselyEqual('张三', '李四'), isFalse);
      expect(personNamesLooselyEqual('', '张三'), isFalse);
    });
  });

  group('appendKnownName', () {
    test('去重并入', () {
      expect(appendKnownName('', '张三'), '张三');
      expect(appendKnownName('张三', '张 三 '), '张三'); // 宽松去重
      expect(appendKnownName('张三', '李四'), '张三,李四');
      expect(appendKnownName('张三', '  '), '张三'); // 空名不写
    });
  });

  group('checkReportNameAgainstProfile', () {
    test('OCR 没读到姓名 → noOpinion', () {
      expect(
        checkReportNameAgainstProfile(ocrPatientName: '', knownNamesStored: '张三'),
        NameCheckResult.noOpinion,
      );
    });

    test('档案还没记过真名 → firstSeen', () {
      expect(
        checkReportNameAgainstProfile(ocrPatientName: '张三', knownNamesStored: ''),
        NameCheckResult.firstSeen,
      );
    });

    test('与已记住的真名一致 → ok（含宽松写法）', () {
      expect(
        checkReportNameAgainstProfile(
            ocrPatientName: '张 三', knownNamesStored: '张三,李四'),
        NameCheckResult.ok,
      );
    });

    test('与已记住的真名都对不上 → mismatch', () {
      expect(
        checkReportNameAgainstProfile(
            ocrPatientName: '王五', knownNamesStored: '张三,李四'),
        NameCheckResult.mismatch,
      );
    });
  });
}
