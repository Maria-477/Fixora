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

class WorkerDetails {
  final int workerId;
  final String fullName;
  final String city;
  final int experienceYears;
  final String? bio;
  final String? profileImageUrl;
  final List<String> skills;

  WorkerDetails({
    required this.workerId,
    required this.fullName,
    required this.city,
    required this.experienceYears,
    this.bio,
    this.profileImageUrl,
    required this.skills,
  });

  factory WorkerDetails.fromJson(Map<String, dynamic> json) {
    return WorkerDetails(
      workerId: json['worker_id'],
      fullName: json['full_name'] ?? 'Worker',
      city: json['city'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'],
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}