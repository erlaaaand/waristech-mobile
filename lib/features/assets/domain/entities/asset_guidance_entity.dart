/// Panduan dokumen & langkah resmi untuk aset berkustodi GUIDANCE
/// (kredensial TIDAK dititipkan ke sistem). Cocok dengan `InheritanceGuidance`
/// backend (`GET /assets/:id/guidance`, juga disertakan saat `POST /assets`
/// untuk aset GUIDANCE).
class AssetGuidanceEntity {
  final String summary;
  final List<String> requiredDocuments;
  final List<String> steps;
  final List<String> legalBasis;

  const AssetGuidanceEntity({
    required this.summary,
    required this.requiredDocuments,
    required this.steps,
    required this.legalBasis,
  });

  factory AssetGuidanceEntity.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic v) =>
        (v as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return AssetGuidanceEntity(
      summary: json['summary']?.toString() ?? '',
      requiredDocuments: toList(json['requiredDocuments']),
      steps: toList(json['steps']),
      legalBasis: toList(json['legalBasis']),
    );
  }
}
