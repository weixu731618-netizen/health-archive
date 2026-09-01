import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/toast.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../models/body_area_health.dart';
import '../models/report_followup.dart';
import '../utils/image_storage.dart';
import '../utils/imaging_text_parse.dart';
import '../utils/report_image_save.dart';
import '../widgets/privacy_note.dart';
import 'followup_match.dart';
import 'report_profile_guard.dart';

/// 图文类报告 / 病历的可选类型。这类是"图片 + 文字"，没有可提取的数字指标，
/// 跟化验单走不同的存档路径。
/// 慢病升级 步骤5：在影像/病理之外，补上出院小结、手术记录、门诊病历、处方笺、疫苗接种。
/// 受限 12 类。**没有「其他」** —— 归不到这 12 类的图文内容走「未关联记录」，
/// 不再往这个列表里塞模糊选项。与 report_recognition_service.kImagingReportTypes 一致。
const List<String> imagingReportTypes = [
  'X光',
  'CT',
  'MRI',
  'B超',
  '彩超',
  '心电图',
  '病理',
  '出院小结',
  '手术记录',
  '门诊病历',
  '处方笺',
  '疫苗接种',
];

/// 添加图文报告 / 病历：拍照或选图 → 自动 OCR 提取全部文字（含诊断结论，可编辑修正）
/// → 手填医院/日期/类型 → 保存为一条 medical_reports 记录，不关联任何检查指标。
///
/// 两种进入方式：
/// - 直接进（器官详情页 `+`）：本页自己选图 + 调 `/api/report/ocr`。
/// - [ImagingReportPage.prefilled]：上传/拍照统一流程识别后发现没有结构化指标，
///   把已识别的图 + OCR 全文 + 猜出的类型/日期/部位带进来，本页不再重复 OCR。
class ImagingReportPage extends StatefulWidget {
  /// 从某个器官 / 系统详情页的 `+` 进来时传入该部位名，作为「建议关联」默认勾上。
  final String? initialArea;

  /// 预填模式（来自统一识别流程）。null = 用户自己选图那条老路径。
  final ImagingPrefill? prefill;

  const ImagingReportPage({super.key, this.initialArea}) : prefill = null;

  ImagingReportPage.prefilled({
    super.key,
    required PickedReportImage image,
    required String ocrText,
    String patientName = '',
    String patientGender = '',
    DateTime? patientBirthDate,
    DateTime? reportDate,
    String hospitalName = '',
    String reportType = '', // 已确定的类型（DeepSeek imagingType / 用户手选）；空=页面自己猜
    this.initialArea,
  }) : prefill = ImagingPrefill(
          image: image,
          ocrText: ocrText,
          patientName: patientName,
          patientGender: patientGender,
          patientBirthDate: patientBirthDate,
          reportDate: reportDate,
          hospitalName: hospitalName,
          reportType: reportType,
        );

  @override
  State<ImagingReportPage> createState() => _ImagingReportPageState();
}

/// 统一识别流程传进来的预填数据。
class ImagingPrefill {
  final PickedReportImage image;
  final String ocrText;
  final String patientName;
  final String patientGender;
  final DateTime? patientBirthDate;
  final DateTime? reportDate;
  final String hospitalName;
  final String reportType;

  const ImagingPrefill({
    required this.image,
    required this.ocrText,
    required this.patientName,
    required this.patientGender,
    required this.patientBirthDate,
    required this.reportDate,
    required this.hospitalName,
    this.reportType = '',
  });
}

class _ImagingReportPageState extends State<ImagingReportPage> {
  PickedReportImage? _image;
  final _textCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  // 直接进入本页（器官详情页 +）时的默认类型；预填模式一定会带来确定的类型覆盖它。
  String _reportType = imagingReportTypes.first;
  DateTime _reportDate = DateTime.now();

  /// 用户是否手动改过「报告类型 / 检查日期」。改过之后 OCR 就不再覆盖预填。
  bool _typeTouched = false;
  bool _dateTouched = false;

  /// 这份影像涉及的身体部位（手选，影像没有指标推不出来）。
  /// 从器官详情页进来时预置该部位（[ImagingReportPage.initialArea]），用户可改。
  late final Set<String> _organs = {
    if (widget.initialArea != null &&
        coreBodyAreaOrder.contains(widget.initialArea))
      widget.initialArea!,
  };

  /// 可选的复查安排：null = 不设；否则为「多少天之后」。
  int? _recheckDays;

  bool _ocrRunning = false;
  String? _ocrError;
  bool _saving = false;
  bool _saved = false;

  /// 预填模式带进来的患者信息（保存时用于「家庭成员核对」）。
  String _patientName = '';
  String _patientGender = '';
  DateTime? _patientBirthDate;

  @override
  void initState() {
    super.initState();
    final pre = widget.prefill;
    if (pre != null) {
      _image = pre.image;
      _textCtrl.text = pre.ocrText;
      _hospitalCtrl.text = pre.hospitalName;
      _patientName = pre.patientName;
      _patientGender = pre.patientGender;
      _patientBirthDate = pre.patientBirthDate;
      if (pre.reportType.isNotEmpty &&
          imagingReportTypes.contains(pre.reportType)) {
        _reportType = pre.reportType;
        _typeTouched = true; // 类型已确定，别让文本猜测覆盖
      }
      if (pre.reportDate != null) {
        _reportDate = pre.reportDate!;
        _dateTouched = true; // 后端给了日期，别让文本猜测覆盖
      }
      _applyGuessesFromText(pre.ocrText);
    }
  }

  @override
  void dispose() {
    // 预填模式下用户没保存就退出：清掉带进来的原图，避免磁盘留孤儿文件。
    if (widget.prefill != null && !_saved) {
      deleteManagedReportImage(_image?.path);
    }
    _textCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() => _pick(captureLabReportImage);
  Future<void> _pickFromGallery() => _pick(pickReportImageFromGallery);
  Future<void> _pickFromFile() => _pick(pickLabReportImage);

  Future<void> _pick(Future<PickedReportImage> Function() picker) async {
    try {
      final img = await picker();
      if (!mounted) return;
      setState(() => _image = img);
      await _runOcr(img);
    } catch (_) {
      if (mounted) _toast('无法读取该图片，请重试');
    }
  }

  Future<void> _runOcr(PickedReportImage img) async {
    setState(() {
      _ocrRunning = true;
      _ocrError = null;
    });
    try {
      final lines = await reportOcrService.ocrImage(
        imageBytes: img.bytes,
        fileName: img.fileName,
      );
      final text = lines.map((l) => l.text).join('\n');
      if (mounted) {
        setState(() {
          // 只在文本框为空时自动填入，避免覆盖用户已经手动编辑过的内容。
          if (_textCtrl.text.trim().isEmpty) _textCtrl.text = text;
          _applyGuessesFromText(text);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _ocrError = '文字识别未完成，可以手动填写或修正下方内容：$e');
      }
    } finally {
      if (mounted) setState(() => _ocrRunning = false);
    }
  }

  /// 用 OCR 文本轻量预填「报告类型 / 检查日期 / 涉及身体部位」。
  /// 只在用户还没手动改过对应字段时填；调用方已包在 setState 里。
  void _applyGuessesFromText(String text) {
    if (!_typeTouched) {
      final t = guessImagingReportType(text);
      if (t != null) _reportType = t;
    }
    if (!_dateTouched) {
      final d = guessReportDate(text);
      if (d != null) _reportDate = d;
    }
    if (_organs.isEmpty) {
      _organs.addAll(guessBodyAreas(text).where(coreBodyAreaOrder.contains));
    }
  }

  Future<void> _pickDate() async {
    final picked = await pickCupertinoDate(context, initial: _reportDate, minimumDate: DateTime(2000), maximumDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _reportDate = picked;
        _dateTouched = true;
      });
    }
  }

  Future<void> _save() async {
    if (_image == null) {
      _toast('请先拍照或选择图片');
      return;
    }
    final repo = appRepository;
    if (repo == null) {
      _toast('数据库未就绪');
      return;
    }
    // 家庭成员核对：姓名对不上当前档案则提醒；报告读到的性别/生日可补进档案资料。
    final ok = await guardReportAgainstActiveProfile(
      context,
      ocrPatientName: _patientName,
      ocrGender: _patientGender,
      ocrBirthDate: _patientBirthDate,
    );
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    try {
      final reportId = await repo.insertReport(
        hospitalName: _hospitalCtrl.text.trim(),
        reportDate: _reportDate,
        reportType: _reportType,
        sourceImagePath: _image!.path,
        rawText: _textCtrl.text.trim().isEmpty ? null : _textCtrl.text.trim(),
        recognitionStatus: 'confirmed',
      );

      if (_organs.isNotEmpty) {
        await repo.setReportOrgans(reportId, _organs);
      }

      if (_recheckDays != null) {
        final due = _reportDate.add(Duration(days: _recheckDays!));
        await repo.insertReminder(
          kind: 'recheck',
          title: '复查 $_reportType',
          detail: '影像报告建议复查',
          sourceType: 'report',
          areaName: _organs.isEmpty ? null : _organs.first,
          dueDate: due,
          recommendedDate: due,
        );
        await syncReminders();
      }

      if (mounted) {
        await offerFollowUpLink(
          context,
          reportAreas: _organs,
          reportDate: _reportDate,
        );
      }

      _saved = true;
      if (mounted) {
        _toast('已保存');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) _toast('保存失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String s) {
    showToast(context, s);
  }

  String _recheckLabel() {
    for (final e in kRecheckIntervalOptions.entries) {
      if (e.value == _recheckDays) return e.key;
    }
    return '$_recheckDays 天后';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加图文报告 / 病历')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '适用于 X光/CT/MRI/超声/心电图/病理，以及出院小结、手术记录、门诊病历、处方、疫苗接种这类'
              '图文报告：没有可提取的数字指标，识别出文字（含诊断结论）后可再编辑修正，原件会一并保存归档。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const PrivacyNote(),
          HealthCard(
            child: _image == null
                  ? Column(
                      children: [
                        const Icon(CupertinoIcons.photo,
                            size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        const Text('拍照，或从相册选截图 / 从文件选 PDF',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            IosButton.tinted('拍照',
                                icon: CupertinoIcons.camera,
                                onPressed: _pickFromCamera),
                            IosButton.tinted('相册',
                                icon: CupertinoIcons.photo_on_rectangle,
                                onPressed: _pickFromGallery),
                            IosButton.tinted('PDF / 文件',
                                icon: CupertinoIcons.folder,
                                onPressed: _pickFromFile),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _image!.bytes,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            IosButton.plain('重新拍照',
                                onPressed: _pickFromCamera),
                            IosButton.plain('相册', onPressed: _pickFromGallery),
                            IosButton.plain('PDF / 文件',
                                onPressed: _pickFromFile),
                          ],
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _reportType,
            decoration: const InputDecoration(labelText: '报告类型'),
            items: [
              for (final t in imagingReportTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() {
              _reportType = v ?? _reportType;
              _typeTouched = true;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hospitalCtrl,
            decoration: const InputDecoration(labelText: '医院（可留空）'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: '检查日期'),
              child: Text(
                '${_reportDate.year}-${_reportDate.month.toString().padLeft(2, '0')}-${_reportDate.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('涉及的身体部位（多选，可留空）',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final a in coreBodyAreaOrder)
                FilterChip(
                  label: Text(a),
                  selected: _organs.contains(a),
                  onSelected: (s) => setState(
                      () => s ? _organs.add(a) : _organs.remove(a)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('设置复查提醒'),
            subtitle: Text(_recheckDays == null
                ? '报告写了「建议随访 / 复查」时打开'
                : '${_recheckLabel()} · 到期会提醒你'),
            value: _recheckDays != null,
            onChanged: (on) async {
              if (!on) {
                setState(() => _recheckDays = null);
                return;
              }
              final days = await showCupertinoModalPopup<int>(
                context: context,
                builder: (ctx) => CupertinoActionSheet(
                  title: const Text('参考复查时间'),
                  actions: [
                    for (final e in kRecheckIntervalOptions.entries)
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(ctx, e.value),
                        child: Text(e.key),
                      ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消'),
                  ),
                ),
              );
              if (days != null) setState(() => _recheckDays = days);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('识别文字（可编辑修正）',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (_ocrRunning) const CupertinoActivityIndicator(radius: 8),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textCtrl,
            maxLines: 8,
            minLines: 4,
            decoration: const InputDecoration(
              hintText: '拍照/选图后会自动填入识别结果；识别失败或不准确时可以在这里手动修正',
              border: OutlineInputBorder(),
            ),
          ),
          if (_ocrError != null) ...[
            const SizedBox(height: 8),
            Text(_ocrError!,
                style: const TextStyle(fontSize: 13, color: AppColors.abnormal)),
          ],
          const SizedBox(height: 24),
          IosButton.filled(_saving ? '保存中…' : '保存',
              onPressed: _saving ? null : _save, expand: true),
        ],
      ),
    );
  }
}
