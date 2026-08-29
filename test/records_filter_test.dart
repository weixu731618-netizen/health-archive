// B3：记录页搜索 / 筛选 判定 + 标签解析 —— 逻辑。
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/utils/records_filter.dart';

void main() {
  test('normalizeTags / parseTags：去空、去重、剔除含逗号项', () {
    expect(HealthRepository.normalizeTags([' 体检 ', '术前', '体检', 'a,b', '']),
        '体检,术前');
    expect(HealthRepository.parseTags('体检, 术前 ,'), ['体检', '术前']);
    expect(HealthRepository.parseTags(''), isEmpty);
    expect(HealthRepository.parseTags(null), isEmpty);
  });

  test('presetToRange', () {
    final now = DateTime(2026, 8, 29);
    expect(presetToRange(RecordDatePreset.all, now), isNull);
    expect(presetToRange(RecordDatePreset.custom, now), isNull);
    expect(presetToRange(RecordDatePreset.month1, now)!.start,
        DateTime(2026, 7, 30));
    expect(presetToRange(RecordDatePreset.year1, now)!.start,
        DateTime(2025, 8, 29));
  });

  test('matchesEntry：关键词 / 只看异常 / 时间范围 / 报告专属筛选排除', () {
    const base = RecordFilter();
    expect(
        base.matchesEntry(
            title: '体重',
            subtitle: '82 kg',
            status: '',
            measuredAt: DateTime(2026, 8, 1)),
        isTrue);

    final kw = base.copyWith(query: 'kg');
    expect(
        kw.matchesEntry(
            title: '体重',
            subtitle: '82 kg',
            status: '',
            measuredAt: DateTime(2026, 8, 1)),
        isTrue);
    expect(
        kw.matchesEntry(
            title: '血压',
            subtitle: '128/82 mmHg',
            status: '',
            measuredAt: DateTime(2026, 8, 1)),
        isFalse);

    final abn = base.copyWith(abnormalOnly: true);
    expect(
        abn.matchesEntry(
            title: '尿酸',
            subtitle: '',
            status: '偏高',
            measuredAt: DateTime(2026, 8, 1)),
        isTrue);
    expect(
        abn.matchesEntry(
            title: '尿酸',
            subtitle: '',
            status: '正常',
            measuredAt: DateTime(2026, 8, 1)),
        isFalse);

    final ranged = base.copyWith(
        dateRange: DateTimeRange(
            start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31)));
    expect(
        ranged.matchesEntry(
            title: 'x',
            subtitle: '',
            status: '',
            measuredAt: DateTime(2026, 7, 15)),
        isFalse);
    expect(
        ranged.matchesEntry(
            title: 'x',
            subtitle: '',
            status: '',
            measuredAt: DateTime(2026, 8, 15)),
        isTrue);

    // 报告专属筛选（标签 / 医院）生效 → 非报告条目一律排除
    final reportOnly = base.copyWith(tags: {'体检'});
    expect(reportOnly.isReportOnly, isTrue);
    expect(
        reportOnly.matchesEntry(
            title: 'x',
            subtitle: '',
            status: '',
            measuredAt: DateTime(2026, 8, 15)),
        isFalse);
  });

  group('matchesReport（用内存库建真实 MedicalReport）', () {
    late AppDatabase db;
    late HealthRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = HealthRepository(db);
    });
    tearDown(() async => db.close());

    Future<MedicalReport> make({
      String hospital = '深圳市人民医院',
      String type = '生化检查',
      String? rawText,
      List<String> tags = const [],
      DateTime? date,
    }) async {
      final id = await repo.insertReport(
        hospitalName: hospital,
        reportDate: date ?? DateTime(2026, 8, 1),
        reportType: type,
        rawText: rawText,
        tags: tags,
      );
      return (await repo.getReportById(id))!;
    }

    test('关键词命中医院 / 类型 / 结论 / 指标名 / 标签', () async {
      final r = await make(
          rawText: '双肺结节', tags: ['体检'], type: 'CT');
      bool q(String s) => RecordFilter(query: s).matchesReport(r,
          metricNames: const ['尿酸', '肌酐'], hasAbnormalMetric: false);
      expect(q('人民医院'), isTrue);
      expect(q('ct'), isTrue);
      expect(q('结节'), isTrue);
      expect(q('肌酐'), isTrue);
      expect(q('体检'), isTrue);
      expect(q('完全无关'), isFalse);
    });

    test('标签 / 医院 / 只看异常 / 时间范围 过滤', () async {
      final r = await make(
          tags: ['体检', '复查'],
          hospital: '协和医院',
          date: DateTime(2026, 5, 1));
      bool m(RecordFilter f, {bool abnormal = false}) => f.matchesReport(r,
          metricNames: const [], hasAbnormalMetric: abnormal);

      expect(m(const RecordFilter(tags: {'复查'})), isTrue);
      expect(m(const RecordFilter(tags: {'术前'})), isFalse);
      expect(m(const RecordFilter(hospitals: {'协和医院'})), isTrue);
      expect(m(const RecordFilter(hospitals: {'人民医院'})), isFalse);
      expect(m(const RecordFilter(abnormalOnly: true)), isFalse);
      expect(m(const RecordFilter(abnormalOnly: true), abnormal: true), isTrue);
      expect(
          m(RecordFilter(
              dateRange: DateTimeRange(
                  start: DateTime(2026, 6, 1), end: DateTime(2026, 8, 1)))),
          isFalse);
    });
  });
}
