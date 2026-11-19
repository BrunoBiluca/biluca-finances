import 'package:equatable/equatable.dart';

class RemoteBackupFile extends Equatable {
  final String id;
  final DateTime? modifiedAt;
  final int? size;

  const RemoteBackupFile({
    required this.id,
    this.modifiedAt,
    this.size,
  });

  @override
  List<Object?> get props => [id, modifiedAt, size];
}
