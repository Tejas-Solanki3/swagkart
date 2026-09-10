
String indianGroup(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final buf = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
    buf.write(rest[i]);
  }
  return '$buf,$last3';
}

/// Formats a rupee value: ₹1,29,999
String inr(double value, {bool withRupee = true}) {
  final rounded = value.round();
  final prefix = withRupee ? '₹' : '';
  return '$prefix${indianGroup(rounded)}';
}

/// Two-decimal variant for stats: ₹7,640.50
String inrDecimals(double value) {
  final str = value.toStringAsFixed(2);
  final parts = str.split('.');
  return '₹${indianGroup(int.parse(parts[0]))}.${parts[1]}';
}

String pct(double value) => '${value.round()}%';

String compactCount(int n) {
  if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
