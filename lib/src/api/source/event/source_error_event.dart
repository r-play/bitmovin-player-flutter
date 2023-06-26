import 'package:bitmovin_player/src/api/event.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'source_error_event.g.dart';

@JsonSerializable(explicitToJson: true)
class SourceErrorEvent extends Event with EquatableMixin {
  const SourceErrorEvent({
    required this.code,
    this.message,
    super.timestamp,
  });

  factory SourceErrorEvent.fromJson(Map<String, dynamic> json) {
    return _$SourceErrorEventFromJson(json);
  }

  @override
  List<Object?> get props => [
        code,
        message,
        timestamp,
      ];

  @JsonKey(name: 'code', defaultValue: null)
  final int code;

  @JsonKey(name: 'message', defaultValue: null)
  final String? message;

  @override
  Map<String, dynamic> toJson() => _$SourceErrorEventToJson(this);
}
