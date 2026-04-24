import 'dart:convert';

class ScanModel {
  final String id;
  final String conditionName;
  final double confidenceScore;
  final String description;
  final List<String> precautions;
  final String urgencyLevel;
  final String imageUrl;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.conditionName,
    required this.confidenceScore,
    required this.description,
    required this.precautions,
    required this.urgencyLevel,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    // Precautions ko handle karne ka safe tareeqa
    var precautionsData = json['precautions'];
    List<String> precautionsList = [];

    if (precautionsData is List) {
      precautionsList = List<String>.from(precautionsData);
    } else if (precautionsData is String) {
      // Agar Gemini ne comma-separated string bheji hai toh split kar dein
      precautionsList = precautionsData.split(',').map((e) => e.trim()).toList();
    }

    return ScanModel(
      id: json['id']?.toString() ?? '',
      conditionName: json['condition_name'] ?? 'Unknown',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      precautions: precautionsList, // ✅ Use safe list
      urgencyLevel: json['urgency_level'] ?? 'Green',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ID insert karte waqt Supabase khud generate karta hai,
      // isliye save karte waqt ye optional ho sakta hai.
      'condition_name': conditionName,
      'confidence_score': confidenceScore,
      'description': description,
      'precautions': precautions,
      'urgency_level': urgencyLevel,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ✅ Getter add karein taakay HistoryScreen ka code crash na ho
  int get confidence => (confidenceScore * 100).toInt();
}