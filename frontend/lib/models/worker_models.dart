class ExtractedProfile {
  final String? fullName;
  final String? city;
  final int experienceYears;
  final String? skill;
  final String bio;
  final String rawTranscript;

  ExtractedProfile({
    this.fullName,
    this.city,
    required this.experienceYears,
    this.skill,
    required this.bio,
    required this.rawTranscript,
  });

  factory ExtractedProfile.fromJson(Map<String, dynamic> json) {
    return ExtractedProfile(
      fullName: json['full_name'],
      city: json['city'],
      experienceYears: json['experience_years'] ?? 0,
      skill: json['skill'],
      bio: json['bio'] ?? '',
      rawTranscript: json['raw_transcript'] ?? '',
    );
  }
}