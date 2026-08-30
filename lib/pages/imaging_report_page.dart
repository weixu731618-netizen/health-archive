import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/image_storage.dart';

/// 图文类报告 / 病历的可选类型。这类是"图片 + 文字"，没有可提取的数字指标，
/// 跟化验单走不同的存档路径。
/// 慢病升级 步骤5：在影像/病理之外，补上出院小结、手术记录、门诊病历、处方笺、疫苗接种。
const List<String> imagingReportTypes = [
  'X光',
  'CT',
  'MRI',
  'B超',
  '心电图',
  '病理',
  '出院小结',
  '手术记录',
  '门诊病历',
  '处方笺',
  '疫苗接种',
  '其他',
];

/// 添加影像/病理报告：拍照或选图 → 自动 OCR 提取全部文字（含诊断结论，可编辑修正）
/// → 手填医院/日期/类型 → 保存为一条 medical_reports 记录，不关联任何检查指标。
class ImagingReportPage extends StatefulWidget {
  const ImagingReportPage({super.key});

  @override
  State<ImagingReportPage> createState() => _ImagingReportPageState();
}

class _ImagingReportPageState extends State<ImagingReportPage> {
  PickedReportImage? _image;
  final _textCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  String _reportType = imagingReportTypes.first;
  DateTime _reportDate = DateTime.now();

  bool _ocrRunning = false;
  String? _ocrError;
  bool _saving = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() => _pick(captureLabReportImage);
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _reportDate = picked);
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
    setState(() => _saving = true);
    try {
      await repo.insertReport(
        hospitalName: _hospitalCtrl.text.trim(),
        reportDate: _reportDate,
        reportType: _reportType,
        sourceImagePath: _image!.path,
        rawText: _textCtrl.text.trim().isEmpty ? null : _textCtrl.text.trim(),
        recognitionStatus: 'confirmed',
      );
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加影像/病理报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '适用于 X光/CT/MRI/B超/心电图/病理这类图文报告：没有可提取的数字指标，'
              '拍照、选图或选 PDF 后系统会自动识别文字（含诊断结论），可以再编辑修正，原件会一并保存归档。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _image == null
                  ? Column(
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        const Text('尚未选择图片',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _pickFromCamera,
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('拍照'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickFromFile,
                              icon: const Icon(Icons.add_photo_alternate_outlined),
                              label: const Text('选图片 / PDF'),
                            ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: _pickFromCamera, child: const Text('重新拍照')),
                            const SizedBox(width: 8),
                            TextButton(
                                onPressed: _pickFromFile, child: const Text('重新选择')),
                          ],
                        ),
                      ],
                    ),
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
            onChanged: (v) => setState(() => _reportType = v ?? _reportType),
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
          Row(
            children: [
              const Text('识别文字（可编辑修正）',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (_ocrRunning)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
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
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(_saving ? '保存中…' : '保存', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
