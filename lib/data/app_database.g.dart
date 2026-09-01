// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HealthMetricsTable extends HealthMetrics
    with TableInfo<$HealthMetricsTable, HealthMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _metricIdMeta =
      const VerificationMeta('metricId');
  @override
  late final GeneratedColumn<String> metricId = GeneratedColumn<String>(
      'metric_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metricNameMeta =
      const VerificationMeta('metricName');
  @override
  late final GeneratedColumn<String> metricName = GeneratedColumn<String>(
      'metric_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rawValueMeta =
      const VerificationMeta('rawValue');
  @override
  late final GeneratedColumn<String> rawValue = GeneratedColumn<String>(
      'raw_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _numericValueMeta =
      const VerificationMeta('numericValue');
  @override
  late final GeneratedColumn<double> numericValue = GeneratedColumn<double>(
      'numeric_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canonicalValueMeta =
      const VerificationMeta('canonicalValue');
  @override
  late final GeneratedColumn<double> canonicalValue = GeneratedColumn<double>(
      'canonical_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _canonicalUnitMeta =
      const VerificationMeta('canonicalUnit');
  @override
  late final GeneratedColumn<String> canonicalUnit = GeneratedColumn<String>(
      'canonical_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceMinMeta =
      const VerificationMeta('referenceMin');
  @override
  late final GeneratedColumn<double> referenceMin = GeneratedColumn<double>(
      'reference_min', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _referenceMaxMeta =
      const VerificationMeta('referenceMax');
  @override
  late final GeneratedColumn<double> referenceMax = GeneratedColumn<double>(
      'reference_max', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _referenceRangeRawMeta =
      const VerificationMeta('referenceRangeRaw');
  @override
  late final GeneratedColumn<String> referenceRangeRaw =
      GeneratedColumn<String>('reference_range_raw', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceAbnormalFlagMeta =
      const VerificationMeta('sourceAbnormalFlag');
  @override
  late final GeneratedColumn<String> sourceAbnormalFlag =
      GeneratedColumn<String>('source_abnormal_flag', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodySystemMeta =
      const VerificationMeta('bodySystem');
  @override
  late final GeneratedColumn<String> bodySystem = GeneratedColumn<String>(
      'body_system', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _measuredAtMeta =
      const VerificationMeta('measuredAt');
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
      'measured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rawNameMeta =
      const VerificationMeta('rawName');
  @override
  late final GeneratedColumn<String> rawName = GeneratedColumn<String>(
      'raw_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _matchTypeMeta =
      const VerificationMeta('matchType');
  @override
  late final GeneratedColumn<String> matchType = GeneratedColumn<String>(
      'match_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _recognitionConfidenceMeta =
      const VerificationMeta('recognitionConfidence');
  @override
  late final GeneratedColumn<double> recognitionConfidence =
      GeneratedColumn<double>('recognition_confidence', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _verificationStatusMeta =
      const VerificationMeta('verificationStatus');
  @override
  late final GeneratedColumn<String> verificationStatus =
      GeneratedColumn<String>('verification_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('user_confirmed'));
  static const VerificationMeta _sourcePageMeta =
      const VerificationMeta('sourcePage');
  @override
  late final GeneratedColumn<int> sourcePage = GeneratedColumn<int>(
      'source_page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceBoundingBoxMeta =
      const VerificationMeta('sourceBoundingBox');
  @override
  late final GeneratedColumn<String> sourceBoundingBox =
      GeneratedColumn<String>('source_bounding_box', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        metricId,
        metricName,
        value,
        rawValue,
        numericValue,
        unit,
        canonicalValue,
        canonicalUnit,
        referenceMin,
        referenceMax,
        referenceRangeRaw,
        sourceAbnormalFlag,
        status,
        bodySystem,
        measuredAt,
        sourceType,
        sourceId,
        notes,
        createdAt,
        reportId,
        rawName,
        matchType,
        recognitionConfidence,
        verificationStatus,
        sourcePage,
        sourceBoundingBox
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<HealthMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('metric_id')) {
      context.handle(_metricIdMeta,
          metricId.isAcceptableOrUnknown(data['metric_id']!, _metricIdMeta));
    } else if (isInserting) {
      context.missing(_metricIdMeta);
    }
    if (data.containsKey('metric_name')) {
      context.handle(
          _metricNameMeta,
          metricName.isAcceptableOrUnknown(
              data['metric_name']!, _metricNameMeta));
    } else if (isInserting) {
      context.missing(_metricNameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('raw_value')) {
      context.handle(_rawValueMeta,
          rawValue.isAcceptableOrUnknown(data['raw_value']!, _rawValueMeta));
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
          _numericValueMeta,
          numericValue.isAcceptableOrUnknown(
              data['numeric_value']!, _numericValueMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('canonical_value')) {
      context.handle(
          _canonicalValueMeta,
          canonicalValue.isAcceptableOrUnknown(
              data['canonical_value']!, _canonicalValueMeta));
    }
    if (data.containsKey('canonical_unit')) {
      context.handle(
          _canonicalUnitMeta,
          canonicalUnit.isAcceptableOrUnknown(
              data['canonical_unit']!, _canonicalUnitMeta));
    }
    if (data.containsKey('reference_min')) {
      context.handle(
          _referenceMinMeta,
          referenceMin.isAcceptableOrUnknown(
              data['reference_min']!, _referenceMinMeta));
    }
    if (data.containsKey('reference_max')) {
      context.handle(
          _referenceMaxMeta,
          referenceMax.isAcceptableOrUnknown(
              data['reference_max']!, _referenceMaxMeta));
    }
    if (data.containsKey('reference_range_raw')) {
      context.handle(
          _referenceRangeRawMeta,
          referenceRangeRaw.isAcceptableOrUnknown(
              data['reference_range_raw']!, _referenceRangeRawMeta));
    }
    if (data.containsKey('source_abnormal_flag')) {
      context.handle(
          _sourceAbnormalFlagMeta,
          sourceAbnormalFlag.isAcceptableOrUnknown(
              data['source_abnormal_flag']!, _sourceAbnormalFlagMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('body_system')) {
      context.handle(
          _bodySystemMeta,
          bodySystem.isAcceptableOrUnknown(
              data['body_system']!, _bodySystemMeta));
    } else if (isInserting) {
      context.missing(_bodySystemMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
          _measuredAtMeta,
          measuredAt.isAcceptableOrUnknown(
              data['measured_at']!, _measuredAtMeta));
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    }
    if (data.containsKey('raw_name')) {
      context.handle(_rawNameMeta,
          rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta));
    }
    if (data.containsKey('match_type')) {
      context.handle(_matchTypeMeta,
          matchType.isAcceptableOrUnknown(data['match_type']!, _matchTypeMeta));
    }
    if (data.containsKey('recognition_confidence')) {
      context.handle(
          _recognitionConfidenceMeta,
          recognitionConfidence.isAcceptableOrUnknown(
              data['recognition_confidence']!, _recognitionConfidenceMeta));
    }
    if (data.containsKey('verification_status')) {
      context.handle(
          _verificationStatusMeta,
          verificationStatus.isAcceptableOrUnknown(
              data['verification_status']!, _verificationStatusMeta));
    }
    if (data.containsKey('source_page')) {
      context.handle(
          _sourcePageMeta,
          sourcePage.isAcceptableOrUnknown(
              data['source_page']!, _sourcePageMeta));
    }
    if (data.containsKey('source_bounding_box')) {
      context.handle(
          _sourceBoundingBoxMeta,
          sourceBoundingBox.isAcceptableOrUnknown(
              data['source_bounding_box']!, _sourceBoundingBoxMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      metricId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metric_id'])!,
      metricName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metric_name'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      rawValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_value']),
      numericValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}numeric_value']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      canonicalValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}canonical_value']),
      canonicalUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canonical_unit']),
      referenceMin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}reference_min']),
      referenceMax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}reference_max']),
      referenceRangeRaw: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_range_raw']),
      sourceAbnormalFlag: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_abnormal_flag']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      bodySystem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_system'])!,
      measuredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}measured_at'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id']),
      rawName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_name']),
      matchType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_type'])!,
      recognitionConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}recognition_confidence']),
      verificationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verification_status'])!,
      sourcePage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_page']),
      sourceBoundingBox: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_bounding_box']),
    );
  }

  @override
  $HealthMetricsTable createAlias(String alias) {
    return $HealthMetricsTable(attachedDatabase, alias);
  }
}

class HealthMetric extends DataClass implements Insertable<HealthMetric> {
  final int id;
  final int profileId;
  final String metricId;
  final String metricName;
  final double value;
  final String? rawValue;
  final double? numericValue;
  final String unit;
  final double? canonicalValue;
  final String? canonicalUnit;
  final double? referenceMin;
  final double? referenceMax;
  final String? referenceRangeRaw;
  final String? sourceAbnormalFlag;
  final String status;
  final String bodySystem;
  final DateTime measuredAt;
  final String sourceType;
  final String? sourceId;
  final String? notes;
  final DateTime createdAt;
  final int? reportId;
  final String? rawName;
  final String matchType;
  final double? recognitionConfidence;
  final String verificationStatus;
  final int? sourcePage;
  final String? sourceBoundingBox;
  const HealthMetric(
      {required this.id,
      required this.profileId,
      required this.metricId,
      required this.metricName,
      required this.value,
      this.rawValue,
      this.numericValue,
      required this.unit,
      this.canonicalValue,
      this.canonicalUnit,
      this.referenceMin,
      this.referenceMax,
      this.referenceRangeRaw,
      this.sourceAbnormalFlag,
      required this.status,
      required this.bodySystem,
      required this.measuredAt,
      required this.sourceType,
      this.sourceId,
      this.notes,
      required this.createdAt,
      this.reportId,
      this.rawName,
      required this.matchType,
      this.recognitionConfidence,
      required this.verificationStatus,
      this.sourcePage,
      this.sourceBoundingBox});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['metric_id'] = Variable<String>(metricId);
    map['metric_name'] = Variable<String>(metricName);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || rawValue != null) {
      map['raw_value'] = Variable<String>(rawValue);
    }
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<double>(numericValue);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || canonicalValue != null) {
      map['canonical_value'] = Variable<double>(canonicalValue);
    }
    if (!nullToAbsent || canonicalUnit != null) {
      map['canonical_unit'] = Variable<String>(canonicalUnit);
    }
    if (!nullToAbsent || referenceMin != null) {
      map['reference_min'] = Variable<double>(referenceMin);
    }
    if (!nullToAbsent || referenceMax != null) {
      map['reference_max'] = Variable<double>(referenceMax);
    }
    if (!nullToAbsent || referenceRangeRaw != null) {
      map['reference_range_raw'] = Variable<String>(referenceRangeRaw);
    }
    if (!nullToAbsent || sourceAbnormalFlag != null) {
      map['source_abnormal_flag'] = Variable<String>(sourceAbnormalFlag);
    }
    map['status'] = Variable<String>(status);
    map['body_system'] = Variable<String>(bodySystem);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || reportId != null) {
      map['report_id'] = Variable<int>(reportId);
    }
    if (!nullToAbsent || rawName != null) {
      map['raw_name'] = Variable<String>(rawName);
    }
    map['match_type'] = Variable<String>(matchType);
    if (!nullToAbsent || recognitionConfidence != null) {
      map['recognition_confidence'] = Variable<double>(recognitionConfidence);
    }
    map['verification_status'] = Variable<String>(verificationStatus);
    if (!nullToAbsent || sourcePage != null) {
      map['source_page'] = Variable<int>(sourcePage);
    }
    if (!nullToAbsent || sourceBoundingBox != null) {
      map['source_bounding_box'] = Variable<String>(sourceBoundingBox);
    }
    return map;
  }

  HealthMetricsCompanion toCompanion(bool nullToAbsent) {
    return HealthMetricsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      metricId: Value(metricId),
      metricName: Value(metricName),
      value: Value(value),
      rawValue: rawValue == null && nullToAbsent
          ? const Value.absent()
          : Value(rawValue),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      unit: Value(unit),
      canonicalValue: canonicalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalValue),
      canonicalUnit: canonicalUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalUnit),
      referenceMin: referenceMin == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceMin),
      referenceMax: referenceMax == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceMax),
      referenceRangeRaw: referenceRangeRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceRangeRaw),
      sourceAbnormalFlag: sourceAbnormalFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAbnormalFlag),
      status: Value(status),
      bodySystem: Value(bodySystem),
      measuredAt: Value(measuredAt),
      sourceType: Value(sourceType),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      reportId: reportId == null && nullToAbsent
          ? const Value.absent()
          : Value(reportId),
      rawName: rawName == null && nullToAbsent
          ? const Value.absent()
          : Value(rawName),
      matchType: Value(matchType),
      recognitionConfidence: recognitionConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(recognitionConfidence),
      verificationStatus: Value(verificationStatus),
      sourcePage: sourcePage == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePage),
      sourceBoundingBox: sourceBoundingBox == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceBoundingBox),
    );
  }

  factory HealthMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthMetric(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      metricId: serializer.fromJson<String>(json['metricId']),
      metricName: serializer.fromJson<String>(json['metricName']),
      value: serializer.fromJson<double>(json['value']),
      rawValue: serializer.fromJson<String?>(json['rawValue']),
      numericValue: serializer.fromJson<double?>(json['numericValue']),
      unit: serializer.fromJson<String>(json['unit']),
      canonicalValue: serializer.fromJson<double?>(json['canonicalValue']),
      canonicalUnit: serializer.fromJson<String?>(json['canonicalUnit']),
      referenceMin: serializer.fromJson<double?>(json['referenceMin']),
      referenceMax: serializer.fromJson<double?>(json['referenceMax']),
      referenceRangeRaw:
          serializer.fromJson<String?>(json['referenceRangeRaw']),
      sourceAbnormalFlag:
          serializer.fromJson<String?>(json['sourceAbnormalFlag']),
      status: serializer.fromJson<String>(json['status']),
      bodySystem: serializer.fromJson<String>(json['bodySystem']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      reportId: serializer.fromJson<int?>(json['reportId']),
      rawName: serializer.fromJson<String?>(json['rawName']),
      matchType: serializer.fromJson<String>(json['matchType']),
      recognitionConfidence:
          serializer.fromJson<double?>(json['recognitionConfidence']),
      verificationStatus:
          serializer.fromJson<String>(json['verificationStatus']),
      sourcePage: serializer.fromJson<int?>(json['sourcePage']),
      sourceBoundingBox:
          serializer.fromJson<String?>(json['sourceBoundingBox']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'metricId': serializer.toJson<String>(metricId),
      'metricName': serializer.toJson<String>(metricName),
      'value': serializer.toJson<double>(value),
      'rawValue': serializer.toJson<String?>(rawValue),
      'numericValue': serializer.toJson<double?>(numericValue),
      'unit': serializer.toJson<String>(unit),
      'canonicalValue': serializer.toJson<double?>(canonicalValue),
      'canonicalUnit': serializer.toJson<String?>(canonicalUnit),
      'referenceMin': serializer.toJson<double?>(referenceMin),
      'referenceMax': serializer.toJson<double?>(referenceMax),
      'referenceRangeRaw': serializer.toJson<String?>(referenceRangeRaw),
      'sourceAbnormalFlag': serializer.toJson<String?>(sourceAbnormalFlag),
      'status': serializer.toJson<String>(status),
      'bodySystem': serializer.toJson<String>(bodySystem),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String?>(sourceId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'reportId': serializer.toJson<int?>(reportId),
      'rawName': serializer.toJson<String?>(rawName),
      'matchType': serializer.toJson<String>(matchType),
      'recognitionConfidence':
          serializer.toJson<double?>(recognitionConfidence),
      'verificationStatus': serializer.toJson<String>(verificationStatus),
      'sourcePage': serializer.toJson<int?>(sourcePage),
      'sourceBoundingBox': serializer.toJson<String?>(sourceBoundingBox),
    };
  }

  HealthMetric copyWith(
          {int? id,
          int? profileId,
          String? metricId,
          String? metricName,
          double? value,
          Value<String?> rawValue = const Value.absent(),
          Value<double?> numericValue = const Value.absent(),
          String? unit,
          Value<double?> canonicalValue = const Value.absent(),
          Value<String?> canonicalUnit = const Value.absent(),
          Value<double?> referenceMin = const Value.absent(),
          Value<double?> referenceMax = const Value.absent(),
          Value<String?> referenceRangeRaw = const Value.absent(),
          Value<String?> sourceAbnormalFlag = const Value.absent(),
          String? status,
          String? bodySystem,
          DateTime? measuredAt,
          String? sourceType,
          Value<String?> sourceId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<int?> reportId = const Value.absent(),
          Value<String?> rawName = const Value.absent(),
          String? matchType,
          Value<double?> recognitionConfidence = const Value.absent(),
          String? verificationStatus,
          Value<int?> sourcePage = const Value.absent(),
          Value<String?> sourceBoundingBox = const Value.absent()}) =>
      HealthMetric(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        metricId: metricId ?? this.metricId,
        metricName: metricName ?? this.metricName,
        value: value ?? this.value,
        rawValue: rawValue.present ? rawValue.value : this.rawValue,
        numericValue:
            numericValue.present ? numericValue.value : this.numericValue,
        unit: unit ?? this.unit,
        canonicalValue:
            canonicalValue.present ? canonicalValue.value : this.canonicalValue,
        canonicalUnit:
            canonicalUnit.present ? canonicalUnit.value : this.canonicalUnit,
        referenceMin:
            referenceMin.present ? referenceMin.value : this.referenceMin,
        referenceMax:
            referenceMax.present ? referenceMax.value : this.referenceMax,
        referenceRangeRaw: referenceRangeRaw.present
            ? referenceRangeRaw.value
            : this.referenceRangeRaw,
        sourceAbnormalFlag: sourceAbnormalFlag.present
            ? sourceAbnormalFlag.value
            : this.sourceAbnormalFlag,
        status: status ?? this.status,
        bodySystem: bodySystem ?? this.bodySystem,
        measuredAt: measuredAt ?? this.measuredAt,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        reportId: reportId.present ? reportId.value : this.reportId,
        rawName: rawName.present ? rawName.value : this.rawName,
        matchType: matchType ?? this.matchType,
        recognitionConfidence: recognitionConfidence.present
            ? recognitionConfidence.value
            : this.recognitionConfidence,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        sourcePage: sourcePage.present ? sourcePage.value : this.sourcePage,
        sourceBoundingBox: sourceBoundingBox.present
            ? sourceBoundingBox.value
            : this.sourceBoundingBox,
      );
  HealthMetric copyWithCompanion(HealthMetricsCompanion data) {
    return HealthMetric(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      metricId: data.metricId.present ? data.metricId.value : this.metricId,
      metricName:
          data.metricName.present ? data.metricName.value : this.metricName,
      value: data.value.present ? data.value.value : this.value,
      rawValue: data.rawValue.present ? data.rawValue.value : this.rawValue,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      canonicalValue: data.canonicalValue.present
          ? data.canonicalValue.value
          : this.canonicalValue,
      canonicalUnit: data.canonicalUnit.present
          ? data.canonicalUnit.value
          : this.canonicalUnit,
      referenceMin: data.referenceMin.present
          ? data.referenceMin.value
          : this.referenceMin,
      referenceMax: data.referenceMax.present
          ? data.referenceMax.value
          : this.referenceMax,
      referenceRangeRaw: data.referenceRangeRaw.present
          ? data.referenceRangeRaw.value
          : this.referenceRangeRaw,
      sourceAbnormalFlag: data.sourceAbnormalFlag.present
          ? data.sourceAbnormalFlag.value
          : this.sourceAbnormalFlag,
      status: data.status.present ? data.status.value : this.status,
      bodySystem:
          data.bodySystem.present ? data.bodySystem.value : this.bodySystem,
      measuredAt:
          data.measuredAt.present ? data.measuredAt.value : this.measuredAt,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      matchType: data.matchType.present ? data.matchType.value : this.matchType,
      recognitionConfidence: data.recognitionConfidence.present
          ? data.recognitionConfidence.value
          : this.recognitionConfidence,
      verificationStatus: data.verificationStatus.present
          ? data.verificationStatus.value
          : this.verificationStatus,
      sourcePage:
          data.sourcePage.present ? data.sourcePage.value : this.sourcePage,
      sourceBoundingBox: data.sourceBoundingBox.present
          ? data.sourceBoundingBox.value
          : this.sourceBoundingBox,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthMetric(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('metricId: $metricId, ')
          ..write('metricName: $metricName, ')
          ..write('value: $value, ')
          ..write('rawValue: $rawValue, ')
          ..write('numericValue: $numericValue, ')
          ..write('unit: $unit, ')
          ..write('canonicalValue: $canonicalValue, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('referenceMin: $referenceMin, ')
          ..write('referenceMax: $referenceMax, ')
          ..write('referenceRangeRaw: $referenceRangeRaw, ')
          ..write('sourceAbnormalFlag: $sourceAbnormalFlag, ')
          ..write('status: $status, ')
          ..write('bodySystem: $bodySystem, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('reportId: $reportId, ')
          ..write('rawName: $rawName, ')
          ..write('matchType: $matchType, ')
          ..write('recognitionConfidence: $recognitionConfidence, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('sourceBoundingBox: $sourceBoundingBox')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        profileId,
        metricId,
        metricName,
        value,
        rawValue,
        numericValue,
        unit,
        canonicalValue,
        canonicalUnit,
        referenceMin,
        referenceMax,
        referenceRangeRaw,
        sourceAbnormalFlag,
        status,
        bodySystem,
        measuredAt,
        sourceType,
        sourceId,
        notes,
        createdAt,
        reportId,
        rawName,
        matchType,
        recognitionConfidence,
        verificationStatus,
        sourcePage,
        sourceBoundingBox
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthMetric &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.metricId == this.metricId &&
          other.metricName == this.metricName &&
          other.value == this.value &&
          other.rawValue == this.rawValue &&
          other.numericValue == this.numericValue &&
          other.unit == this.unit &&
          other.canonicalValue == this.canonicalValue &&
          other.canonicalUnit == this.canonicalUnit &&
          other.referenceMin == this.referenceMin &&
          other.referenceMax == this.referenceMax &&
          other.referenceRangeRaw == this.referenceRangeRaw &&
          other.sourceAbnormalFlag == this.sourceAbnormalFlag &&
          other.status == this.status &&
          other.bodySystem == this.bodySystem &&
          other.measuredAt == this.measuredAt &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.reportId == this.reportId &&
          other.rawName == this.rawName &&
          other.matchType == this.matchType &&
          other.recognitionConfidence == this.recognitionConfidence &&
          other.verificationStatus == this.verificationStatus &&
          other.sourcePage == this.sourcePage &&
          other.sourceBoundingBox == this.sourceBoundingBox);
}

class HealthMetricsCompanion extends UpdateCompanion<HealthMetric> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> metricId;
  final Value<String> metricName;
  final Value<double> value;
  final Value<String?> rawValue;
  final Value<double?> numericValue;
  final Value<String> unit;
  final Value<double?> canonicalValue;
  final Value<String?> canonicalUnit;
  final Value<double?> referenceMin;
  final Value<double?> referenceMax;
  final Value<String?> referenceRangeRaw;
  final Value<String?> sourceAbnormalFlag;
  final Value<String> status;
  final Value<String> bodySystem;
  final Value<DateTime> measuredAt;
  final Value<String> sourceType;
  final Value<String?> sourceId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int?> reportId;
  final Value<String?> rawName;
  final Value<String> matchType;
  final Value<double?> recognitionConfidence;
  final Value<String> verificationStatus;
  final Value<int?> sourcePage;
  final Value<String?> sourceBoundingBox;
  const HealthMetricsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.metricId = const Value.absent(),
    this.metricName = const Value.absent(),
    this.value = const Value.absent(),
    this.rawValue = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.canonicalValue = const Value.absent(),
    this.canonicalUnit = const Value.absent(),
    this.referenceMin = const Value.absent(),
    this.referenceMax = const Value.absent(),
    this.referenceRangeRaw = const Value.absent(),
    this.sourceAbnormalFlag = const Value.absent(),
    this.status = const Value.absent(),
    this.bodySystem = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reportId = const Value.absent(),
    this.rawName = const Value.absent(),
    this.matchType = const Value.absent(),
    this.recognitionConfidence = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.sourceBoundingBox = const Value.absent(),
  });
  HealthMetricsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String metricId,
    required String metricName,
    required double value,
    this.rawValue = const Value.absent(),
    this.numericValue = const Value.absent(),
    required String unit,
    this.canonicalValue = const Value.absent(),
    this.canonicalUnit = const Value.absent(),
    this.referenceMin = const Value.absent(),
    this.referenceMax = const Value.absent(),
    this.referenceRangeRaw = const Value.absent(),
    this.sourceAbnormalFlag = const Value.absent(),
    required String status,
    required String bodySystem,
    required DateTime measuredAt,
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.reportId = const Value.absent(),
    this.rawName = const Value.absent(),
    this.matchType = const Value.absent(),
    this.recognitionConfidence = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.sourceBoundingBox = const Value.absent(),
  })  : metricId = Value(metricId),
        metricName = Value(metricName),
        value = Value(value),
        unit = Value(unit),
        status = Value(status),
        bodySystem = Value(bodySystem),
        measuredAt = Value(measuredAt),
        createdAt = Value(createdAt);
  static Insertable<HealthMetric> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? metricId,
    Expression<String>? metricName,
    Expression<double>? value,
    Expression<String>? rawValue,
    Expression<double>? numericValue,
    Expression<String>? unit,
    Expression<double>? canonicalValue,
    Expression<String>? canonicalUnit,
    Expression<double>? referenceMin,
    Expression<double>? referenceMax,
    Expression<String>? referenceRangeRaw,
    Expression<String>? sourceAbnormalFlag,
    Expression<String>? status,
    Expression<String>? bodySystem,
    Expression<DateTime>? measuredAt,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? reportId,
    Expression<String>? rawName,
    Expression<String>? matchType,
    Expression<double>? recognitionConfidence,
    Expression<String>? verificationStatus,
    Expression<int>? sourcePage,
    Expression<String>? sourceBoundingBox,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (metricId != null) 'metric_id': metricId,
      if (metricName != null) 'metric_name': metricName,
      if (value != null) 'value': value,
      if (rawValue != null) 'raw_value': rawValue,
      if (numericValue != null) 'numeric_value': numericValue,
      if (unit != null) 'unit': unit,
      if (canonicalValue != null) 'canonical_value': canonicalValue,
      if (canonicalUnit != null) 'canonical_unit': canonicalUnit,
      if (referenceMin != null) 'reference_min': referenceMin,
      if (referenceMax != null) 'reference_max': referenceMax,
      if (referenceRangeRaw != null) 'reference_range_raw': referenceRangeRaw,
      if (sourceAbnormalFlag != null)
        'source_abnormal_flag': sourceAbnormalFlag,
      if (status != null) 'status': status,
      if (bodySystem != null) 'body_system': bodySystem,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (reportId != null) 'report_id': reportId,
      if (rawName != null) 'raw_name': rawName,
      if (matchType != null) 'match_type': matchType,
      if (recognitionConfidence != null)
        'recognition_confidence': recognitionConfidence,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (sourcePage != null) 'source_page': sourcePage,
      if (sourceBoundingBox != null) 'source_bounding_box': sourceBoundingBox,
    });
  }

  HealthMetricsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? metricId,
      Value<String>? metricName,
      Value<double>? value,
      Value<String?>? rawValue,
      Value<double?>? numericValue,
      Value<String>? unit,
      Value<double?>? canonicalValue,
      Value<String?>? canonicalUnit,
      Value<double?>? referenceMin,
      Value<double?>? referenceMax,
      Value<String?>? referenceRangeRaw,
      Value<String?>? sourceAbnormalFlag,
      Value<String>? status,
      Value<String>? bodySystem,
      Value<DateTime>? measuredAt,
      Value<String>? sourceType,
      Value<String?>? sourceId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int?>? reportId,
      Value<String?>? rawName,
      Value<String>? matchType,
      Value<double?>? recognitionConfidence,
      Value<String>? verificationStatus,
      Value<int?>? sourcePage,
      Value<String?>? sourceBoundingBox}) {
    return HealthMetricsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      metricId: metricId ?? this.metricId,
      metricName: metricName ?? this.metricName,
      value: value ?? this.value,
      rawValue: rawValue ?? this.rawValue,
      numericValue: numericValue ?? this.numericValue,
      unit: unit ?? this.unit,
      canonicalValue: canonicalValue ?? this.canonicalValue,
      canonicalUnit: canonicalUnit ?? this.canonicalUnit,
      referenceMin: referenceMin ?? this.referenceMin,
      referenceMax: referenceMax ?? this.referenceMax,
      referenceRangeRaw: referenceRangeRaw ?? this.referenceRangeRaw,
      sourceAbnormalFlag: sourceAbnormalFlag ?? this.sourceAbnormalFlag,
      status: status ?? this.status,
      bodySystem: bodySystem ?? this.bodySystem,
      measuredAt: measuredAt ?? this.measuredAt,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      reportId: reportId ?? this.reportId,
      rawName: rawName ?? this.rawName,
      matchType: matchType ?? this.matchType,
      recognitionConfidence:
          recognitionConfidence ?? this.recognitionConfidence,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      sourcePage: sourcePage ?? this.sourcePage,
      sourceBoundingBox: sourceBoundingBox ?? this.sourceBoundingBox,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (metricId.present) {
      map['metric_id'] = Variable<String>(metricId.value);
    }
    if (metricName.present) {
      map['metric_name'] = Variable<String>(metricName.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rawValue.present) {
      map['raw_value'] = Variable<String>(rawValue.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<double>(numericValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (canonicalValue.present) {
      map['canonical_value'] = Variable<double>(canonicalValue.value);
    }
    if (canonicalUnit.present) {
      map['canonical_unit'] = Variable<String>(canonicalUnit.value);
    }
    if (referenceMin.present) {
      map['reference_min'] = Variable<double>(referenceMin.value);
    }
    if (referenceMax.present) {
      map['reference_max'] = Variable<double>(referenceMax.value);
    }
    if (referenceRangeRaw.present) {
      map['reference_range_raw'] = Variable<String>(referenceRangeRaw.value);
    }
    if (sourceAbnormalFlag.present) {
      map['source_abnormal_flag'] = Variable<String>(sourceAbnormalFlag.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bodySystem.present) {
      map['body_system'] = Variable<String>(bodySystem.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (matchType.present) {
      map['match_type'] = Variable<String>(matchType.value);
    }
    if (recognitionConfidence.present) {
      map['recognition_confidence'] =
          Variable<double>(recognitionConfidence.value);
    }
    if (verificationStatus.present) {
      map['verification_status'] = Variable<String>(verificationStatus.value);
    }
    if (sourcePage.present) {
      map['source_page'] = Variable<int>(sourcePage.value);
    }
    if (sourceBoundingBox.present) {
      map['source_bounding_box'] = Variable<String>(sourceBoundingBox.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthMetricsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('metricId: $metricId, ')
          ..write('metricName: $metricName, ')
          ..write('value: $value, ')
          ..write('rawValue: $rawValue, ')
          ..write('numericValue: $numericValue, ')
          ..write('unit: $unit, ')
          ..write('canonicalValue: $canonicalValue, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('referenceMin: $referenceMin, ')
          ..write('referenceMax: $referenceMax, ')
          ..write('referenceRangeRaw: $referenceRangeRaw, ')
          ..write('sourceAbnormalFlag: $sourceAbnormalFlag, ')
          ..write('status: $status, ')
          ..write('bodySystem: $bodySystem, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('reportId: $reportId, ')
          ..write('rawName: $rawName, ')
          ..write('matchType: $matchType, ')
          ..write('recognitionConfidence: $recognitionConfidence, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('sourceBoundingBox: $sourceBoundingBox')
          ..write(')'))
        .toString();
  }
}

class $DailyHealthRecordsTable extends DailyHealthRecords
    with TableInfo<$DailyHealthRecordsTable, DailyHealthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _value1Meta = const VerificationMeta('value1');
  @override
  late final GeneratedColumn<double> value1 = GeneratedColumn<double>(
      'value1', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _value2Meta = const VerificationMeta('value2');
  @override
  late final GeneratedColumn<double> value2 = GeneratedColumn<double>(
      'value2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _measuredAtMeta =
      const VerificationMeta('measuredAt');
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
      'measured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        type,
        value1,
        value2,
        unit,
        context,
        measuredAt,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health_records';
  @override
  VerificationContext validateIntegrity(Insertable<DailyHealthRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value1')) {
      context.handle(_value1Meta,
          value1.isAcceptableOrUnknown(data['value1']!, _value1Meta));
    } else if (isInserting) {
      context.missing(_value1Meta);
    }
    if (data.containsKey('value2')) {
      context.handle(_value2Meta,
          value2.isAcceptableOrUnknown(data['value2']!, _value2Meta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    }
    if (data.containsKey('measured_at')) {
      context.handle(
          _measuredAtMeta,
          measuredAt.isAcceptableOrUnknown(
              data['measured_at']!, _measuredAtMeta));
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyHealthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      value1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value1'])!,
      value2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value2']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context']),
      measuredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}measured_at'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DailyHealthRecordsTable createAlias(String alias) {
    return $DailyHealthRecordsTable(attachedDatabase, alias);
  }
}

class DailyHealthRecord extends DataClass
    implements Insertable<DailyHealthRecord> {
  final int id;
  final int profileId;
  final String type;
  final double value1;
  final double? value2;
  final String unit;
  final String? context;
  final DateTime measuredAt;
  final String? notes;
  final DateTime createdAt;
  const DailyHealthRecord(
      {required this.id,
      required this.profileId,
      required this.type,
      required this.value1,
      this.value2,
      required this.unit,
      this.context,
      required this.measuredAt,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['type'] = Variable<String>(type);
    map['value1'] = Variable<double>(value1);
    if (!nullToAbsent || value2 != null) {
      map['value2'] = Variable<double>(value2);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<String>(context);
    }
    map['measured_at'] = Variable<DateTime>(measuredAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyHealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthRecordsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      type: Value(type),
      value1: Value(value1),
      value2:
          value2 == null && nullToAbsent ? const Value.absent() : Value(value2),
      unit: Value(unit),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      measuredAt: Value(measuredAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory DailyHealthRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthRecord(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      type: serializer.fromJson<String>(json['type']),
      value1: serializer.fromJson<double>(json['value1']),
      value2: serializer.fromJson<double?>(json['value2']),
      unit: serializer.fromJson<String>(json['unit']),
      context: serializer.fromJson<String?>(json['context']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'type': serializer.toJson<String>(type),
      'value1': serializer.toJson<double>(value1),
      'value2': serializer.toJson<double?>(value2),
      'unit': serializer.toJson<String>(unit),
      'context': serializer.toJson<String?>(context),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyHealthRecord copyWith(
          {int? id,
          int? profileId,
          String? type,
          double? value1,
          Value<double?> value2 = const Value.absent(),
          String? unit,
          Value<String?> context = const Value.absent(),
          DateTime? measuredAt,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      DailyHealthRecord(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        type: type ?? this.type,
        value1: value1 ?? this.value1,
        value2: value2.present ? value2.value : this.value2,
        unit: unit ?? this.unit,
        context: context.present ? context.value : this.context,
        measuredAt: measuredAt ?? this.measuredAt,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  DailyHealthRecord copyWithCompanion(DailyHealthRecordsCompanion data) {
    return DailyHealthRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      type: data.type.present ? data.type.value : this.type,
      value1: data.value1.present ? data.value1.value : this.value1,
      value2: data.value2.present ? data.value2.value : this.value2,
      unit: data.unit.present ? data.unit.value : this.unit,
      context: data.context.present ? data.context.value : this.context,
      measuredAt:
          data.measuredAt.present ? data.measuredAt.value : this.measuredAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('value1: $value1, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, type, value1, value2, unit,
      context, measuredAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.type == this.type &&
          other.value1 == this.value1 &&
          other.value2 == this.value2 &&
          other.unit == this.unit &&
          other.context == this.context &&
          other.measuredAt == this.measuredAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DailyHealthRecordsCompanion extends UpdateCompanion<DailyHealthRecord> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> type;
  final Value<double> value1;
  final Value<double?> value2;
  final Value<String> unit;
  final Value<String?> context;
  final Value<DateTime> measuredAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DailyHealthRecordsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.type = const Value.absent(),
    this.value1 = const Value.absent(),
    this.value2 = const Value.absent(),
    this.unit = const Value.absent(),
    this.context = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyHealthRecordsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String type,
    required double value1,
    this.value2 = const Value.absent(),
    required String unit,
    this.context = const Value.absent(),
    required DateTime measuredAt,
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : type = Value(type),
        value1 = Value(value1),
        unit = Value(unit),
        measuredAt = Value(measuredAt),
        createdAt = Value(createdAt);
  static Insertable<DailyHealthRecord> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? type,
    Expression<double>? value1,
    Expression<double>? value2,
    Expression<String>? unit,
    Expression<String>? context,
    Expression<DateTime>? measuredAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (type != null) 'type': type,
      if (value1 != null) 'value1': value1,
      if (value2 != null) 'value2': value2,
      if (unit != null) 'unit': unit,
      if (context != null) 'context': context,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyHealthRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? type,
      Value<double>? value1,
      Value<double?>? value2,
      Value<String>? unit,
      Value<String?>? context,
      Value<DateTime>? measuredAt,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return DailyHealthRecordsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      type: type ?? this.type,
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      unit: unit ?? this.unit,
      context: context ?? this.context,
      measuredAt: measuredAt ?? this.measuredAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value1.present) {
      map['value1'] = Variable<double>(value1.value);
    }
    if (value2.present) {
      map['value2'] = Variable<double>(value2.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('value1: $value1, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicalReportsTable extends MedicalReports
    with TableInfo<$MedicalReportsTable, MedicalReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _hospitalNameMeta =
      const VerificationMeta('hospitalName');
  @override
  late final GeneratedColumn<String> hospitalName = GeneratedColumn<String>(
      'hospital_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reportDateMeta =
      const VerificationMeta('reportDate');
  @override
  late final GeneratedColumn<DateTime> reportDate = GeneratedColumn<DateTime>(
      'report_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reportTypeMeta =
      const VerificationMeta('reportType');
  @override
  late final GeneratedColumn<String> reportType = GeneratedColumn<String>(
      'report_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceImagePathMeta =
      const VerificationMeta('sourceImagePath');
  @override
  late final GeneratedColumn<String> sourceImagePath = GeneratedColumn<String>(
      'source_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recognitionStatusMeta =
      const VerificationMeta('recognitionStatus');
  @override
  late final GeneratedColumn<String> recognitionStatus =
      GeneratedColumn<String>('recognition_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('pending'));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _conditionCodeMeta =
      const VerificationMeta('conditionCode');
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
      'condition_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _encounterIdMeta =
      const VerificationMeta('encounterId');
  @override
  late final GeneratedColumn<int> encounterId = GeneratedColumn<int>(
      'encounter_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        hospitalName,
        reportDate,
        reportType,
        sourceImagePath,
        rawText,
        recognitionStatus,
        tags,
        conditionCode,
        encounterId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_reports';
  @override
  VerificationContext validateIntegrity(Insertable<MedicalReport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('hospital_name')) {
      context.handle(
          _hospitalNameMeta,
          hospitalName.isAcceptableOrUnknown(
              data['hospital_name']!, _hospitalNameMeta));
    } else if (isInserting) {
      context.missing(_hospitalNameMeta);
    }
    if (data.containsKey('report_date')) {
      context.handle(
          _reportDateMeta,
          reportDate.isAcceptableOrUnknown(
              data['report_date']!, _reportDateMeta));
    } else if (isInserting) {
      context.missing(_reportDateMeta);
    }
    if (data.containsKey('report_type')) {
      context.handle(
          _reportTypeMeta,
          reportType.isAcceptableOrUnknown(
              data['report_type']!, _reportTypeMeta));
    } else if (isInserting) {
      context.missing(_reportTypeMeta);
    }
    if (data.containsKey('source_image_path')) {
      context.handle(
          _sourceImagePathMeta,
          sourceImagePath.isAcceptableOrUnknown(
              data['source_image_path']!, _sourceImagePathMeta));
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    }
    if (data.containsKey('recognition_status')) {
      context.handle(
          _recognitionStatusMeta,
          recognitionStatus.isAcceptableOrUnknown(
              data['recognition_status']!, _recognitionStatusMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('condition_code')) {
      context.handle(
          _conditionCodeMeta,
          conditionCode.isAcceptableOrUnknown(
              data['condition_code']!, _conditionCodeMeta));
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
          _encounterIdMeta,
          encounterId.isAcceptableOrUnknown(
              data['encounter_id']!, _encounterIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalReport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      hospitalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hospital_name'])!,
      reportDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}report_date'])!,
      reportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_type'])!,
      sourceImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_image_path']),
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text']),
      recognitionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recognition_status'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      conditionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_code']),
      encounterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}encounter_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicalReportsTable createAlias(String alias) {
    return $MedicalReportsTable(attachedDatabase, alias);
  }
}

class MedicalReport extends DataClass implements Insertable<MedicalReport> {
  final int id;
  final int profileId;
  final String hospitalName;
  final DateTime reportDate;
  final String reportType;
  final String? sourceImagePath;
  final String? rawText;
  final String recognitionStatus;
  final String tags;
  final String? conditionCode;
  final int? encounterId;
  final DateTime createdAt;
  const MedicalReport(
      {required this.id,
      required this.profileId,
      required this.hospitalName,
      required this.reportDate,
      required this.reportType,
      this.sourceImagePath,
      this.rawText,
      required this.recognitionStatus,
      required this.tags,
      this.conditionCode,
      this.encounterId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['hospital_name'] = Variable<String>(hospitalName);
    map['report_date'] = Variable<DateTime>(reportDate);
    map['report_type'] = Variable<String>(reportType);
    if (!nullToAbsent || sourceImagePath != null) {
      map['source_image_path'] = Variable<String>(sourceImagePath);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    map['recognition_status'] = Variable<String>(recognitionStatus);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || conditionCode != null) {
      map['condition_code'] = Variable<String>(conditionCode);
    }
    if (!nullToAbsent || encounterId != null) {
      map['encounter_id'] = Variable<int>(encounterId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicalReportsCompanion toCompanion(bool nullToAbsent) {
    return MedicalReportsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      hospitalName: Value(hospitalName),
      reportDate: Value(reportDate),
      reportType: Value(reportType),
      sourceImagePath: sourceImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceImagePath),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      recognitionStatus: Value(recognitionStatus),
      tags: Value(tags),
      conditionCode: conditionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionCode),
      encounterId: encounterId == null && nullToAbsent
          ? const Value.absent()
          : Value(encounterId),
      createdAt: Value(createdAt),
    );
  }

  factory MedicalReport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalReport(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      hospitalName: serializer.fromJson<String>(json['hospitalName']),
      reportDate: serializer.fromJson<DateTime>(json['reportDate']),
      reportType: serializer.fromJson<String>(json['reportType']),
      sourceImagePath: serializer.fromJson<String?>(json['sourceImagePath']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      recognitionStatus: serializer.fromJson<String>(json['recognitionStatus']),
      tags: serializer.fromJson<String>(json['tags']),
      conditionCode: serializer.fromJson<String?>(json['conditionCode']),
      encounterId: serializer.fromJson<int?>(json['encounterId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'hospitalName': serializer.toJson<String>(hospitalName),
      'reportDate': serializer.toJson<DateTime>(reportDate),
      'reportType': serializer.toJson<String>(reportType),
      'sourceImagePath': serializer.toJson<String?>(sourceImagePath),
      'rawText': serializer.toJson<String?>(rawText),
      'recognitionStatus': serializer.toJson<String>(recognitionStatus),
      'tags': serializer.toJson<String>(tags),
      'conditionCode': serializer.toJson<String?>(conditionCode),
      'encounterId': serializer.toJson<int?>(encounterId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicalReport copyWith(
          {int? id,
          int? profileId,
          String? hospitalName,
          DateTime? reportDate,
          String? reportType,
          Value<String?> sourceImagePath = const Value.absent(),
          Value<String?> rawText = const Value.absent(),
          String? recognitionStatus,
          String? tags,
          Value<String?> conditionCode = const Value.absent(),
          Value<int?> encounterId = const Value.absent(),
          DateTime? createdAt}) =>
      MedicalReport(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        hospitalName: hospitalName ?? this.hospitalName,
        reportDate: reportDate ?? this.reportDate,
        reportType: reportType ?? this.reportType,
        sourceImagePath: sourceImagePath.present
            ? sourceImagePath.value
            : this.sourceImagePath,
        rawText: rawText.present ? rawText.value : this.rawText,
        recognitionStatus: recognitionStatus ?? this.recognitionStatus,
        tags: tags ?? this.tags,
        conditionCode:
            conditionCode.present ? conditionCode.value : this.conditionCode,
        encounterId: encounterId.present ? encounterId.value : this.encounterId,
        createdAt: createdAt ?? this.createdAt,
      );
  MedicalReport copyWithCompanion(MedicalReportsCompanion data) {
    return MedicalReport(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      hospitalName: data.hospitalName.present
          ? data.hospitalName.value
          : this.hospitalName,
      reportDate:
          data.reportDate.present ? data.reportDate.value : this.reportDate,
      reportType:
          data.reportType.present ? data.reportType.value : this.reportType,
      sourceImagePath: data.sourceImagePath.present
          ? data.sourceImagePath.value
          : this.sourceImagePath,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      recognitionStatus: data.recognitionStatus.present
          ? data.recognitionStatus.value
          : this.recognitionStatus,
      tags: data.tags.present ? data.tags.value : this.tags,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      encounterId:
          data.encounterId.present ? data.encounterId.value : this.encounterId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalReport(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('reportDate: $reportDate, ')
          ..write('reportType: $reportType, ')
          ..write('sourceImagePath: $sourceImagePath, ')
          ..write('rawText: $rawText, ')
          ..write('recognitionStatus: $recognitionStatus, ')
          ..write('tags: $tags, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('encounterId: $encounterId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      profileId,
      hospitalName,
      reportDate,
      reportType,
      sourceImagePath,
      rawText,
      recognitionStatus,
      tags,
      conditionCode,
      encounterId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalReport &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.hospitalName == this.hospitalName &&
          other.reportDate == this.reportDate &&
          other.reportType == this.reportType &&
          other.sourceImagePath == this.sourceImagePath &&
          other.rawText == this.rawText &&
          other.recognitionStatus == this.recognitionStatus &&
          other.tags == this.tags &&
          other.conditionCode == this.conditionCode &&
          other.encounterId == this.encounterId &&
          other.createdAt == this.createdAt);
}

class MedicalReportsCompanion extends UpdateCompanion<MedicalReport> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> hospitalName;
  final Value<DateTime> reportDate;
  final Value<String> reportType;
  final Value<String?> sourceImagePath;
  final Value<String?> rawText;
  final Value<String> recognitionStatus;
  final Value<String> tags;
  final Value<String?> conditionCode;
  final Value<int?> encounterId;
  final Value<DateTime> createdAt;
  const MedicalReportsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.hospitalName = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.reportType = const Value.absent(),
    this.sourceImagePath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.recognitionStatus = const Value.absent(),
    this.tags = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicalReportsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String hospitalName,
    required DateTime reportDate,
    required String reportType,
    this.sourceImagePath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.recognitionStatus = const Value.absent(),
    this.tags = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.encounterId = const Value.absent(),
    required DateTime createdAt,
  })  : hospitalName = Value(hospitalName),
        reportDate = Value(reportDate),
        reportType = Value(reportType),
        createdAt = Value(createdAt);
  static Insertable<MedicalReport> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? hospitalName,
    Expression<DateTime>? reportDate,
    Expression<String>? reportType,
    Expression<String>? sourceImagePath,
    Expression<String>? rawText,
    Expression<String>? recognitionStatus,
    Expression<String>? tags,
    Expression<String>? conditionCode,
    Expression<int>? encounterId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (hospitalName != null) 'hospital_name': hospitalName,
      if (reportDate != null) 'report_date': reportDate,
      if (reportType != null) 'report_type': reportType,
      if (sourceImagePath != null) 'source_image_path': sourceImagePath,
      if (rawText != null) 'raw_text': rawText,
      if (recognitionStatus != null) 'recognition_status': recognitionStatus,
      if (tags != null) 'tags': tags,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (encounterId != null) 'encounter_id': encounterId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicalReportsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? hospitalName,
      Value<DateTime>? reportDate,
      Value<String>? reportType,
      Value<String?>? sourceImagePath,
      Value<String?>? rawText,
      Value<String>? recognitionStatus,
      Value<String>? tags,
      Value<String?>? conditionCode,
      Value<int?>? encounterId,
      Value<DateTime>? createdAt}) {
    return MedicalReportsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      hospitalName: hospitalName ?? this.hospitalName,
      reportDate: reportDate ?? this.reportDate,
      reportType: reportType ?? this.reportType,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      rawText: rawText ?? this.rawText,
      recognitionStatus: recognitionStatus ?? this.recognitionStatus,
      tags: tags ?? this.tags,
      conditionCode: conditionCode ?? this.conditionCode,
      encounterId: encounterId ?? this.encounterId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (hospitalName.present) {
      map['hospital_name'] = Variable<String>(hospitalName.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<DateTime>(reportDate.value);
    }
    if (reportType.present) {
      map['report_type'] = Variable<String>(reportType.value);
    }
    if (sourceImagePath.present) {
      map['source_image_path'] = Variable<String>(sourceImagePath.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (recognitionStatus.present) {
      map['recognition_status'] = Variable<String>(recognitionStatus.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<int>(encounterId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalReportsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('reportDate: $reportDate, ')
          ..write('reportType: $reportType, ')
          ..write('sourceImagePath: $sourceImagePath, ')
          ..write('rawText: $rawText, ')
          ..write('recognitionStatus: $recognitionStatus, ')
          ..write('tags: $tags, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('encounterId: $encounterId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DiseasesTable extends Diseases with TableInfo<$DiseasesTable, Disease> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiseasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foundDateMeta =
      const VerificationMeta('foundDate');
  @override
  late final GeneratedColumn<DateTime> foundDate = GeneratedColumn<DateTime>(
      'found_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('不确定'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _conditionCodeMeta =
      const VerificationMeta('conditionCode');
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
      'condition_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _diagnosisBasisMeta =
      const VerificationMeta('diagnosisBasis');
  @override
  late final GeneratedColumn<String> diagnosisBasis = GeneratedColumn<String>(
      'diagnosis_basis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        name,
        foundDate,
        status,
        notes,
        createdAt,
        conditionCode,
        stage,
        diagnosisBasis
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diseases';
  @override
  VerificationContext validateIntegrity(Insertable<Disease> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('found_date')) {
      context.handle(_foundDateMeta,
          foundDate.isAcceptableOrUnknown(data['found_date']!, _foundDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('condition_code')) {
      context.handle(
          _conditionCodeMeta,
          conditionCode.isAcceptableOrUnknown(
              data['condition_code']!, _conditionCodeMeta));
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    }
    if (data.containsKey('diagnosis_basis')) {
      context.handle(
          _diagnosisBasisMeta,
          diagnosisBasis.isAcceptableOrUnknown(
              data['diagnosis_basis']!, _diagnosisBasisMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Disease map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Disease(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      foundDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}found_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      conditionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_code']),
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage']),
      diagnosisBasis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis_basis']),
    );
  }

  @override
  $DiseasesTable createAlias(String alias) {
    return $DiseasesTable(attachedDatabase, alias);
  }
}

class Disease extends DataClass implements Insertable<Disease> {
  final int id;
  final int profileId;
  final String name;
  final DateTime? foundDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String? conditionCode;
  final String? stage;
  final String? diagnosisBasis;
  const Disease(
      {required this.id,
      required this.profileId,
      required this.name,
      this.foundDate,
      required this.status,
      this.notes,
      required this.createdAt,
      this.conditionCode,
      this.stage,
      this.diagnosisBasis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || foundDate != null) {
      map['found_date'] = Variable<DateTime>(foundDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || conditionCode != null) {
      map['condition_code'] = Variable<String>(conditionCode);
    }
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || diagnosisBasis != null) {
      map['diagnosis_basis'] = Variable<String>(diagnosisBasis);
    }
    return map;
  }

  DiseasesCompanion toCompanion(bool nullToAbsent) {
    return DiseasesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      foundDate: foundDate == null && nullToAbsent
          ? const Value.absent()
          : Value(foundDate),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      conditionCode: conditionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionCode),
      stage:
          stage == null && nullToAbsent ? const Value.absent() : Value(stage),
      diagnosisBasis: diagnosisBasis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosisBasis),
    );
  }

  factory Disease.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Disease(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      foundDate: serializer.fromJson<DateTime?>(json['foundDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      conditionCode: serializer.fromJson<String?>(json['conditionCode']),
      stage: serializer.fromJson<String?>(json['stage']),
      diagnosisBasis: serializer.fromJson<String?>(json['diagnosisBasis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'foundDate': serializer.toJson<DateTime?>(foundDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'conditionCode': serializer.toJson<String?>(conditionCode),
      'stage': serializer.toJson<String?>(stage),
      'diagnosisBasis': serializer.toJson<String?>(diagnosisBasis),
    };
  }

  Disease copyWith(
          {int? id,
          int? profileId,
          String? name,
          Value<DateTime?> foundDate = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<String?> conditionCode = const Value.absent(),
          Value<String?> stage = const Value.absent(),
          Value<String?> diagnosisBasis = const Value.absent()}) =>
      Disease(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        foundDate: foundDate.present ? foundDate.value : this.foundDate,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        conditionCode:
            conditionCode.present ? conditionCode.value : this.conditionCode,
        stage: stage.present ? stage.value : this.stage,
        diagnosisBasis:
            diagnosisBasis.present ? diagnosisBasis.value : this.diagnosisBasis,
      );
  Disease copyWithCompanion(DiseasesCompanion data) {
    return Disease(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      foundDate: data.foundDate.present ? data.foundDate.value : this.foundDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      stage: data.stage.present ? data.stage.value : this.stage,
      diagnosisBasis: data.diagnosisBasis.present
          ? data.diagnosisBasis.value
          : this.diagnosisBasis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Disease(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('foundDate: $foundDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('stage: $stage, ')
          ..write('diagnosisBasis: $diagnosisBasis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, name, foundDate, status, notes,
      createdAt, conditionCode, stage, diagnosisBasis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Disease &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.foundDate == this.foundDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.conditionCode == this.conditionCode &&
          other.stage == this.stage &&
          other.diagnosisBasis == this.diagnosisBasis);
}

class DiseasesCompanion extends UpdateCompanion<Disease> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<DateTime?> foundDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> conditionCode;
  final Value<String?> stage;
  final Value<String?> diagnosisBasis;
  const DiseasesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.foundDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.stage = const Value.absent(),
    this.diagnosisBasis = const Value.absent(),
  });
  DiseasesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    this.foundDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.conditionCode = const Value.absent(),
    this.stage = const Value.absent(),
    this.diagnosisBasis = const Value.absent(),
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Disease> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<DateTime>? foundDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? conditionCode,
    Expression<String>? stage,
    Expression<String>? diagnosisBasis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (foundDate != null) 'found_date': foundDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (stage != null) 'stage': stage,
      if (diagnosisBasis != null) 'diagnosis_basis': diagnosisBasis,
    });
  }

  DiseasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? name,
      Value<DateTime?>? foundDate,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<String?>? conditionCode,
      Value<String?>? stage,
      Value<String?>? diagnosisBasis}) {
    return DiseasesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      foundDate: foundDate ?? this.foundDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      conditionCode: conditionCode ?? this.conditionCode,
      stage: stage ?? this.stage,
      diagnosisBasis: diagnosisBasis ?? this.diagnosisBasis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (foundDate.present) {
      map['found_date'] = Variable<DateTime>(foundDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (diagnosisBasis.present) {
      map['diagnosis_basis'] = Variable<String>(diagnosisBasis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiseasesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('foundDate: $foundDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('stage: $stage, ')
          ..write('diagnosisBasis: $diagnosisBasis')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dosageUnitMeta =
      const VerificationMeta('dosageUnit');
  @override
  late final GeneratedColumn<String> dosageUnit = GeneratedColumn<String>(
      'dosage_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<String> usage = GeneratedColumn<String>(
      'usage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timesPerDayMeta =
      const VerificationMeta('timesPerDay');
  @override
  late final GeneratedColumn<String> timesPerDay = GeneratedColumn<String>(
      'times_per_day', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('当前使用'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conditionCodeMeta =
      const VerificationMeta('conditionCode');
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
      'condition_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        name,
        dosage,
        dosageUnit,
        usage,
        timesPerDay,
        startDate,
        endDate,
        status,
        notes,
        conditionCode,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(Insertable<Medication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    }
    if (data.containsKey('dosage_unit')) {
      context.handle(
          _dosageUnitMeta,
          dosageUnit.isAcceptableOrUnknown(
              data['dosage_unit']!, _dosageUnitMeta));
    }
    if (data.containsKey('usage')) {
      context.handle(
          _usageMeta, usage.isAcceptableOrUnknown(data['usage']!, _usageMeta));
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
          _timesPerDayMeta,
          timesPerDay.isAcceptableOrUnknown(
              data['times_per_day']!, _timesPerDayMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('condition_code')) {
      context.handle(
          _conditionCodeMeta,
          conditionCode.isAcceptableOrUnknown(
              data['condition_code']!, _conditionCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage']),
      dosageUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage_unit']),
      usage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usage']),
      timesPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}times_per_day']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      conditionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final int profileId;
  final String name;
  final String? dosage;
  final String? dosageUnit;
  final String? usage;
  final String? timesPerDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final String? conditionCode;
  final DateTime createdAt;
  const Medication(
      {required this.id,
      required this.profileId,
      required this.name,
      this.dosage,
      this.dosageUnit,
      this.usage,
      this.timesPerDay,
      this.startDate,
      this.endDate,
      required this.status,
      this.notes,
      this.conditionCode,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || dosageUnit != null) {
      map['dosage_unit'] = Variable<String>(dosageUnit);
    }
    if (!nullToAbsent || usage != null) {
      map['usage'] = Variable<String>(usage);
    }
    if (!nullToAbsent || timesPerDay != null) {
      map['times_per_day'] = Variable<String>(timesPerDay);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || conditionCode != null) {
      map['condition_code'] = Variable<String>(conditionCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      dosage:
          dosage == null && nullToAbsent ? const Value.absent() : Value(dosage),
      dosageUnit: dosageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageUnit),
      usage:
          usage == null && nullToAbsent ? const Value.absent() : Value(usage),
      timesPerDay: timesPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timesPerDay),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      conditionCode: conditionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionCode),
      createdAt: Value(createdAt),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      dosageUnit: serializer.fromJson<String?>(json['dosageUnit']),
      usage: serializer.fromJson<String?>(json['usage']),
      timesPerDay: serializer.fromJson<String?>(json['timesPerDay']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      conditionCode: serializer.fromJson<String?>(json['conditionCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String?>(dosage),
      'dosageUnit': serializer.toJson<String?>(dosageUnit),
      'usage': serializer.toJson<String?>(usage),
      'timesPerDay': serializer.toJson<String?>(timesPerDay),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'conditionCode': serializer.toJson<String?>(conditionCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Medication copyWith(
          {int? id,
          int? profileId,
          String? name,
          Value<String?> dosage = const Value.absent(),
          Value<String?> dosageUnit = const Value.absent(),
          Value<String?> usage = const Value.absent(),
          Value<String?> timesPerDay = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> conditionCode = const Value.absent(),
          DateTime? createdAt}) =>
      Medication(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        dosage: dosage.present ? dosage.value : this.dosage,
        dosageUnit: dosageUnit.present ? dosageUnit.value : this.dosageUnit,
        usage: usage.present ? usage.value : this.usage,
        timesPerDay: timesPerDay.present ? timesPerDay.value : this.timesPerDay,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        conditionCode:
            conditionCode.present ? conditionCode.value : this.conditionCode,
        createdAt: createdAt ?? this.createdAt,
      );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      dosageUnit:
          data.dosageUnit.present ? data.dosageUnit.value : this.dosageUnit,
      usage: data.usage.present ? data.usage.value : this.usage,
      timesPerDay:
          data.timesPerDay.present ? data.timesPerDay.value : this.timesPerDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('dosageUnit: $dosageUnit, ')
          ..write('usage: $usage, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      profileId,
      name,
      dosage,
      dosageUnit,
      usage,
      timesPerDay,
      startDate,
      endDate,
      status,
      notes,
      conditionCode,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.dosageUnit == this.dosageUnit &&
          other.usage == this.usage &&
          other.timesPerDay == this.timesPerDay &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.conditionCode == this.conditionCode &&
          other.createdAt == this.createdAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<String?> dosage;
  final Value<String?> dosageUnit;
  final Value<String?> usage;
  final Value<String?> timesPerDay;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> conditionCode;
  final Value<DateTime> createdAt;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.usage = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.usage = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.conditionCode = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? dosageUnit,
    Expression<String>? usage,
    Expression<String>? timesPerDay,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? conditionCode,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (dosageUnit != null) 'dosage_unit': dosageUnit,
      if (usage != null) 'usage': usage,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? name,
      Value<String?>? dosage,
      Value<String?>? dosageUnit,
      Value<String?>? usage,
      Value<String?>? timesPerDay,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? conditionCode,
      Value<DateTime>? createdAt}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      usage: usage ?? this.usage,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      conditionCode: conditionCode ?? this.conditionCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (dosageUnit.present) {
      map['dosage_unit'] = Variable<String>(dosageUnit.value);
    }
    if (usage.present) {
      map['usage'] = Variable<String>(usage.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<String>(timesPerDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('dosageUnit: $dosageUnit, ')
          ..write('usage: $usage, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nickname, gender, birthDate, heightCm, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String nickname;
  final String gender;
  final DateTime? birthDate;
  final double? heightCm;
  final DateTime? updatedAt;
  const UserProfileData(
      {required this.id,
      required this.nickname,
      required this.gender,
      this.birthDate,
      this.heightCm,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      nickname: Value(nickname),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'heightCm': serializer.toJson<double?>(heightCm),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserProfileData copyWith(
          {int? id,
          String? nickname,
          String? gender,
          Value<DateTime?> birthDate = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      UserProfileData(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        gender: gender ?? this.gender,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nickname, gender, birthDate, heightCm, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.heightCm == this.heightCm &&
          other.updatedAt == this.updatedAt);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> gender;
  final Value<DateTime?> birthDate;
  final Value<double?> heightCm;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileCompanion.insert({
    required int id,
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<double>? heightCm,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (heightCm != null) 'height_cm': heightCm,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileCompanion copyWith(
      {Value<int>? id,
      Value<String>? nickname,
      Value<String>? gender,
      Value<DateTime?>? birthDate,
      Value<double?>? heightCm,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return UserProfileCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonProfilesTable extends PersonProfiles
    with TableInfo<$PersonProfilesTable, PersonProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('本人'));
  static const VerificationMeta _relationshipMeta =
      const VerificationMeta('relationship');
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
      'relationship', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('self'));
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _knownNamesMeta =
      const VerificationMeta('knownNames');
  @override
  late final GeneratedColumn<String> knownNames = GeneratedColumn<String>(
      'known_names', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        relationship,
        sex,
        dateOfBirth,
        heightCm,
        knownNames,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<PersonProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('relationship')) {
      context.handle(
          _relationshipMeta,
          relationship.isAcceptableOrUnknown(
              data['relationship']!, _relationshipMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('known_names')) {
      context.handle(
          _knownNamesMeta,
          knownNames.isAcceptableOrUnknown(
              data['known_names']!, _knownNamesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      relationship: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relationship'])!,
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      knownNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}known_names'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PersonProfilesTable createAlias(String alias) {
    return $PersonProfilesTable(attachedDatabase, alias);
  }
}

class PersonProfile extends DataClass implements Insertable<PersonProfile> {
  final int id;
  final String displayName;
  final String relationship;
  final String? sex;
  final DateTime? dateOfBirth;
  final double? heightCm;

  /// 这个档案「认识的真实姓名」，逗号分隔。首次存报告时用 OCR 姓名自动填入，
  /// 之后每次存报告拿 OCR 姓名与之比对，明显不一致才提醒（防止存错家庭成员）。
  /// 用户在提醒里选「仍存这里」会把新名字并进来。空 = 还没记过，不比对。
  final String knownNames;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonProfile(
      {required this.id,
      required this.displayName,
      required this.relationship,
      this.sex,
      this.dateOfBirth,
      this.heightCm,
      required this.knownNames,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['relationship'] = Variable<String>(relationship);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    map['known_names'] = Variable<String>(knownNames);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonProfilesCompanion toCompanion(bool nullToAbsent) {
    return PersonProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      relationship: Value(relationship),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      knownNames: Value(knownNames),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonProfile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      relationship: serializer.fromJson<String>(json['relationship']),
      sex: serializer.fromJson<String?>(json['sex']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      knownNames: serializer.fromJson<String>(json['knownNames']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'relationship': serializer.toJson<String>(relationship),
      'sex': serializer.toJson<String?>(sex),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'heightCm': serializer.toJson<double?>(heightCm),
      'knownNames': serializer.toJson<String>(knownNames),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonProfile copyWith(
          {int? id,
          String? displayName,
          String? relationship,
          Value<String?> sex = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          String? knownNames,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PersonProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        relationship: relationship ?? this.relationship,
        sex: sex.present ? sex.value : this.sex,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        knownNames: knownNames ?? this.knownNames,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PersonProfile copyWithCompanion(PersonProfilesCompanion data) {
    return PersonProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      sex: data.sex.present ? data.sex.value : this.sex,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      knownNames:
          data.knownNames.present ? data.knownNames.value : this.knownNames,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('sex: $sex, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('knownNames: $knownNames, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, relationship, sex,
      dateOfBirth, heightCm, knownNames, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.relationship == this.relationship &&
          other.sex == this.sex &&
          other.dateOfBirth == this.dateOfBirth &&
          other.heightCm == this.heightCm &&
          other.knownNames == this.knownNames &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonProfilesCompanion extends UpdateCompanion<PersonProfile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> relationship;
  final Value<String?> sex;
  final Value<DateTime?> dateOfBirth;
  final Value<double?> heightCm;
  final Value<String> knownNames;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PersonProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.knownNames = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PersonProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.knownNames = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PersonProfile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? relationship,
    Expression<String>? sex,
    Expression<DateTime>? dateOfBirth,
    Expression<double>? heightCm,
    Expression<String>? knownNames,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (relationship != null) 'relationship': relationship,
      if (sex != null) 'sex': sex,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (heightCm != null) 'height_cm': heightCm,
      if (knownNames != null) 'known_names': knownNames,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PersonProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? displayName,
      Value<String>? relationship,
      Value<String?>? sex,
      Value<DateTime?>? dateOfBirth,
      Value<double?>? heightCm,
      Value<String>? knownNames,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PersonProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      relationship: relationship ?? this.relationship,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      knownNames: knownNames ?? this.knownNames,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (knownNames.present) {
      map['known_names'] = Variable<String>(knownNames.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('sex: $sex, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('knownNames: $knownNames, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conditionCodeMeta =
      const VerificationMeta('conditionCode');
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
      'condition_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _followUpKeyMeta =
      const VerificationMeta('followUpKey');
  @override
  late final GeneratedColumn<String> followUpKey = GeneratedColumn<String>(
      'follow_up_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoGeneratedMeta =
      const VerificationMeta('autoGenerated');
  @override
  late final GeneratedColumn<bool> autoGenerated = GeneratedColumn<bool>(
      'auto_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _areaNameMeta =
      const VerificationMeta('areaName');
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
      'area_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recommendedDateMeta =
      const VerificationMeta('recommendedDate');
  @override
  late final GeneratedColumn<DateTime> recommendedDate =
      GeneratedColumn<DateTime>('recommended_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedMetricIdMeta =
      const VerificationMeta('relatedMetricId');
  @override
  late final GeneratedColumn<String> relatedMetricId = GeneratedColumn<String>(
      'related_metric_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedMedicationIdMeta =
      const VerificationMeta('relatedMedicationId');
  @override
  late final GeneratedColumn<int> relatedMedicationId = GeneratedColumn<int>(
      'related_medication_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dailyTimesMeta =
      const VerificationMeta('dailyTimes');
  @override
  late final GeneratedColumn<String> dailyTimes = GeneratedColumn<String>(
      'daily_times', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        kind,
        conditionCode,
        followUpKey,
        autoGenerated,
        sourceType,
        areaName,
        recommendedDate,
        title,
        detail,
        relatedMetricId,
        relatedMedicationId,
        dueDate,
        dailyTimes,
        enabled,
        completedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('condition_code')) {
      context.handle(
          _conditionCodeMeta,
          conditionCode.isAcceptableOrUnknown(
              data['condition_code']!, _conditionCodeMeta));
    }
    if (data.containsKey('follow_up_key')) {
      context.handle(
          _followUpKeyMeta,
          followUpKey.isAcceptableOrUnknown(
              data['follow_up_key']!, _followUpKeyMeta));
    }
    if (data.containsKey('auto_generated')) {
      context.handle(
          _autoGeneratedMeta,
          autoGenerated.isAcceptableOrUnknown(
              data['auto_generated']!, _autoGeneratedMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('area_name')) {
      context.handle(_areaNameMeta,
          areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta));
    }
    if (data.containsKey('recommended_date')) {
      context.handle(
          _recommendedDateMeta,
          recommendedDate.isAcceptableOrUnknown(
              data['recommended_date']!, _recommendedDateMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('related_metric_id')) {
      context.handle(
          _relatedMetricIdMeta,
          relatedMetricId.isAcceptableOrUnknown(
              data['related_metric_id']!, _relatedMetricIdMeta));
    }
    if (data.containsKey('related_medication_id')) {
      context.handle(
          _relatedMedicationIdMeta,
          relatedMedicationId.isAcceptableOrUnknown(
              data['related_medication_id']!, _relatedMedicationIdMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('daily_times')) {
      context.handle(
          _dailyTimesMeta,
          dailyTimes.isAcceptableOrUnknown(
              data['daily_times']!, _dailyTimesMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      conditionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_code']),
      followUpKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}follow_up_key']),
      autoGenerated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_generated'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      areaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_name']),
      recommendedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}recommended_date']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      relatedMetricId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_metric_id']),
      relatedMedicationId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}related_medication_id']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      dailyTimes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}daily_times']),
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int profileId;
  final String kind;
  final String? conditionCode;
  final String? followUpKey;
  final bool autoGenerated;
  final String sourceType;
  final String? areaName;
  final DateTime? recommendedDate;
  final String title;
  final String? detail;
  final String? relatedMetricId;
  final int? relatedMedicationId;
  final DateTime? dueDate;
  final String? dailyTimes;
  final bool enabled;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Reminder(
      {required this.id,
      required this.profileId,
      required this.kind,
      this.conditionCode,
      this.followUpKey,
      required this.autoGenerated,
      required this.sourceType,
      this.areaName,
      this.recommendedDate,
      required this.title,
      this.detail,
      this.relatedMetricId,
      this.relatedMedicationId,
      this.dueDate,
      this.dailyTimes,
      required this.enabled,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || conditionCode != null) {
      map['condition_code'] = Variable<String>(conditionCode);
    }
    if (!nullToAbsent || followUpKey != null) {
      map['follow_up_key'] = Variable<String>(followUpKey);
    }
    map['auto_generated'] = Variable<bool>(autoGenerated);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || areaName != null) {
      map['area_name'] = Variable<String>(areaName);
    }
    if (!nullToAbsent || recommendedDate != null) {
      map['recommended_date'] = Variable<DateTime>(recommendedDate);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    if (!nullToAbsent || relatedMetricId != null) {
      map['related_metric_id'] = Variable<String>(relatedMetricId);
    }
    if (!nullToAbsent || relatedMedicationId != null) {
      map['related_medication_id'] = Variable<int>(relatedMedicationId);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || dailyTimes != null) {
      map['daily_times'] = Variable<String>(dailyTimes);
    }
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      profileId: Value(profileId),
      kind: Value(kind),
      conditionCode: conditionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionCode),
      followUpKey: followUpKey == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpKey),
      autoGenerated: Value(autoGenerated),
      sourceType: Value(sourceType),
      areaName: areaName == null && nullToAbsent
          ? const Value.absent()
          : Value(areaName),
      recommendedDate: recommendedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedDate),
      title: Value(title),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
      relatedMetricId: relatedMetricId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedMetricId),
      relatedMedicationId: relatedMedicationId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedMedicationId),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dailyTimes: dailyTimes == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyTimes),
      enabled: Value(enabled),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      kind: serializer.fromJson<String>(json['kind']),
      conditionCode: serializer.fromJson<String?>(json['conditionCode']),
      followUpKey: serializer.fromJson<String?>(json['followUpKey']),
      autoGenerated: serializer.fromJson<bool>(json['autoGenerated']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      areaName: serializer.fromJson<String?>(json['areaName']),
      recommendedDate: serializer.fromJson<DateTime?>(json['recommendedDate']),
      title: serializer.fromJson<String>(json['title']),
      detail: serializer.fromJson<String?>(json['detail']),
      relatedMetricId: serializer.fromJson<String?>(json['relatedMetricId']),
      relatedMedicationId:
          serializer.fromJson<int?>(json['relatedMedicationId']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      dailyTimes: serializer.fromJson<String?>(json['dailyTimes']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'kind': serializer.toJson<String>(kind),
      'conditionCode': serializer.toJson<String?>(conditionCode),
      'followUpKey': serializer.toJson<String?>(followUpKey),
      'autoGenerated': serializer.toJson<bool>(autoGenerated),
      'sourceType': serializer.toJson<String>(sourceType),
      'areaName': serializer.toJson<String?>(areaName),
      'recommendedDate': serializer.toJson<DateTime?>(recommendedDate),
      'title': serializer.toJson<String>(title),
      'detail': serializer.toJson<String?>(detail),
      'relatedMetricId': serializer.toJson<String?>(relatedMetricId),
      'relatedMedicationId': serializer.toJson<int?>(relatedMedicationId),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'dailyTimes': serializer.toJson<String?>(dailyTimes),
      'enabled': serializer.toJson<bool>(enabled),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith(
          {int? id,
          int? profileId,
          String? kind,
          Value<String?> conditionCode = const Value.absent(),
          Value<String?> followUpKey = const Value.absent(),
          bool? autoGenerated,
          String? sourceType,
          Value<String?> areaName = const Value.absent(),
          Value<DateTime?> recommendedDate = const Value.absent(),
          String? title,
          Value<String?> detail = const Value.absent(),
          Value<String?> relatedMetricId = const Value.absent(),
          Value<int?> relatedMedicationId = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> dailyTimes = const Value.absent(),
          bool? enabled,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Reminder(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        kind: kind ?? this.kind,
        conditionCode:
            conditionCode.present ? conditionCode.value : this.conditionCode,
        followUpKey: followUpKey.present ? followUpKey.value : this.followUpKey,
        autoGenerated: autoGenerated ?? this.autoGenerated,
        sourceType: sourceType ?? this.sourceType,
        areaName: areaName.present ? areaName.value : this.areaName,
        recommendedDate: recommendedDate.present
            ? recommendedDate.value
            : this.recommendedDate,
        title: title ?? this.title,
        detail: detail.present ? detail.value : this.detail,
        relatedMetricId: relatedMetricId.present
            ? relatedMetricId.value
            : this.relatedMetricId,
        relatedMedicationId: relatedMedicationId.present
            ? relatedMedicationId.value
            : this.relatedMedicationId,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        dailyTimes: dailyTimes.present ? dailyTimes.value : this.dailyTimes,
        enabled: enabled ?? this.enabled,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      kind: data.kind.present ? data.kind.value : this.kind,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      followUpKey:
          data.followUpKey.present ? data.followUpKey.value : this.followUpKey,
      autoGenerated: data.autoGenerated.present
          ? data.autoGenerated.value
          : this.autoGenerated,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      recommendedDate: data.recommendedDate.present
          ? data.recommendedDate.value
          : this.recommendedDate,
      title: data.title.present ? data.title.value : this.title,
      detail: data.detail.present ? data.detail.value : this.detail,
      relatedMetricId: data.relatedMetricId.present
          ? data.relatedMetricId.value
          : this.relatedMetricId,
      relatedMedicationId: data.relatedMedicationId.present
          ? data.relatedMedicationId.value
          : this.relatedMedicationId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dailyTimes:
          data.dailyTimes.present ? data.dailyTimes.value : this.dailyTimes,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('followUpKey: $followUpKey, ')
          ..write('autoGenerated: $autoGenerated, ')
          ..write('sourceType: $sourceType, ')
          ..write('areaName: $areaName, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('relatedMetricId: $relatedMetricId, ')
          ..write('relatedMedicationId: $relatedMedicationId, ')
          ..write('dueDate: $dueDate, ')
          ..write('dailyTimes: $dailyTimes, ')
          ..write('enabled: $enabled, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      profileId,
      kind,
      conditionCode,
      followUpKey,
      autoGenerated,
      sourceType,
      areaName,
      recommendedDate,
      title,
      detail,
      relatedMetricId,
      relatedMedicationId,
      dueDate,
      dailyTimes,
      enabled,
      completedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.kind == this.kind &&
          other.conditionCode == this.conditionCode &&
          other.followUpKey == this.followUpKey &&
          other.autoGenerated == this.autoGenerated &&
          other.sourceType == this.sourceType &&
          other.areaName == this.areaName &&
          other.recommendedDate == this.recommendedDate &&
          other.title == this.title &&
          other.detail == this.detail &&
          other.relatedMetricId == this.relatedMetricId &&
          other.relatedMedicationId == this.relatedMedicationId &&
          other.dueDate == this.dueDate &&
          other.dailyTimes == this.dailyTimes &&
          other.enabled == this.enabled &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> kind;
  final Value<String?> conditionCode;
  final Value<String?> followUpKey;
  final Value<bool> autoGenerated;
  final Value<String> sourceType;
  final Value<String?> areaName;
  final Value<DateTime?> recommendedDate;
  final Value<String> title;
  final Value<String?> detail;
  final Value<String?> relatedMetricId;
  final Value<int?> relatedMedicationId;
  final Value<DateTime?> dueDate;
  final Value<String?> dailyTimes;
  final Value<bool> enabled;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.kind = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.followUpKey = const Value.absent(),
    this.autoGenerated = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.areaName = const Value.absent(),
    this.recommendedDate = const Value.absent(),
    this.title = const Value.absent(),
    this.detail = const Value.absent(),
    this.relatedMetricId = const Value.absent(),
    this.relatedMedicationId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dailyTimes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String kind,
    this.conditionCode = const Value.absent(),
    this.followUpKey = const Value.absent(),
    this.autoGenerated = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.areaName = const Value.absent(),
    this.recommendedDate = const Value.absent(),
    required String title,
    this.detail = const Value.absent(),
    this.relatedMetricId = const Value.absent(),
    this.relatedMedicationId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dailyTimes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : kind = Value(kind),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? kind,
    Expression<String>? conditionCode,
    Expression<String>? followUpKey,
    Expression<bool>? autoGenerated,
    Expression<String>? sourceType,
    Expression<String>? areaName,
    Expression<DateTime>? recommendedDate,
    Expression<String>? title,
    Expression<String>? detail,
    Expression<String>? relatedMetricId,
    Expression<int>? relatedMedicationId,
    Expression<DateTime>? dueDate,
    Expression<String>? dailyTimes,
    Expression<bool>? enabled,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (kind != null) 'kind': kind,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (followUpKey != null) 'follow_up_key': followUpKey,
      if (autoGenerated != null) 'auto_generated': autoGenerated,
      if (sourceType != null) 'source_type': sourceType,
      if (areaName != null) 'area_name': areaName,
      if (recommendedDate != null) 'recommended_date': recommendedDate,
      if (title != null) 'title': title,
      if (detail != null) 'detail': detail,
      if (relatedMetricId != null) 'related_metric_id': relatedMetricId,
      if (relatedMedicationId != null)
        'related_medication_id': relatedMedicationId,
      if (dueDate != null) 'due_date': dueDate,
      if (dailyTimes != null) 'daily_times': dailyTimes,
      if (enabled != null) 'enabled': enabled,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? kind,
      Value<String?>? conditionCode,
      Value<String?>? followUpKey,
      Value<bool>? autoGenerated,
      Value<String>? sourceType,
      Value<String?>? areaName,
      Value<DateTime?>? recommendedDate,
      Value<String>? title,
      Value<String?>? detail,
      Value<String?>? relatedMetricId,
      Value<int?>? relatedMedicationId,
      Value<DateTime?>? dueDate,
      Value<String?>? dailyTimes,
      Value<bool>? enabled,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return RemindersCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      kind: kind ?? this.kind,
      conditionCode: conditionCode ?? this.conditionCode,
      followUpKey: followUpKey ?? this.followUpKey,
      autoGenerated: autoGenerated ?? this.autoGenerated,
      sourceType: sourceType ?? this.sourceType,
      areaName: areaName ?? this.areaName,
      recommendedDate: recommendedDate ?? this.recommendedDate,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      relatedMetricId: relatedMetricId ?? this.relatedMetricId,
      relatedMedicationId: relatedMedicationId ?? this.relatedMedicationId,
      dueDate: dueDate ?? this.dueDate,
      dailyTimes: dailyTimes ?? this.dailyTimes,
      enabled: enabled ?? this.enabled,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (followUpKey.present) {
      map['follow_up_key'] = Variable<String>(followUpKey.value);
    }
    if (autoGenerated.present) {
      map['auto_generated'] = Variable<bool>(autoGenerated.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (recommendedDate.present) {
      map['recommended_date'] = Variable<DateTime>(recommendedDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (relatedMetricId.present) {
      map['related_metric_id'] = Variable<String>(relatedMetricId.value);
    }
    if (relatedMedicationId.present) {
      map['related_medication_id'] = Variable<int>(relatedMedicationId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dailyTimes.present) {
      map['daily_times'] = Variable<String>(dailyTimes.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('followUpKey: $followUpKey, ')
          ..write('autoGenerated: $autoGenerated, ')
          ..write('sourceType: $sourceType, ')
          ..write('areaName: $areaName, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('relatedMetricId: $relatedMetricId, ')
          ..write('relatedMedicationId: $relatedMedicationId, ')
          ..write('dueDate: $dueDate, ')
          ..write('dailyTimes: $dailyTimes, ')
          ..write('enabled: $enabled, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reminderIdMeta =
      const VerificationMeta('reminderId');
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
      'reminder_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledForMeta =
      const VerificationMeta('scheduledFor');
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
      'scheduled_for', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deliveredAtMeta =
      const VerificationMeta('deliveredAt');
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
      'delivered_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _channelMeta =
      const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
      'channel', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        reminderId,
        category,
        title,
        body,
        scheduledFor,
        deliveredAt,
        readAt,
        channel,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
          _reminderIdMeta,
          reminderId.isAcceptableOrUnknown(
              data['reminder_id']!, _reminderIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
          _scheduledForMeta,
          scheduledFor.isAcceptableOrUnknown(
              data['scheduled_for']!, _scheduledForMeta));
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
          _deliveredAtMeta,
          deliveredAt.isAcceptableOrUnknown(
              data['delivered_at']!, _deliveredAtMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta,
          channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      reminderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      scheduledFor: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_for'])!,
      deliveredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}delivered_at']),
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
      channel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRecord extends DataClass
    implements Insertable<NotificationRecord> {
  final int id;
  final int profileId;
  final int? reminderId;
  final String category;
  final String title;
  final String? body;
  final DateTime scheduledFor;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String channel;
  final DateTime createdAt;
  const NotificationRecord(
      {required this.id,
      required this.profileId,
      this.reminderId,
      required this.category,
      required this.title,
      this.body,
      required this.scheduledFor,
      this.deliveredAt,
      this.readAt,
      required this.channel,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    if (!nullToAbsent || reminderId != null) {
      map['reminder_id'] = Variable<int>(reminderId);
    }
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['channel'] = Variable<String>(channel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      reminderId: reminderId == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderId),
      category: Value(category),
      title: Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      scheduledFor: Value(scheduledFor),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
      channel: Value(channel),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRecord(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      reminderId: serializer.fromJson<int?>(json['reminderId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      channel: serializer.fromJson<String>(json['channel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'reminderId': serializer.toJson<int?>(reminderId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String?>(body),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'channel': serializer.toJson<String>(channel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRecord copyWith(
          {int? id,
          int? profileId,
          Value<int?> reminderId = const Value.absent(),
          String? category,
          String? title,
          Value<String?> body = const Value.absent(),
          DateTime? scheduledFor,
          Value<DateTime?> deliveredAt = const Value.absent(),
          Value<DateTime?> readAt = const Value.absent(),
          String? channel,
          DateTime? createdAt}) =>
      NotificationRecord(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        reminderId: reminderId.present ? reminderId.value : this.reminderId,
        category: category ?? this.category,
        title: title ?? this.title,
        body: body.present ? body.value : this.body,
        scheduledFor: scheduledFor ?? this.scheduledFor,
        deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
        readAt: readAt.present ? readAt.value : this.readAt,
        channel: channel ?? this.channel,
        createdAt: createdAt ?? this.createdAt,
      );
  NotificationRecord copyWithCompanion(NotificationsCompanion data) {
    return NotificationRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      reminderId:
          data.reminderId.present ? data.reminderId.value : this.reminderId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      deliveredAt:
          data.deliveredAt.present ? data.deliveredAt.value : this.deliveredAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      channel: data.channel.present ? data.channel.value : this.channel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('reminderId: $reminderId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt, ')
          ..write('channel: $channel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, reminderId, category, title,
      body, scheduledFor, deliveredAt, readAt, channel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.reminderId == this.reminderId &&
          other.category == this.category &&
          other.title == this.title &&
          other.body == this.body &&
          other.scheduledFor == this.scheduledFor &&
          other.deliveredAt == this.deliveredAt &&
          other.readAt == this.readAt &&
          other.channel == this.channel &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRecord> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int?> reminderId;
  final Value<String> category;
  final Value<String> title;
  final Value<String?> body;
  final Value<DateTime> scheduledFor;
  final Value<DateTime?> deliveredAt;
  final Value<DateTime?> readAt;
  final Value<String> channel;
  final Value<DateTime> createdAt;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.channel = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.reminderId = const Value.absent(),
    required String category,
    required String title,
    this.body = const Value.absent(),
    required DateTime scheduledFor,
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.channel = const Value.absent(),
    required DateTime createdAt,
  })  : category = Value(category),
        title = Value(title),
        scheduledFor = Value(scheduledFor),
        createdAt = Value(createdAt);
  static Insertable<NotificationRecord> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? reminderId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? scheduledFor,
    Expression<DateTime>? deliveredAt,
    Expression<DateTime>? readAt,
    Expression<String>? channel,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (reminderId != null) 'reminder_id': reminderId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (readAt != null) 'read_at': readAt,
      if (channel != null) 'channel': channel,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<int?>? reminderId,
      Value<String>? category,
      Value<String>? title,
      Value<String?>? body,
      Value<DateTime>? scheduledFor,
      Value<DateTime?>? deliveredAt,
      Value<DateTime?>? readAt,
      Value<String>? channel,
      Value<DateTime>? createdAt}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      reminderId: reminderId ?? this.reminderId,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      channel: channel ?? this.channel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('reminderId: $reminderId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt, ')
          ..write('channel: $channel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _visitDateMeta =
      const VerificationMeta('visitDate');
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
      'visit_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _hospitalNameMeta =
      const VerificationMeta('hospitalName');
  @override
  late final GeneratedColumn<String> hospitalName = GeneratedColumn<String>(
      'hospital_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _diagnosisMeta =
      const VerificationMeta('diagnosis');
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
      'diagnosis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adviceMeta = const VerificationMeta('advice');
  @override
  late final GeneratedColumn<String> advice = GeneratedColumn<String>(
      'advice', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conditionCodeMeta =
      const VerificationMeta('conditionCode');
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
      'condition_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        visitDate,
        hospitalName,
        department,
        diagnosis,
        advice,
        notes,
        conditionCode,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(Insertable<Encounter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('visit_date')) {
      context.handle(_visitDateMeta,
          visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta));
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('hospital_name')) {
      context.handle(
          _hospitalNameMeta,
          hospitalName.isAcceptableOrUnknown(
              data['hospital_name']!, _hospitalNameMeta));
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    }
    if (data.containsKey('diagnosis')) {
      context.handle(_diagnosisMeta,
          diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta));
    }
    if (data.containsKey('advice')) {
      context.handle(_adviceMeta,
          advice.isAcceptableOrUnknown(data['advice']!, _adviceMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('condition_code')) {
      context.handle(
          _conditionCodeMeta,
          conditionCode.isAcceptableOrUnknown(
              data['condition_code']!, _conditionCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      visitDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}visit_date'])!,
      hospitalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hospital_name'])!,
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department'])!,
      diagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis']),
      advice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}advice']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      conditionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final int id;
  final int profileId;
  final DateTime visitDate;
  final String hospitalName;
  final String department;
  final String? diagnosis;
  final String? advice;
  final String? notes;
  final String? conditionCode;
  final DateTime createdAt;
  const Encounter(
      {required this.id,
      required this.profileId,
      required this.visitDate,
      required this.hospitalName,
      required this.department,
      this.diagnosis,
      this.advice,
      this.notes,
      this.conditionCode,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['visit_date'] = Variable<DateTime>(visitDate);
    map['hospital_name'] = Variable<String>(hospitalName);
    map['department'] = Variable<String>(department);
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || advice != null) {
      map['advice'] = Variable<String>(advice);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || conditionCode != null) {
      map['condition_code'] = Variable<String>(conditionCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      profileId: Value(profileId),
      visitDate: Value(visitDate),
      hospitalName: Value(hospitalName),
      department: Value(department),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      advice:
          advice == null && nullToAbsent ? const Value.absent() : Value(advice),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      conditionCode: conditionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionCode),
      createdAt: Value(createdAt),
    );
  }

  factory Encounter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      hospitalName: serializer.fromJson<String>(json['hospitalName']),
      department: serializer.fromJson<String>(json['department']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      advice: serializer.fromJson<String?>(json['advice']),
      notes: serializer.fromJson<String?>(json['notes']),
      conditionCode: serializer.fromJson<String?>(json['conditionCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'hospitalName': serializer.toJson<String>(hospitalName),
      'department': serializer.toJson<String>(department),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'advice': serializer.toJson<String?>(advice),
      'notes': serializer.toJson<String?>(notes),
      'conditionCode': serializer.toJson<String?>(conditionCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Encounter copyWith(
          {int? id,
          int? profileId,
          DateTime? visitDate,
          String? hospitalName,
          String? department,
          Value<String?> diagnosis = const Value.absent(),
          Value<String?> advice = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> conditionCode = const Value.absent(),
          DateTime? createdAt}) =>
      Encounter(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        visitDate: visitDate ?? this.visitDate,
        hospitalName: hospitalName ?? this.hospitalName,
        department: department ?? this.department,
        diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
        advice: advice.present ? advice.value : this.advice,
        notes: notes.present ? notes.value : this.notes,
        conditionCode:
            conditionCode.present ? conditionCode.value : this.conditionCode,
        createdAt: createdAt ?? this.createdAt,
      );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      hospitalName: data.hospitalName.present
          ? data.hospitalName.value
          : this.hospitalName,
      department:
          data.department.present ? data.department.value : this.department,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      advice: data.advice.present ? data.advice.value : this.advice,
      notes: data.notes.present ? data.notes.value : this.notes,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('visitDate: $visitDate, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('department: $department, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('advice: $advice, ')
          ..write('notes: $notes, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, visitDate, hospitalName,
      department, diagnosis, advice, notes, conditionCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.visitDate == this.visitDate &&
          other.hospitalName == this.hospitalName &&
          other.department == this.department &&
          other.diagnosis == this.diagnosis &&
          other.advice == this.advice &&
          other.notes == this.notes &&
          other.conditionCode == this.conditionCode &&
          other.createdAt == this.createdAt);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> visitDate;
  final Value<String> hospitalName;
  final Value<String> department;
  final Value<String?> diagnosis;
  final Value<String?> advice;
  final Value<String?> notes;
  final Value<String?> conditionCode;
  final Value<DateTime> createdAt;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.hospitalName = const Value.absent(),
    this.department = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.advice = const Value.absent(),
    this.notes = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EncountersCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required DateTime visitDate,
    this.hospitalName = const Value.absent(),
    this.department = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.advice = const Value.absent(),
    this.notes = const Value.absent(),
    this.conditionCode = const Value.absent(),
    required DateTime createdAt,
  })  : visitDate = Value(visitDate),
        createdAt = Value(createdAt);
  static Insertable<Encounter> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? visitDate,
    Expression<String>? hospitalName,
    Expression<String>? department,
    Expression<String>? diagnosis,
    Expression<String>? advice,
    Expression<String>? notes,
    Expression<String>? conditionCode,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (visitDate != null) 'visit_date': visitDate,
      if (hospitalName != null) 'hospital_name': hospitalName,
      if (department != null) 'department': department,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (advice != null) 'advice': advice,
      if (notes != null) 'notes': notes,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EncountersCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<DateTime>? visitDate,
      Value<String>? hospitalName,
      Value<String>? department,
      Value<String?>? diagnosis,
      Value<String?>? advice,
      Value<String?>? notes,
      Value<String?>? conditionCode,
      Value<DateTime>? createdAt}) {
    return EncountersCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      visitDate: visitDate ?? this.visitDate,
      hospitalName: hospitalName ?? this.hospitalName,
      department: department ?? this.department,
      diagnosis: diagnosis ?? this.diagnosis,
      advice: advice ?? this.advice,
      notes: notes ?? this.notes,
      conditionCode: conditionCode ?? this.conditionCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (hospitalName.present) {
      map['hospital_name'] = Variable<String>(hospitalName.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (advice.present) {
      map['advice'] = Variable<String>(advice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('visitDate: $visitDate, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('department: $department, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('advice: $advice, ')
          ..write('notes: $notes, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AllergiesTable extends Allergies
    with TableInfo<$AllergiesTable, Allergy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllergiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _substanceMeta =
      const VerificationMeta('substance');
  @override
  late final GeneratedColumn<String> substance = GeneratedColumn<String>(
      'substance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('药物'));
  static const VerificationMeta _reactionMeta =
      const VerificationMeta('reaction');
  @override
  late final GeneratedColumn<String> reaction = GeneratedColumn<String>(
      'reaction', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('不确定'));
  static const VerificationMeta _notedDateMeta =
      const VerificationMeta('notedDate');
  @override
  late final GeneratedColumn<DateTime> notedDate = GeneratedColumn<DateTime>(
      'noted_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        substance,
        category,
        reaction,
        severity,
        notedDate,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allergies';
  @override
  VerificationContext validateIntegrity(Insertable<Allergy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('substance')) {
      context.handle(_substanceMeta,
          substance.isAcceptableOrUnknown(data['substance']!, _substanceMeta));
    } else if (isInserting) {
      context.missing(_substanceMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('reaction')) {
      context.handle(_reactionMeta,
          reaction.isAcceptableOrUnknown(data['reaction']!, _reactionMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    }
    if (data.containsKey('noted_date')) {
      context.handle(_notedDateMeta,
          notedDate.isAcceptableOrUnknown(data['noted_date']!, _notedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Allergy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Allergy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      substance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}substance'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      reaction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reaction']),
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      notedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}noted_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AllergiesTable createAlias(String alias) {
    return $AllergiesTable(attachedDatabase, alias);
  }
}

class Allergy extends DataClass implements Insertable<Allergy> {
  final int id;
  final int profileId;
  final String substance;
  final String category;
  final String? reaction;
  final String severity;
  final DateTime? notedDate;
  final String? notes;
  final DateTime createdAt;
  const Allergy(
      {required this.id,
      required this.profileId,
      required this.substance,
      required this.category,
      this.reaction,
      required this.severity,
      this.notedDate,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['substance'] = Variable<String>(substance);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || reaction != null) {
      map['reaction'] = Variable<String>(reaction);
    }
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || notedDate != null) {
      map['noted_date'] = Variable<DateTime>(notedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AllergiesCompanion toCompanion(bool nullToAbsent) {
    return AllergiesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      substance: Value(substance),
      category: Value(category),
      reaction: reaction == null && nullToAbsent
          ? const Value.absent()
          : Value(reaction),
      severity: Value(severity),
      notedDate: notedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(notedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Allergy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Allergy(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      substance: serializer.fromJson<String>(json['substance']),
      category: serializer.fromJson<String>(json['category']),
      reaction: serializer.fromJson<String?>(json['reaction']),
      severity: serializer.fromJson<String>(json['severity']),
      notedDate: serializer.fromJson<DateTime?>(json['notedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'substance': serializer.toJson<String>(substance),
      'category': serializer.toJson<String>(category),
      'reaction': serializer.toJson<String?>(reaction),
      'severity': serializer.toJson<String>(severity),
      'notedDate': serializer.toJson<DateTime?>(notedDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Allergy copyWith(
          {int? id,
          int? profileId,
          String? substance,
          String? category,
          Value<String?> reaction = const Value.absent(),
          String? severity,
          Value<DateTime?> notedDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Allergy(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        substance: substance ?? this.substance,
        category: category ?? this.category,
        reaction: reaction.present ? reaction.value : this.reaction,
        severity: severity ?? this.severity,
        notedDate: notedDate.present ? notedDate.value : this.notedDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Allergy copyWithCompanion(AllergiesCompanion data) {
    return Allergy(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      substance: data.substance.present ? data.substance.value : this.substance,
      category: data.category.present ? data.category.value : this.category,
      reaction: data.reaction.present ? data.reaction.value : this.reaction,
      severity: data.severity.present ? data.severity.value : this.severity,
      notedDate: data.notedDate.present ? data.notedDate.value : this.notedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Allergy(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('substance: $substance, ')
          ..write('category: $category, ')
          ..write('reaction: $reaction, ')
          ..write('severity: $severity, ')
          ..write('notedDate: $notedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, substance, category, reaction,
      severity, notedDate, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Allergy &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.substance == this.substance &&
          other.category == this.category &&
          other.reaction == this.reaction &&
          other.severity == this.severity &&
          other.notedDate == this.notedDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class AllergiesCompanion extends UpdateCompanion<Allergy> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> substance;
  final Value<String> category;
  final Value<String?> reaction;
  final Value<String> severity;
  final Value<DateTime?> notedDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const AllergiesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.substance = const Value.absent(),
    this.category = const Value.absent(),
    this.reaction = const Value.absent(),
    this.severity = const Value.absent(),
    this.notedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AllergiesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String substance,
    this.category = const Value.absent(),
    this.reaction = const Value.absent(),
    this.severity = const Value.absent(),
    this.notedDate = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : substance = Value(substance),
        createdAt = Value(createdAt);
  static Insertable<Allergy> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? substance,
    Expression<String>? category,
    Expression<String>? reaction,
    Expression<String>? severity,
    Expression<DateTime>? notedDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (substance != null) 'substance': substance,
      if (category != null) 'category': category,
      if (reaction != null) 'reaction': reaction,
      if (severity != null) 'severity': severity,
      if (notedDate != null) 'noted_date': notedDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AllergiesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? substance,
      Value<String>? category,
      Value<String?>? reaction,
      Value<String>? severity,
      Value<DateTime?>? notedDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return AllergiesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      substance: substance ?? this.substance,
      category: category ?? this.category,
      reaction: reaction ?? this.reaction,
      severity: severity ?? this.severity,
      notedDate: notedDate ?? this.notedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (substance.present) {
      map['substance'] = Variable<String>(substance.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (reaction.present) {
      map['reaction'] = Variable<String>(reaction.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (notedDate.present) {
      map['noted_date'] = Variable<DateTime>(notedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('substance: $substance, ')
          ..write('category: $category, ')
          ..write('reaction: $reaction, ')
          ..write('severity: $severity, ')
          ..write('notedDate: $notedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReportOrgansTable extends ReportOrgans
    with TableInfo<$ReportOrgansTable, ReportOrgan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportOrgansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _areaNameMeta =
      const VerificationMeta('areaName');
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
      'area_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, reportId, areaName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_organs';
  @override
  VerificationContext validateIntegrity(Insertable<ReportOrgan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('area_name')) {
      context.handle(_areaNameMeta,
          areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta));
    } else if (isInserting) {
      context.missing(_areaNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportOrgan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportOrgan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      areaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReportOrgansTable createAlias(String alias) {
    return $ReportOrgansTable(attachedDatabase, alias);
  }
}

class ReportOrgan extends DataClass implements Insertable<ReportOrgan> {
  final int id;
  final int profileId;
  final int reportId;
  final String areaName;
  final DateTime createdAt;
  const ReportOrgan(
      {required this.id,
      required this.profileId,
      required this.reportId,
      required this.areaName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['report_id'] = Variable<int>(reportId);
    map['area_name'] = Variable<String>(areaName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReportOrgansCompanion toCompanion(bool nullToAbsent) {
    return ReportOrgansCompanion(
      id: Value(id),
      profileId: Value(profileId),
      reportId: Value(reportId),
      areaName: Value(areaName),
      createdAt: Value(createdAt),
    );
  }

  factory ReportOrgan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportOrgan(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      reportId: serializer.fromJson<int>(json['reportId']),
      areaName: serializer.fromJson<String>(json['areaName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'reportId': serializer.toJson<int>(reportId),
      'areaName': serializer.toJson<String>(areaName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReportOrgan copyWith(
          {int? id,
          int? profileId,
          int? reportId,
          String? areaName,
          DateTime? createdAt}) =>
      ReportOrgan(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        reportId: reportId ?? this.reportId,
        areaName: areaName ?? this.areaName,
        createdAt: createdAt ?? this.createdAt,
      );
  ReportOrgan copyWithCompanion(ReportOrgansCompanion data) {
    return ReportOrgan(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportOrgan(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('reportId: $reportId, ')
          ..write('areaName: $areaName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, reportId, areaName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportOrgan &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.reportId == this.reportId &&
          other.areaName == this.areaName &&
          other.createdAt == this.createdAt);
}

class ReportOrgansCompanion extends UpdateCompanion<ReportOrgan> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> reportId;
  final Value<String> areaName;
  final Value<DateTime> createdAt;
  const ReportOrgansCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.reportId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReportOrgansCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required int reportId,
    required String areaName,
    required DateTime createdAt,
  })  : reportId = Value(reportId),
        areaName = Value(areaName),
        createdAt = Value(createdAt);
  static Insertable<ReportOrgan> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? reportId,
    Expression<String>? areaName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (reportId != null) 'report_id': reportId,
      if (areaName != null) 'area_name': areaName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReportOrgansCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<int>? reportId,
      Value<String>? areaName,
      Value<DateTime>? createdAt}) {
    return ReportOrgansCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      reportId: reportId ?? this.reportId,
      areaName: areaName ?? this.areaName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportOrgansCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('reportId: $reportId, ')
          ..write('areaName: $areaName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HealthMetricsTable healthMetrics = $HealthMetricsTable(this);
  late final $DailyHealthRecordsTable dailyHealthRecords =
      $DailyHealthRecordsTable(this);
  late final $MedicalReportsTable medicalReports = $MedicalReportsTable(this);
  late final $DiseasesTable diseases = $DiseasesTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final $PersonProfilesTable personProfiles = $PersonProfilesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $AllergiesTable allergies = $AllergiesTable(this);
  late final $ReportOrgansTable reportOrgans = $ReportOrgansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        healthMetrics,
        dailyHealthRecords,
        medicalReports,
        diseases,
        medications,
        userProfile,
        personProfiles,
        reminders,
        notifications,
        encounters,
        allergies,
        reportOrgans
      ];
}

typedef $$HealthMetricsTableCreateCompanionBuilder = HealthMetricsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  required String metricId,
  required String metricName,
  required double value,
  Value<String?> rawValue,
  Value<double?> numericValue,
  required String unit,
  Value<double?> canonicalValue,
  Value<String?> canonicalUnit,
  Value<double?> referenceMin,
  Value<double?> referenceMax,
  Value<String?> referenceRangeRaw,
  Value<String?> sourceAbnormalFlag,
  required String status,
  required String bodySystem,
  required DateTime measuredAt,
  Value<String> sourceType,
  Value<String?> sourceId,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int?> reportId,
  Value<String?> rawName,
  Value<String> matchType,
  Value<double?> recognitionConfidence,
  Value<String> verificationStatus,
  Value<int?> sourcePage,
  Value<String?> sourceBoundingBox,
});
typedef $$HealthMetricsTableUpdateCompanionBuilder = HealthMetricsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> metricId,
  Value<String> metricName,
  Value<double> value,
  Value<String?> rawValue,
  Value<double?> numericValue,
  Value<String> unit,
  Value<double?> canonicalValue,
  Value<String?> canonicalUnit,
  Value<double?> referenceMin,
  Value<double?> referenceMax,
  Value<String?> referenceRangeRaw,
  Value<String?> sourceAbnormalFlag,
  Value<String> status,
  Value<String> bodySystem,
  Value<DateTime> measuredAt,
  Value<String> sourceType,
  Value<String?> sourceId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int?> reportId,
  Value<String?> rawName,
  Value<String> matchType,
  Value<double?> recognitionConfidence,
  Value<String> verificationStatus,
  Value<int?> sourcePage,
  Value<String?> sourceBoundingBox,
});

class $$HealthMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metricId => $composableBuilder(
      column: $table.metricId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metricName => $composableBuilder(
      column: $table.metricName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawValue => $composableBuilder(
      column: $table.rawValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get canonicalValue => $composableBuilder(
      column: $table.canonicalValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canonicalUnit => $composableBuilder(
      column: $table.canonicalUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get referenceMin => $composableBuilder(
      column: $table.referenceMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get referenceMax => $composableBuilder(
      column: $table.referenceMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceRangeRaw => $composableBuilder(
      column: $table.referenceRangeRaw,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceAbnormalFlag => $composableBuilder(
      column: $table.sourceAbnormalFlag,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodySystem => $composableBuilder(
      column: $table.bodySystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawName => $composableBuilder(
      column: $table.rawName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchType => $composableBuilder(
      column: $table.matchType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get recognitionConfidence => $composableBuilder(
      column: $table.recognitionConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceBoundingBox => $composableBuilder(
      column: $table.sourceBoundingBox,
      builder: (column) => ColumnFilters(column));
}

class $$HealthMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metricId => $composableBuilder(
      column: $table.metricId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metricName => $composableBuilder(
      column: $table.metricName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawValue => $composableBuilder(
      column: $table.rawValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get numericValue => $composableBuilder(
      column: $table.numericValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get canonicalValue => $composableBuilder(
      column: $table.canonicalValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canonicalUnit => $composableBuilder(
      column: $table.canonicalUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get referenceMin => $composableBuilder(
      column: $table.referenceMin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get referenceMax => $composableBuilder(
      column: $table.referenceMax,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceRangeRaw => $composableBuilder(
      column: $table.referenceRangeRaw,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceAbnormalFlag => $composableBuilder(
      column: $table.sourceAbnormalFlag,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodySystem => $composableBuilder(
      column: $table.bodySystem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawName => $composableBuilder(
      column: $table.rawName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchType => $composableBuilder(
      column: $table.matchType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get recognitionConfidence => $composableBuilder(
      column: $table.recognitionConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceBoundingBox => $composableBuilder(
      column: $table.sourceBoundingBox,
      builder: (column) => ColumnOrderings(column));
}

class $$HealthMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get metricId =>
      $composableBuilder(column: $table.metricId, builder: (column) => column);

  GeneratedColumn<String> get metricName => $composableBuilder(
      column: $table.metricName, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get rawValue =>
      $composableBuilder(column: $table.rawValue, builder: (column) => column);

  GeneratedColumn<double> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get canonicalValue => $composableBuilder(
      column: $table.canonicalValue, builder: (column) => column);

  GeneratedColumn<String> get canonicalUnit => $composableBuilder(
      column: $table.canonicalUnit, builder: (column) => column);

  GeneratedColumn<double> get referenceMin => $composableBuilder(
      column: $table.referenceMin, builder: (column) => column);

  GeneratedColumn<double> get referenceMax => $composableBuilder(
      column: $table.referenceMax, builder: (column) => column);

  GeneratedColumn<String> get referenceRangeRaw => $composableBuilder(
      column: $table.referenceRangeRaw, builder: (column) => column);

  GeneratedColumn<String> get sourceAbnormalFlag => $composableBuilder(
      column: $table.sourceAbnormalFlag, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get bodySystem => $composableBuilder(
      column: $table.bodySystem, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<String> get rawName =>
      $composableBuilder(column: $table.rawName, builder: (column) => column);

  GeneratedColumn<String> get matchType =>
      $composableBuilder(column: $table.matchType, builder: (column) => column);

  GeneratedColumn<double> get recognitionConfidence => $composableBuilder(
      column: $table.recognitionConfidence, builder: (column) => column);

  GeneratedColumn<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus, builder: (column) => column);

  GeneratedColumn<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => column);

  GeneratedColumn<String> get sourceBoundingBox => $composableBuilder(
      column: $table.sourceBoundingBox, builder: (column) => column);
}

class $$HealthMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthMetricsTable,
    HealthMetric,
    $$HealthMetricsTableFilterComposer,
    $$HealthMetricsTableOrderingComposer,
    $$HealthMetricsTableAnnotationComposer,
    $$HealthMetricsTableCreateCompanionBuilder,
    $$HealthMetricsTableUpdateCompanionBuilder,
    (
      HealthMetric,
      BaseReferences<_$AppDatabase, $HealthMetricsTable, HealthMetric>
    ),
    HealthMetric,
    PrefetchHooks Function()> {
  $$HealthMetricsTableTableManager(_$AppDatabase db, $HealthMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> metricId = const Value.absent(),
            Value<String> metricName = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<String?> rawValue = const Value.absent(),
            Value<double?> numericValue = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> canonicalValue = const Value.absent(),
            Value<String?> canonicalUnit = const Value.absent(),
            Value<double?> referenceMin = const Value.absent(),
            Value<double?> referenceMax = const Value.absent(),
            Value<String?> referenceRangeRaw = const Value.absent(),
            Value<String?> sourceAbnormalFlag = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> bodySystem = const Value.absent(),
            Value<DateTime> measuredAt = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> reportId = const Value.absent(),
            Value<String?> rawName = const Value.absent(),
            Value<String> matchType = const Value.absent(),
            Value<double?> recognitionConfidence = const Value.absent(),
            Value<String> verificationStatus = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<String?> sourceBoundingBox = const Value.absent(),
          }) =>
              HealthMetricsCompanion(
            id: id,
            profileId: profileId,
            metricId: metricId,
            metricName: metricName,
            value: value,
            rawValue: rawValue,
            numericValue: numericValue,
            unit: unit,
            canonicalValue: canonicalValue,
            canonicalUnit: canonicalUnit,
            referenceMin: referenceMin,
            referenceMax: referenceMax,
            referenceRangeRaw: referenceRangeRaw,
            sourceAbnormalFlag: sourceAbnormalFlag,
            status: status,
            bodySystem: bodySystem,
            measuredAt: measuredAt,
            sourceType: sourceType,
            sourceId: sourceId,
            notes: notes,
            createdAt: createdAt,
            reportId: reportId,
            rawName: rawName,
            matchType: matchType,
            recognitionConfidence: recognitionConfidence,
            verificationStatus: verificationStatus,
            sourcePage: sourcePage,
            sourceBoundingBox: sourceBoundingBox,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String metricId,
            required String metricName,
            required double value,
            Value<String?> rawValue = const Value.absent(),
            Value<double?> numericValue = const Value.absent(),
            required String unit,
            Value<double?> canonicalValue = const Value.absent(),
            Value<String?> canonicalUnit = const Value.absent(),
            Value<double?> referenceMin = const Value.absent(),
            Value<double?> referenceMax = const Value.absent(),
            Value<String?> referenceRangeRaw = const Value.absent(),
            Value<String?> sourceAbnormalFlag = const Value.absent(),
            required String status,
            required String bodySystem,
            required DateTime measuredAt,
            Value<String> sourceType = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int?> reportId = const Value.absent(),
            Value<String?> rawName = const Value.absent(),
            Value<String> matchType = const Value.absent(),
            Value<double?> recognitionConfidence = const Value.absent(),
            Value<String> verificationStatus = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<String?> sourceBoundingBox = const Value.absent(),
          }) =>
              HealthMetricsCompanion.insert(
            id: id,
            profileId: profileId,
            metricId: metricId,
            metricName: metricName,
            value: value,
            rawValue: rawValue,
            numericValue: numericValue,
            unit: unit,
            canonicalValue: canonicalValue,
            canonicalUnit: canonicalUnit,
            referenceMin: referenceMin,
            referenceMax: referenceMax,
            referenceRangeRaw: referenceRangeRaw,
            sourceAbnormalFlag: sourceAbnormalFlag,
            status: status,
            bodySystem: bodySystem,
            measuredAt: measuredAt,
            sourceType: sourceType,
            sourceId: sourceId,
            notes: notes,
            createdAt: createdAt,
            reportId: reportId,
            rawName: rawName,
            matchType: matchType,
            recognitionConfidence: recognitionConfidence,
            verificationStatus: verificationStatus,
            sourcePage: sourcePage,
            sourceBoundingBox: sourceBoundingBox,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthMetricsTable,
    HealthMetric,
    $$HealthMetricsTableFilterComposer,
    $$HealthMetricsTableOrderingComposer,
    $$HealthMetricsTableAnnotationComposer,
    $$HealthMetricsTableCreateCompanionBuilder,
    $$HealthMetricsTableUpdateCompanionBuilder,
    (
      HealthMetric,
      BaseReferences<_$AppDatabase, $HealthMetricsTable, HealthMetric>
    ),
    HealthMetric,
    PrefetchHooks Function()>;
typedef $$DailyHealthRecordsTableCreateCompanionBuilder
    = DailyHealthRecordsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  required String type,
  required double value1,
  Value<double?> value2,
  required String unit,
  Value<String?> context,
  required DateTime measuredAt,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$DailyHealthRecordsTableUpdateCompanionBuilder
    = DailyHealthRecordsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> type,
  Value<double> value1,
  Value<double?> value2,
  Value<String> unit,
  Value<String?> context,
  Value<DateTime> measuredAt,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$DailyHealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value1 => $composableBuilder(
      column: $table.value1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value2 => $composableBuilder(
      column: $table.value2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DailyHealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value1 => $composableBuilder(
      column: $table.value1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value2 => $composableBuilder(
      column: $table.value2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyHealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value1 =>
      $composableBuilder(column: $table.value1, builder: (column) => column);

  GeneratedColumn<double> get value2 =>
      $composableBuilder(column: $table.value2, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyHealthRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyHealthRecordsTable,
    DailyHealthRecord,
    $$DailyHealthRecordsTableFilterComposer,
    $$DailyHealthRecordsTableOrderingComposer,
    $$DailyHealthRecordsTableAnnotationComposer,
    $$DailyHealthRecordsTableCreateCompanionBuilder,
    $$DailyHealthRecordsTableUpdateCompanionBuilder,
    (
      DailyHealthRecord,
      BaseReferences<_$AppDatabase, $DailyHealthRecordsTable, DailyHealthRecord>
    ),
    DailyHealthRecord,
    PrefetchHooks Function()> {
  $$DailyHealthRecordsTableTableManager(
      _$AppDatabase db, $DailyHealthRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyHealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyHealthRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> value1 = const Value.absent(),
            Value<double?> value2 = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> context = const Value.absent(),
            Value<DateTime> measuredAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DailyHealthRecordsCompanion(
            id: id,
            profileId: profileId,
            type: type,
            value1: value1,
            value2: value2,
            unit: unit,
            context: context,
            measuredAt: measuredAt,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String type,
            required double value1,
            Value<double?> value2 = const Value.absent(),
            required String unit,
            Value<String?> context = const Value.absent(),
            required DateTime measuredAt,
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              DailyHealthRecordsCompanion.insert(
            id: id,
            profileId: profileId,
            type: type,
            value1: value1,
            value2: value2,
            unit: unit,
            context: context,
            measuredAt: measuredAt,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyHealthRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyHealthRecordsTable,
    DailyHealthRecord,
    $$DailyHealthRecordsTableFilterComposer,
    $$DailyHealthRecordsTableOrderingComposer,
    $$DailyHealthRecordsTableAnnotationComposer,
    $$DailyHealthRecordsTableCreateCompanionBuilder,
    $$DailyHealthRecordsTableUpdateCompanionBuilder,
    (
      DailyHealthRecord,
      BaseReferences<_$AppDatabase, $DailyHealthRecordsTable, DailyHealthRecord>
    ),
    DailyHealthRecord,
    PrefetchHooks Function()>;
typedef $$MedicalReportsTableCreateCompanionBuilder = MedicalReportsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  required String hospitalName,
  required DateTime reportDate,
  required String reportType,
  Value<String?> sourceImagePath,
  Value<String?> rawText,
  Value<String> recognitionStatus,
  Value<String> tags,
  Value<String?> conditionCode,
  Value<int?> encounterId,
  required DateTime createdAt,
});
typedef $$MedicalReportsTableUpdateCompanionBuilder = MedicalReportsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> hospitalName,
  Value<DateTime> reportDate,
  Value<String> reportType,
  Value<String?> sourceImagePath,
  Value<String?> rawText,
  Value<String> recognitionStatus,
  Value<String> tags,
  Value<String?> conditionCode,
  Value<int?> encounterId,
  Value<DateTime> createdAt,
});

class $$MedicalReportsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reportDate => $composableBuilder(
      column: $table.reportDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceImagePath => $composableBuilder(
      column: $table.sourceImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recognitionStatus => $composableBuilder(
      column: $table.recognitionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MedicalReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reportDate => $composableBuilder(
      column: $table.reportDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceImagePath => $composableBuilder(
      column: $table.sourceImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recognitionStatus => $composableBuilder(
      column: $table.recognitionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MedicalReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName, builder: (column) => column);

  GeneratedColumn<DateTime> get reportDate => $composableBuilder(
      column: $table.reportDate, builder: (column) => column);

  GeneratedColumn<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => column);

  GeneratedColumn<String> get sourceImagePath => $composableBuilder(
      column: $table.sourceImagePath, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get recognitionStatus => $composableBuilder(
      column: $table.recognitionStatus, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => column);

  GeneratedColumn<int> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MedicalReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicalReportsTable,
    MedicalReport,
    $$MedicalReportsTableFilterComposer,
    $$MedicalReportsTableOrderingComposer,
    $$MedicalReportsTableAnnotationComposer,
    $$MedicalReportsTableCreateCompanionBuilder,
    $$MedicalReportsTableUpdateCompanionBuilder,
    (
      MedicalReport,
      BaseReferences<_$AppDatabase, $MedicalReportsTable, MedicalReport>
    ),
    MedicalReport,
    PrefetchHooks Function()> {
  $$MedicalReportsTableTableManager(
      _$AppDatabase db, $MedicalReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicalReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicalReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicalReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> hospitalName = const Value.absent(),
            Value<DateTime> reportDate = const Value.absent(),
            Value<String> reportType = const Value.absent(),
            Value<String?> sourceImagePath = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<String> recognitionStatus = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<int?> encounterId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MedicalReportsCompanion(
            id: id,
            profileId: profileId,
            hospitalName: hospitalName,
            reportDate: reportDate,
            reportType: reportType,
            sourceImagePath: sourceImagePath,
            rawText: rawText,
            recognitionStatus: recognitionStatus,
            tags: tags,
            conditionCode: conditionCode,
            encounterId: encounterId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String hospitalName,
            required DateTime reportDate,
            required String reportType,
            Value<String?> sourceImagePath = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<String> recognitionStatus = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<int?> encounterId = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MedicalReportsCompanion.insert(
            id: id,
            profileId: profileId,
            hospitalName: hospitalName,
            reportDate: reportDate,
            reportType: reportType,
            sourceImagePath: sourceImagePath,
            rawText: rawText,
            recognitionStatus: recognitionStatus,
            tags: tags,
            conditionCode: conditionCode,
            encounterId: encounterId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicalReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicalReportsTable,
    MedicalReport,
    $$MedicalReportsTableFilterComposer,
    $$MedicalReportsTableOrderingComposer,
    $$MedicalReportsTableAnnotationComposer,
    $$MedicalReportsTableCreateCompanionBuilder,
    $$MedicalReportsTableUpdateCompanionBuilder,
    (
      MedicalReport,
      BaseReferences<_$AppDatabase, $MedicalReportsTable, MedicalReport>
    ),
    MedicalReport,
    PrefetchHooks Function()>;
typedef $$DiseasesTableCreateCompanionBuilder = DiseasesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  required String name,
  Value<DateTime?> foundDate,
  Value<String> status,
  Value<String?> notes,
  required DateTime createdAt,
  Value<String?> conditionCode,
  Value<String?> stage,
  Value<String?> diagnosisBasis,
});
typedef $$DiseasesTableUpdateCompanionBuilder = DiseasesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<DateTime?> foundDate,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<String?> conditionCode,
  Value<String?> stage,
  Value<String?> diagnosisBasis,
});

class $$DiseasesTableFilterComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get foundDate => $composableBuilder(
      column: $table.foundDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosisBasis => $composableBuilder(
      column: $table.diagnosisBasis,
      builder: (column) => ColumnFilters(column));
}

class $$DiseasesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get foundDate => $composableBuilder(
      column: $table.foundDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosisBasis => $composableBuilder(
      column: $table.diagnosisBasis,
      builder: (column) => ColumnOrderings(column));
}

class $$DiseasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get foundDate =>
      $composableBuilder(column: $table.foundDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get diagnosisBasis => $composableBuilder(
      column: $table.diagnosisBasis, builder: (column) => column);
}

class $$DiseasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiseasesTable,
    Disease,
    $$DiseasesTableFilterComposer,
    $$DiseasesTableOrderingComposer,
    $$DiseasesTableAnnotationComposer,
    $$DiseasesTableCreateCompanionBuilder,
    $$DiseasesTableUpdateCompanionBuilder,
    (Disease, BaseReferences<_$AppDatabase, $DiseasesTable, Disease>),
    Disease,
    PrefetchHooks Function()> {
  $$DiseasesTableTableManager(_$AppDatabase db, $DiseasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiseasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiseasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiseasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime?> foundDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<String?> stage = const Value.absent(),
            Value<String?> diagnosisBasis = const Value.absent(),
          }) =>
              DiseasesCompanion(
            id: id,
            profileId: profileId,
            name: name,
            foundDate: foundDate,
            status: status,
            notes: notes,
            createdAt: createdAt,
            conditionCode: conditionCode,
            stage: stage,
            diagnosisBasis: diagnosisBasis,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String name,
            Value<DateTime?> foundDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<String?> conditionCode = const Value.absent(),
            Value<String?> stage = const Value.absent(),
            Value<String?> diagnosisBasis = const Value.absent(),
          }) =>
              DiseasesCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            foundDate: foundDate,
            status: status,
            notes: notes,
            createdAt: createdAt,
            conditionCode: conditionCode,
            stage: stage,
            diagnosisBasis: diagnosisBasis,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiseasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiseasesTable,
    Disease,
    $$DiseasesTableFilterComposer,
    $$DiseasesTableOrderingComposer,
    $$DiseasesTableAnnotationComposer,
    $$DiseasesTableCreateCompanionBuilder,
    $$DiseasesTableUpdateCompanionBuilder,
    (Disease, BaseReferences<_$AppDatabase, $DiseasesTable, Disease>),
    Disease,
    PrefetchHooks Function()>;
typedef $$MedicationsTableCreateCompanionBuilder = MedicationsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  required String name,
  Value<String?> dosage,
  Value<String?> dosageUnit,
  Value<String?> usage,
  Value<String?> timesPerDay,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> status,
  Value<String?> notes,
  Value<String?> conditionCode,
  required DateTime createdAt,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<String?> dosage,
  Value<String?> dosageUnit,
  Value<String?> usage,
  Value<String?> timesPerDay,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> status,
  Value<String?> notes,
  Value<String?> conditionCode,
  Value<DateTime> createdAt,
});

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosageUnit => $composableBuilder(
      column: $table.dosageUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usage => $composableBuilder(
      column: $table.usage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosageUnit => $composableBuilder(
      column: $table.dosageUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usage => $composableBuilder(
      column: $table.usage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get dosageUnit => $composableBuilder(
      column: $table.dosageUnit, builder: (column) => column);

  GeneratedColumn<String> get usage =>
      $composableBuilder(column: $table.usage, builder: (column) => column);

  GeneratedColumn<String> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MedicationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, BaseReferences<_$AppDatabase, $MedicationsTable, Medication>),
    Medication,
    PrefetchHooks Function()> {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<String?> dosageUnit = const Value.absent(),
            Value<String?> usage = const Value.absent(),
            Value<String?> timesPerDay = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MedicationsCompanion(
            id: id,
            profileId: profileId,
            name: name,
            dosage: dosage,
            dosageUnit: dosageUnit,
            usage: usage,
            timesPerDay: timesPerDay,
            startDate: startDate,
            endDate: endDate,
            status: status,
            notes: notes,
            conditionCode: conditionCode,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String name,
            Value<String?> dosage = const Value.absent(),
            Value<String?> dosageUnit = const Value.absent(),
            Value<String?> usage = const Value.absent(),
            Value<String?> timesPerDay = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MedicationsCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            dosage: dosage,
            dosageUnit: dosageUnit,
            usage: usage,
            timesPerDay: timesPerDay,
            startDate: startDate,
            endDate: endDate,
            status: status,
            notes: notes,
            conditionCode: conditionCode,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, BaseReferences<_$AppDatabase, $MedicationsTable, Medication>),
    Medication,
    PrefetchHooks Function()>;
typedef $$UserProfileTableCreateCompanionBuilder = UserProfileCompanion
    Function({
  required int id,
  Value<String> nickname,
  Value<String> gender,
  Value<DateTime?> birthDate,
  Value<double?> heightCm,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$UserProfileTableUpdateCompanionBuilder = UserProfileCompanion
    Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> gender,
  Value<DateTime?> birthDate,
  Value<double?> heightCm,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()> {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfileCompanion(
            id: id,
            nickname: nickname,
            gender: gender,
            birthDate: birthDate,
            heightCm: heightCm,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int id,
            Value<String> nickname = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfileCompanion.insert(
            id: id,
            nickname: nickname,
            gender: gender,
            birthDate: birthDate,
            heightCm: heightCm,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()>;
typedef $$PersonProfilesTableCreateCompanionBuilder = PersonProfilesCompanion
    Function({
  Value<int> id,
  Value<String> displayName,
  Value<String> relationship,
  Value<String?> sex,
  Value<DateTime?> dateOfBirth,
  Value<double?> heightCm,
  Value<String> knownNames,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$PersonProfilesTableUpdateCompanionBuilder = PersonProfilesCompanion
    Function({
  Value<int> id,
  Value<String> displayName,
  Value<String> relationship,
  Value<String?> sex,
  Value<DateTime?> dateOfBirth,
  Value<double?> heightCm,
  Value<String> knownNames,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$PersonProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonProfilesTable> {
  $$PersonProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get knownNames => $composableBuilder(
      column: $table.knownNames, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PersonProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonProfilesTable> {
  $$PersonProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationship => $composableBuilder(
      column: $table.relationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get knownNames => $composableBuilder(
      column: $table.knownNames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PersonProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonProfilesTable> {
  $$PersonProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get knownNames => $composableBuilder(
      column: $table.knownNames, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PersonProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonProfilesTable,
    PersonProfile,
    $$PersonProfilesTableFilterComposer,
    $$PersonProfilesTableOrderingComposer,
    $$PersonProfilesTableAnnotationComposer,
    $$PersonProfilesTableCreateCompanionBuilder,
    $$PersonProfilesTableUpdateCompanionBuilder,
    (
      PersonProfile,
      BaseReferences<_$AppDatabase, $PersonProfilesTable, PersonProfile>
    ),
    PersonProfile,
    PrefetchHooks Function()> {
  $$PersonProfilesTableTableManager(
      _$AppDatabase db, $PersonProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> relationship = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String> knownNames = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PersonProfilesCompanion(
            id: id,
            displayName: displayName,
            relationship: relationship,
            sex: sex,
            dateOfBirth: dateOfBirth,
            heightCm: heightCm,
            knownNames: knownNames,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> relationship = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String> knownNames = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              PersonProfilesCompanion.insert(
            id: id,
            displayName: displayName,
            relationship: relationship,
            sex: sex,
            dateOfBirth: dateOfBirth,
            heightCm: heightCm,
            knownNames: knownNames,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonProfilesTable,
    PersonProfile,
    $$PersonProfilesTableFilterComposer,
    $$PersonProfilesTableOrderingComposer,
    $$PersonProfilesTableAnnotationComposer,
    $$PersonProfilesTableCreateCompanionBuilder,
    $$PersonProfilesTableUpdateCompanionBuilder,
    (
      PersonProfile,
      BaseReferences<_$AppDatabase, $PersonProfilesTable, PersonProfile>
    ),
    PersonProfile,
    PrefetchHooks Function()>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<int> profileId,
  required String kind,
  Value<String?> conditionCode,
  Value<String?> followUpKey,
  Value<bool> autoGenerated,
  Value<String> sourceType,
  Value<String?> areaName,
  Value<DateTime?> recommendedDate,
  required String title,
  Value<String?> detail,
  Value<String?> relatedMetricId,
  Value<int?> relatedMedicationId,
  Value<DateTime?> dueDate,
  Value<String?> dailyTimes,
  Value<bool> enabled,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> kind,
  Value<String?> conditionCode,
  Value<String?> followUpKey,
  Value<bool> autoGenerated,
  Value<String> sourceType,
  Value<String?> areaName,
  Value<DateTime?> recommendedDate,
  Value<String> title,
  Value<String?> detail,
  Value<String?> relatedMetricId,
  Value<int?> relatedMedicationId,
  Value<DateTime?> dueDate,
  Value<String?> dailyTimes,
  Value<bool> enabled,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followUpKey => $composableBuilder(
      column: $table.followUpKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoGenerated => $composableBuilder(
      column: $table.autoGenerated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recommendedDate => $composableBuilder(
      column: $table.recommendedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedMetricId => $composableBuilder(
      column: $table.relatedMetricId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get relatedMedicationId => $composableBuilder(
      column: $table.relatedMedicationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dailyTimes => $composableBuilder(
      column: $table.dailyTimes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followUpKey => $composableBuilder(
      column: $table.followUpKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoGenerated => $composableBuilder(
      column: $table.autoGenerated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recommendedDate => $composableBuilder(
      column: $table.recommendedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedMetricId => $composableBuilder(
      column: $table.relatedMetricId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get relatedMedicationId => $composableBuilder(
      column: $table.relatedMedicationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dailyTimes => $composableBuilder(
      column: $table.dailyTimes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => column);

  GeneratedColumn<String> get followUpKey => $composableBuilder(
      column: $table.followUpKey, builder: (column) => column);

  GeneratedColumn<bool> get autoGenerated => $composableBuilder(
      column: $table.autoGenerated, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<DateTime> get recommendedDate => $composableBuilder(
      column: $table.recommendedDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get relatedMetricId => $composableBuilder(
      column: $table.relatedMetricId, builder: (column) => column);

  GeneratedColumn<int> get relatedMedicationId => $composableBuilder(
      column: $table.relatedMedicationId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dailyTimes => $composableBuilder(
      column: $table.dailyTimes, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<String?> followUpKey = const Value.absent(),
            Value<bool> autoGenerated = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> areaName = const Value.absent(),
            Value<DateTime?> recommendedDate = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String?> relatedMetricId = const Value.absent(),
            Value<int?> relatedMedicationId = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> dailyTimes = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            profileId: profileId,
            kind: kind,
            conditionCode: conditionCode,
            followUpKey: followUpKey,
            autoGenerated: autoGenerated,
            sourceType: sourceType,
            areaName: areaName,
            recommendedDate: recommendedDate,
            title: title,
            detail: detail,
            relatedMetricId: relatedMetricId,
            relatedMedicationId: relatedMedicationId,
            dueDate: dueDate,
            dailyTimes: dailyTimes,
            enabled: enabled,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String kind,
            Value<String?> conditionCode = const Value.absent(),
            Value<String?> followUpKey = const Value.absent(),
            Value<bool> autoGenerated = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> areaName = const Value.absent(),
            Value<DateTime?> recommendedDate = const Value.absent(),
            required String title,
            Value<String?> detail = const Value.absent(),
            Value<String?> relatedMetricId = const Value.absent(),
            Value<int?> relatedMedicationId = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> dailyTimes = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              RemindersCompanion.insert(
            id: id,
            profileId: profileId,
            kind: kind,
            conditionCode: conditionCode,
            followUpKey: followUpKey,
            autoGenerated: autoGenerated,
            sourceType: sourceType,
            areaName: areaName,
            recommendedDate: recommendedDate,
            title: title,
            detail: detail,
            relatedMetricId: relatedMetricId,
            relatedMedicationId: relatedMedicationId,
            dueDate: dueDate,
            dailyTimes: dailyTimes,
            enabled: enabled,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<int?> reminderId,
  required String category,
  required String title,
  Value<String?> body,
  required DateTime scheduledFor,
  Value<DateTime?> deliveredAt,
  Value<DateTime?> readAt,
  Value<String> channel,
  required DateTime createdAt,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<int?> reminderId,
  Value<String> category,
  Value<String> title,
  Value<String?> body,
  Value<DateTime> scheduledFor,
  Value<DateTime?> deliveredAt,
  Value<DateTime?> readAt,
  Value<String> channel,
  Value<DateTime> createdAt,
});

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    NotificationRecord,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      NotificationRecord,
      BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRecord>
    ),
    NotificationRecord,
    PrefetchHooks Function()> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int?> reminderId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<DateTime> scheduledFor = const Value.absent(),
            Value<DateTime?> deliveredAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<String> channel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            profileId: profileId,
            reminderId: reminderId,
            category: category,
            title: title,
            body: body,
            scheduledFor: scheduledFor,
            deliveredAt: deliveredAt,
            readAt: readAt,
            channel: channel,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int?> reminderId = const Value.absent(),
            required String category,
            required String title,
            Value<String?> body = const Value.absent(),
            required DateTime scheduledFor,
            Value<DateTime?> deliveredAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<String> channel = const Value.absent(),
            required DateTime createdAt,
          }) =>
              NotificationsCompanion.insert(
            id: id,
            profileId: profileId,
            reminderId: reminderId,
            category: category,
            title: title,
            body: body,
            scheduledFor: scheduledFor,
            deliveredAt: deliveredAt,
            readAt: readAt,
            channel: channel,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    NotificationRecord,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      NotificationRecord,
      BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRecord>
    ),
    NotificationRecord,
    PrefetchHooks Function()>;
typedef $$EncountersTableCreateCompanionBuilder = EncountersCompanion Function({
  Value<int> id,
  Value<int> profileId,
  required DateTime visitDate,
  Value<String> hospitalName,
  Value<String> department,
  Value<String?> diagnosis,
  Value<String?> advice,
  Value<String?> notes,
  Value<String?> conditionCode,
  required DateTime createdAt,
});
typedef $$EncountersTableUpdateCompanionBuilder = EncountersCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<DateTime> visitDate,
  Value<String> hospitalName,
  Value<String> department,
  Value<String?> diagnosis,
  Value<String?> advice,
  Value<String?> notes,
  Value<String?> conditionCode,
  Value<DateTime> createdAt,
});

class $$EncountersTableFilterComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get advice => $composableBuilder(
      column: $table.advice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$EncountersTableOrderingComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get advice => $composableBuilder(
      column: $table.advice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get hospitalName => $composableBuilder(
      column: $table.hospitalName, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get advice =>
      $composableBuilder(column: $table.advice, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get conditionCode => $composableBuilder(
      column: $table.conditionCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EncountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$AppDatabase, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()> {
  $$EncountersTableTableManager(_$AppDatabase db, $EncountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<DateTime> visitDate = const Value.absent(),
            Value<String> hospitalName = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> advice = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EncountersCompanion(
            id: id,
            profileId: profileId,
            visitDate: visitDate,
            hospitalName: hospitalName,
            department: department,
            diagnosis: diagnosis,
            advice: advice,
            notes: notes,
            conditionCode: conditionCode,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required DateTime visitDate,
            Value<String> hospitalName = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> advice = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> conditionCode = const Value.absent(),
            required DateTime createdAt,
          }) =>
              EncountersCompanion.insert(
            id: id,
            profileId: profileId,
            visitDate: visitDate,
            hospitalName: hospitalName,
            department: department,
            diagnosis: diagnosis,
            advice: advice,
            notes: notes,
            conditionCode: conditionCode,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EncountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$AppDatabase, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()>;
typedef $$AllergiesTableCreateCompanionBuilder = AllergiesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  required String substance,
  Value<String> category,
  Value<String?> reaction,
  Value<String> severity,
  Value<DateTime?> notedDate,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$AllergiesTableUpdateCompanionBuilder = AllergiesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> substance,
  Value<String> category,
  Value<String?> reaction,
  Value<String> severity,
  Value<DateTime?> notedDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$AllergiesTableFilterComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get substance => $composableBuilder(
      column: $table.substance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reaction => $composableBuilder(
      column: $table.reaction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get notedDate => $composableBuilder(
      column: $table.notedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AllergiesTableOrderingComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get substance => $composableBuilder(
      column: $table.substance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reaction => $composableBuilder(
      column: $table.reaction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get notedDate => $composableBuilder(
      column: $table.notedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AllergiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get substance =>
      $composableBuilder(column: $table.substance, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get reaction =>
      $composableBuilder(column: $table.reaction, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<DateTime> get notedDate =>
      $composableBuilder(column: $table.notedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AllergiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AllergiesTable,
    Allergy,
    $$AllergiesTableFilterComposer,
    $$AllergiesTableOrderingComposer,
    $$AllergiesTableAnnotationComposer,
    $$AllergiesTableCreateCompanionBuilder,
    $$AllergiesTableUpdateCompanionBuilder,
    (Allergy, BaseReferences<_$AppDatabase, $AllergiesTable, Allergy>),
    Allergy,
    PrefetchHooks Function()> {
  $$AllergiesTableTableManager(_$AppDatabase db, $AllergiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllergiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllergiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllergiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> substance = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> reaction = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<DateTime?> notedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AllergiesCompanion(
            id: id,
            profileId: profileId,
            substance: substance,
            category: category,
            reaction: reaction,
            severity: severity,
            notedDate: notedDate,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String substance,
            Value<String> category = const Value.absent(),
            Value<String?> reaction = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<DateTime?> notedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              AllergiesCompanion.insert(
            id: id,
            profileId: profileId,
            substance: substance,
            category: category,
            reaction: reaction,
            severity: severity,
            notedDate: notedDate,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AllergiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AllergiesTable,
    Allergy,
    $$AllergiesTableFilterComposer,
    $$AllergiesTableOrderingComposer,
    $$AllergiesTableAnnotationComposer,
    $$AllergiesTableCreateCompanionBuilder,
    $$AllergiesTableUpdateCompanionBuilder,
    (Allergy, BaseReferences<_$AppDatabase, $AllergiesTable, Allergy>),
    Allergy,
    PrefetchHooks Function()>;
typedef $$ReportOrgansTableCreateCompanionBuilder = ReportOrgansCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  required int reportId,
  required String areaName,
  required DateTime createdAt,
});
typedef $$ReportOrgansTableUpdateCompanionBuilder = ReportOrgansCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<int> reportId,
  Value<String> areaName,
  Value<DateTime> createdAt,
});

class $$ReportOrgansTableFilterComposer
    extends Composer<_$AppDatabase, $ReportOrgansTable> {
  $$ReportOrgansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReportOrgansTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportOrgansTable> {
  $$ReportOrgansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReportOrgansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportOrgansTable> {
  $$ReportOrgansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReportOrgansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportOrgansTable,
    ReportOrgan,
    $$ReportOrgansTableFilterComposer,
    $$ReportOrgansTableOrderingComposer,
    $$ReportOrgansTableAnnotationComposer,
    $$ReportOrgansTableCreateCompanionBuilder,
    $$ReportOrgansTableUpdateCompanionBuilder,
    (
      ReportOrgan,
      BaseReferences<_$AppDatabase, $ReportOrgansTable, ReportOrgan>
    ),
    ReportOrgan,
    PrefetchHooks Function()> {
  $$ReportOrgansTableTableManager(_$AppDatabase db, $ReportOrgansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportOrgansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportOrgansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportOrgansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<String> areaName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ReportOrgansCompanion(
            id: id,
            profileId: profileId,
            reportId: reportId,
            areaName: areaName,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required int reportId,
            required String areaName,
            required DateTime createdAt,
          }) =>
              ReportOrgansCompanion.insert(
            id: id,
            profileId: profileId,
            reportId: reportId,
            areaName: areaName,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportOrgansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportOrgansTable,
    ReportOrgan,
    $$ReportOrgansTableFilterComposer,
    $$ReportOrgansTableOrderingComposer,
    $$ReportOrgansTableAnnotationComposer,
    $$ReportOrgansTableCreateCompanionBuilder,
    $$ReportOrgansTableUpdateCompanionBuilder,
    (
      ReportOrgan,
      BaseReferences<_$AppDatabase, $ReportOrgansTable, ReportOrgan>
    ),
    ReportOrgan,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HealthMetricsTableTableManager get healthMetrics =>
      $$HealthMetricsTableTableManager(_db, _db.healthMetrics);
  $$DailyHealthRecordsTableTableManager get dailyHealthRecords =>
      $$DailyHealthRecordsTableTableManager(_db, _db.dailyHealthRecords);
  $$MedicalReportsTableTableManager get medicalReports =>
      $$MedicalReportsTableTableManager(_db, _db.medicalReports);
  $$DiseasesTableTableManager get diseases =>
      $$DiseasesTableTableManager(_db, _db.diseases);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
  $$PersonProfilesTableTableManager get personProfiles =>
      $$PersonProfilesTableTableManager(_db, _db.personProfiles);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$AllergiesTableTableManager get allergies =>
      $$AllergiesTableTableManager(_db, _db.allergies);
  $$ReportOrgansTableTableManager get reportOrgans =>
      $$ReportOrgansTableTableManager(_db, _db.reportOrgans);
}
