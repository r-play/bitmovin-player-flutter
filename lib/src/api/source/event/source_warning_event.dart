import 'package:bitmovin_player/src/api/event.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'source_warning_event.g.dart';

@JsonSerializable(explicitToJson: true)
class SourceWarningEvent extends Event with EquatableMixin {
  const SourceWarningEvent({
    required this.code,
    this.message,
    super.timestamp,
  });

  factory SourceWarningEvent.fromJson(Map<String, dynamic> json) {
    return _$SourceWarningEventFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$SourceWarningEventToJson(this);

  @override
  List<Object?> get props => [code, message, timestamp];

  @JsonKey(name: 'code', defaultValue: null)
  final int code;

  @JsonKey(name: 'message', defaultValue: null)
  final String? message;
}
