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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, hospitalName, reportDate,
      reportType, sourceImagePath, rawText, recognitionStatus, createdAt);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, name, foundDate, status, notes, createdAt];
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
  const Disease(
      {required this.id,
      required this.profileId,
      required this.name,
      this.foundDate,
      required this.status,
      this.notes,
      required this.createdAt});
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
    };
  }

  Disease copyWith(
          {int? id,
          int? profileId,
          String? name,
          Value<DateTime?> foundDate = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Disease(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        foundDate: foundDate.present ? foundDate.value : this.foundDate,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, name, foundDate, status, notes, createdAt);
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
          other.createdAt == this.createdAt);
}

class DiseasesCompanion extends UpdateCompanion<Disease> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<DateTime?> foundDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DiseasesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.foundDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiseasesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    this.foundDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (foundDate != null) 'found_date': foundDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiseasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? name,
      Value<DateTime?>? foundDate,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return DiseasesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      foundDate: foundDate ?? this.foundDate,
      status: status ?? this.status,
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
          ..write('createdAt: $createdAt')
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
        timesPerDay,
        startDate,
        endDate,
        status,
        notes,
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
  final String? timesPerDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const Medication(
      {required this.id,
      required this.profileId,
      required this.name,
      this.dosage,
      this.dosageUnit,
      this.timesPerDay,
      this.startDate,
      this.endDate,
      required this.status,
      this.notes,
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
      timesPerDay: serializer.fromJson<String?>(json['timesPerDay']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
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
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String?>(dosage),
      'dosageUnit': serializer.toJson<String?>(dosageUnit),
      'timesPerDay': serializer.toJson<String?>(timesPerDay),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Medication copyWith(
          {int? id,
          int? profileId,
          String? name,
          Value<String?> dosage = const Value.absent(),
          Value<String?> dosageUnit = const Value.absent(),
          Value<String?> timesPerDay = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Medication(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        dosage: dosage.present ? dosage.value : this.dosage,
        dosageUnit: dosageUnit.present ? dosageUnit.value : this.dosageUnit,
        timesPerDay: timesPerDay.present ? timesPerDay.value : this.timesPerDay,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
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
      timesPerDay:
          data.timesPerDay.present ? data.timesPerDay.value : this.timesPerDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
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
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, name, dosage, dosageUnit,
      timesPerDay, startDate, endDate, status, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.dosageUnit == this.dosageUnit &&
          other.timesPerDay == this.timesPerDay &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<String?> dosage;
  final Value<String?> dosageUnit;
  final Value<String?> timesPerDay;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? dosageUnit,
    Expression<String>? timesPerDay,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (dosageUnit != null) 'dosage_unit': dosageUnit,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? name,
      Value<String?>? dosage,
      Value<String?>? dosageUnit,
      Value<String?>? timesPerDay,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (dosageUnit.present) {
      map['dosage_unit'] = Variable<String>(dosageUnit.value);
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
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
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
  List<GeneratedColumn> get $columns =>
      [id, displayName, relationship, sex, dateOfBirth, createdAt, updatedAt];
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
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonProfile(
      {required this.id,
      required this.displayName,
      required this.relationship,
      this.sex,
      this.dateOfBirth,
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
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PersonProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        relationship: relationship ?? this.relationship,
        sex: sex.present ? sex.value : this.sex,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, displayName, relationship, sex, dateOfBirth, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.relationship == this.relationship &&
          other.sex == this.sex &&
          other.dateOfBirth == this.dateOfBirth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonProfilesCompanion extends UpdateCompanion<PersonProfile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> relationship;
  final Value<String?> sex;
  final Value<DateTime?> dateOfBirth;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PersonProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PersonProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
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
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (relationship != null) 'relationship': relationship,
      if (sex != null) 'sex': sex,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
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
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PersonProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      relationship: relationship ?? this.relationship,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
        personProfiles
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
});
typedef $$DiseasesTableUpdateCompanionBuilder = DiseasesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<DateTime?> foundDate,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
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
          }) =>
              DiseasesCompanion(
            id: id,
            profileId: profileId,
            name: name,
            foundDate: foundDate,
            status: status,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String name,
            Value<DateTime?> foundDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              DiseasesCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            foundDate: foundDate,
            status: status,
            notes: notes,
            createdAt: createdAt,
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
  Value<String?> timesPerDay,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> status,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<String?> dosage,
  Value<String?> dosageUnit,
  Value<String?> timesPerDay,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> status,
  Value<String?> notes,
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
            Value<String?> timesPerDay = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MedicationsCompanion(
            id: id,
            profileId: profileId,
            name: name,
            dosage: dosage,
            dosageUnit: dosageUnit,
            timesPerDay: timesPerDay,
            startDate: startDate,
            endDate: endDate,
            status: status,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            required String name,
            Value<String?> dosage = const Value.absent(),
            Value<String?> dosageUnit = const Value.absent(),
            Value<String?> timesPerDay = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MedicationsCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            dosage: dosage,
            dosageUnit: dosageUnit,
            timesPerDay: timesPerDay,
            startDate: startDate,
            endDate: endDate,
            status: status,
            notes: notes,
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PersonProfilesCompanion(
            id: id,
            displayName: displayName,
            relationship: relationship,
            sex: sex,
            dateOfBirth: dateOfBirth,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> relationship = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              PersonProfilesCompanion.insert(
            id: id,
            displayName: displayName,
            relationship: relationship,
            sex: sex,
            dateOfBirth: dateOfBirth,
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
}
