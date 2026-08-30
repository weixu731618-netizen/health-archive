// 首页「检查驱动」完成度模型。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/models/checkup_coverage.dart';

final _now = DateTime(2026, 8, 30);

HealthMetric _m(String id, {required int daysAgo}) => HealthMetric(
      id: (id.hashCode ^ daysAgo) & 0x7fffffff,
      profileId: 1,
      metricId: id,
      metricName: id,
      value: 1,
      unit: 'x',
      status: '正常',
      bodySystem: '其他',
      measuredAt: _now.subtract(Duration(days: daysAgo)),
      sourceType: 'manual',
      createdAt: _now,
      matchType: 'manual',
      verificationStatus: 'user_confirmed',
    );

MedicalReport _r(String type, {required int daysAgo}) => MedicalReport(
      id: (type.hashCode ^ daysAgo) & 0x7fffffff,
      profileId: 1,
      hospitalName: '协和',
      reportDate: _now.subtract(Duration(days: daysAgo)),
      reportType: type,
      recognitionStatus: 'confirmed',
      tags: '',
      createdAt: _now,
    );

DailyHealthRecord _d(String type, {required int daysAgo}) => DailyHealthRecord(
      id: (type.hashCode ^ daysAgo) & 0x7fffffff,
      profileId: 1,
      type: type,
      value1: 1,
      unit: 'x',
      measuredAt: _now.subtract(Duration(days: daysAgo)),
      createdAt: _now,
    );

CoverageOverview _cov({
  List<HealthMetric> m = const [],
  List<MedicalReport> r = const [],
  List<DailyHealthRecord> d = const [],
}) =>
    buildCheckupCoverage(metrics: m, reports: r, daily: d, now: _now);

void main() {
  test('完全没数据 → 全部「没查过」，完成度 0%', () {
    final c = _cov();
    expect(c.percent, 0);
    expect(c.coveredCount, 0);
    expect(c.dueList.length, c.total);
    expect(c.dueList.every((a) => a.neverDone), isTrue);
  });

  test('近期做过 → 覆盖；超周期 → 该查了', () {
    final c = _cov(m: [
      _m('HBA1C', daysAgo: 30), // 血糖，周期 365 → 覆盖
      _m('LDLC', daysAgo: 500), // 血脂，周期 365 → 逾期
      _m('TSH', daysAgo: 300), // 甲状腺，周期 730 → 覆盖
    ]);
    final byKey = {for (final a in c.aspects) a.aspect.key: a};
    expect(byKey['glucose']!.covered, isTrue);
    expect(byKey['lipid']!.overdue, isTrue);
    expect(byKey['lipid']!.due, isTrue);
    expect(byKey['thyroid']!.covered, isTrue);
  });

  test('任意报告都算「年度体检」；报告类型子串匹配影像项', () {
    final c = _cov(r: [
      _r('生化检查', daysAgo: 60), // → physical 覆盖
      _r('腹部B超', daysAgo: 100), // → abdominal_us 覆盖
    ]);
    final byKey = {for (final a in c.aspects) a.aspect.key: a};
    expect(byKey['physical']!.covered, isTrue);
    expect(byKey['abdominal_us']!.covered, isTrue);
    expect(byKey['chest']!.neverDone, isTrue);
  });

  test('日常血压记录算「血压」项', () {
    final c = _cov(d: [_d('blood_pressure', daysAgo: 10)]);
    final bp = c.aspects.firstWhere((a) => a.aspect.key == 'bp');
    expect(bp.covered, isTrue);
  });

  test('dueList 逾期越久排越前，从没查过排最前', () {
    final c = _cov(m: [
      _m('HBA1C', daysAgo: 400), // 逾期 ~35 天
      _m('LDLC', daysAgo: 900), // 逾期 ~535 天
    ]);
    // 从没查过的项排在最前
    expect(c.dueList.first.neverDone, isTrue);
    // 逾期项里 LDLC(血脂) 比 HBA1C(血糖) 逾期更久
    final overdue = c.dueList.where((a) => a.overdue).toList();
    expect(overdue.first.aspect.key, 'lipid');
  });

  test('headline 文案', () {
    expect(_cov().headline, '健康档案完成度 0%');
  });
}
