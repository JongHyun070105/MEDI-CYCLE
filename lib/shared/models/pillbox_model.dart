import 'package:freezed_annotation/freezed_annotation.dart';

part 'pillbox_model.freezed.dart';
part 'pillbox_model.g.dart';

@freezed
class PillboxStatus with _$PillboxStatus {
  const factory PillboxStatus({
    required int id,
    required int userId,
    required bool detected,
    int? batteryPercent,
    required bool isLocked,
    required DateTime updatedAt,
  }) = _PillboxStatus;

  factory PillboxStatus.fromJson(Map<String, dynamic> json) => 
      _$PillboxStatusFromJson(json);
}

@freezed
class PillboxStatusUpdate with _$PillboxStatusUpdate {
  const factory PillboxStatusUpdate({
    bool? detected,
    int? batteryPercent,
    bool? isLocked,
  }) = _PillboxStatusUpdate;

  factory PillboxStatusUpdate.fromJson(Map<String, dynamic> json) => 
      _$PillboxStatusUpdateFromJson(json);
}


