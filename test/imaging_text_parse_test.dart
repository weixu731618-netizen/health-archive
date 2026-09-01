import 'package:flutter_test/flutter_test.dart';
import 'package:health_archive/utils/imaging_text_parse.dart';

void main() {
  group('guessImagingReportType', () {
    test('彩超关键词', () {
      expect(
        guessImagingReportType('腹部彩色多普勒超声检查所见：肝脏大小形态正常'),
        '彩超',
      );
      expect(guessImagingReportType('B型超声提示：胆囊壁毛糙'), '彩超');
    });

    test('CT / MRI / X光 / 心电图 / 病理', () {
      expect(guessImagingReportType('胸部CT平扫：双肺纹理清晰'), 'CT');
      expect(guessImagingReportType('头颅磁共振 T2WI 未见异常信号'), 'MRI');
      expect(guessImagingReportType('胸部DR摄片：心影不大'), 'X光');
      expect(guessImagingReportType('常规心电图：窦性心律'), '心电图');
      expect(guessImagingReportType('病理诊断：（胃窦）慢性浅表性胃炎'), '病理');
    });

    test('猜不出返回 null', () {
      expect(guessImagingReportType('未见明显异常'), isNull);
      expect(guessImagingReportType(''), isNull);
    });

    test('体检套餐清单里单独一个弱词不算数（总分<2 → null）', () {
      // 体检表首页/项目清单常见：一串「项目名」里出现「正位片」「心电图」各一次
      expect(
        guessImagingReportType('体检项目：一般检查 内科 外科 胸部正位片 心电图 腹部彩超 血常规'),
        isNull,
      );
      // 只有姓名/日期这类，更是 null
      expect(guessImagingReportType('姓名：张三 年龄：40 电话：138xxxx 体检日期：2026-03-01'),
          isNull);
    });

    test('心脏彩超里有「病理性反流」也不误判成病理', () {
      const s = '心血管内科 超声心动图检查报告\n'
          'CDFI：各瓣膜未见明显病理性反流。主动脉瓣、二尖瓣形态如常。\n'
          '肺动脉内径正常。左室射血分数65%。检查提示：超声心动图未见明显异常。';
      expect(guessImagingReportType(s), '彩超');
    });
  });

  group('guessReportDate', () {
    final now = DateTime(2026, 8, 31);

    test('多种分隔符', () {
      expect(guessReportDate('检查日期：2026-05-01', now: now), DateTime(2026, 5, 1));
      expect(guessReportDate('2026/05/01 报告', now: now), DateTime(2026, 5, 1));
      expect(guessReportDate('2026年5月1日', now: now), DateTime(2026, 5, 1));
    });

    test('未来日期 / 非法日期 / 无日期 → null', () {
      expect(guessReportDate('2099-01-01', now: now), isNull);
      expect(guessReportDate('2026-13-45', now: now), isNull);
      expect(guessReportDate('无日期信息', now: now), isNull);
    });
  });

  group('guessBodyAreas', () {
    test('腹部彩超命中肝胆 / 泌尿', () {
      final areas = guessBodyAreas('肝脏、胆囊未见异常；双肾及膀胱未见结石');
      expect(areas, containsAll(<String>['肝胆', '肾脏/泌尿']));
    });

    test('甲状腺 → 内分泌/代谢；心脏 → 心血管', () {
      expect(guessBodyAreas('甲状腺两叶大小正常'), contains('内分泌/代谢'));
      expect(guessBodyAreas('心脏各房室内径正常，二尖瓣未见反流'), contains('心血管'));
    });

    test('无部位关键词 → 空集合', () {
      expect(guessBodyAreas('未见明显异常'), isEmpty);
    });

    test('心脏彩超不会因「肺动脉」被判进呼吸系统', () {
      final areas = guessBodyAreas(
          '各房室内径正常。二尖瓣、主动脉瓣形态如常。肺动脉内径正常，肺动脉收缩压正常。');
      expect(areas, contains('心血管'));
      expect(areas, isNot(contains('呼吸系统')));
    });
  });

  group('hasReportSubstance', () {
    test('体检表封面/信息页 → false', () {
      expect(
        hasReportSubstance('姓名：张三\n年龄：40\n电话：13800000000\n体检医生：李四\n体检日期：2026-03-01'),
        isFalse,
      );
      expect(hasReportSubstance(''), isFalse);
      expect(hasReportSubstance('体检项目单 内科 外科 心电图 彩超'), isFalse);
    });

    test('有报告正文/结论用语 → true', () {
      expect(hasReportSubstance('检查所见：肝脏形态大小正常，实质回声均匀。\n结论：未见明显异常。'), isTrue);
      expect(hasReportSubstance('诊断：慢性浅表性胃炎'), isTrue);
    });

    test('明确影像类关键词 → true', () {
      expect(hasReportSubstance('胸部CT平扫：双肺纹理清晰'), isTrue);
    });
  });

  group('looksLikeImagingReport', () {
    test('reportType 是影像类 → true（即使 DeepSeek 抽了测量值）', () {
      expect(
        looksLikeImagingReport(reportType: 'B超', ocrText: '肝右叶斜径 12.5cm'),
        isTrue,
      );
      expect(looksLikeImagingReport(reportType: '彩超', ocrText: ''), isTrue);
      expect(looksLikeImagingReport(reportType: 'CT', ocrText: ''), isTrue);
    });

    test('reportType 不明但 OCR 全文命中影像关键词 → true', () {
      expect(
        looksLikeImagingReport(
            reportType: '其他检验', ocrText: '腹部超声所见：胆囊壁毛糙，胆总管未见扩张'),
        isTrue,
      );
    });

    test('普通生化化验单 → false', () {
      expect(
        looksLikeImagingReport(
            reportType: '生化',
            ocrText: '谷丙转氨酶 32 U/L\n总胆固醇 5.4 mmol/L\n空腹血糖 6.1 mmol/L'),
        isFalse,
      );
    });
  });
}
