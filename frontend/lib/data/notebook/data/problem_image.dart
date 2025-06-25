import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_image.freezed.dart';
part 'problem_image.g.dart';

@freezed
abstract class ProblemImage with _$ProblemImage {
  const factory ProblemImage({
    required int id,
    required String uid,
    required String originalFilename,
    required String filename,
    required String fileUrl,
    required String mimeType,
    required int fileSize,
    int? width,
    int? height,
    required int displayOrder,
    required DateTime createdAt,
  }) = _ProblemImage;

  factory ProblemImage.fromJson(Map<String, dynamic> json) =>
      _$ProblemImageFromJson(json);
}