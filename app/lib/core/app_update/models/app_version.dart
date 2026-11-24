import 'package:equatable/equatable.dart';

class AppVersion extends Equatable implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;

  const AppVersion(this.major, this.minor, this.patch);

  static final RegExp _pattern =
      RegExp(r'^[vV]?(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$');

  static AppVersion? tryParse(String value) {
    final match = _pattern.firstMatch(value.trim());
    if (match == null) return null;
    return AppVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  factory AppVersion.parse(String value) {
    final version = tryParse(value);
    if (version == null) {
      throw FormatException('Versão inválida', value);
    }
    return version;
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  List<Object?> get props => [major, minor, patch];
}
