/// 报告患者姓名 vs 家庭档案的比对（防止把报告存错家庭成员）。
///
/// 纯函数，无副作用。OCR 姓名不完美、写法五花八门，所以：
/// - 比对前做宽松规范化（去空格标点、去「先生/女士」等后缀）
/// - 只在「明显不一致」时提醒，永远是提醒而非拦截
/// - OCR 没读到姓名（空）时不发表意见
library;

/// 档案对某份报告姓名的核对结论。
enum NameCheckResult {
  /// OCR 没读到姓名，或档案还没记过任何真名——不打扰。
  noOpinion,

  /// 一致（含：与该档案已记住的任一真名一致）。
  ok,

  /// 档案第一次遇到真名，应静默记住（不弹框）。
  firstSeen,

  /// 与档案已记住的真名明显不一致——应提醒用户是否存错档案。
  mismatch,
}

const _honorifics = ['先生', '女士', '女土', '小姐', '同志', '患者', '病人', '受检者', '本人'];

/// 姓名规范化：转小写、去空白与常见标点、去掉尾部称谓。CJK 与字母数字保留。
String normalizePersonName(String raw) {
  var s = raw.trim().toLowerCase();
  for (final ch in const [' ', '\t', '　', '·', '.', '．', '、', ',', '，', ':', '：', '(', ')', '（', '）', '*']) {
    s = s.replaceAll(ch, '');
  }
  for (final h in _honorifics) {
    if (s.endsWith(h.toLowerCase())) s = s.substring(0, s.length - h.length);
  }
  return s;
}

/// 两个姓名是否「宽松相等」。任一为空 → false（无法判断，交调用方处理）。
bool personNamesLooselyEqual(String a, String b) {
  final na = normalizePersonName(a);
  final nb = normalizePersonName(b);
  if (na.isEmpty || nb.isEmpty) return false;
  return na == nb;
}

/// 从逗号分隔的 knownNames 串解析成去重列表。
List<String> parseKnownNames(String stored) => [
      for (final p in stored.split(',')) if (p.trim().isNotEmpty) p.trim(),
    ];

/// 把新名字并入 knownNames 串（宽松去重），返回新串。
String appendKnownName(String stored, String name) {
  final n = name.trim();
  if (n.isEmpty) return stored;
  final list = parseKnownNames(stored);
  if (list.any((k) => personNamesLooselyEqual(k, n))) return stored;
  list.add(n);
  return list.join(',');
}

/// 核对报告姓名与某个档案。[knownNamesStored] 为该档案 person_profiles.knownNames。
NameCheckResult checkReportNameAgainstProfile({
  required String ocrPatientName,
  required String knownNamesStored,
}) {
  if (normalizePersonName(ocrPatientName).isEmpty) return NameCheckResult.noOpinion;
  final known = parseKnownNames(knownNamesStored);
  if (known.isEmpty) return NameCheckResult.firstSeen;
  final hit = known.any((k) => personNamesLooselyEqual(k, ocrPatientName));
  return hit ? NameCheckResult.ok : NameCheckResult.mismatch;
}
