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

class PortfolioImageInfo {
  final String url;
  final String? caption;

  PortfolioImageInfo({
    required this.url,
    this.caption,
  });

  factory PortfolioImageInfo.fromJson(Map<String, dynamic> json) {
    return PortfolioImageInfo(
      url: json['url'],
      caption: json['caption'],
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
  final List<PortfolioImageInfo> portfolioImages;
  final double? averageRating;
  final int reviewCount;

  WorkerDetails({
    required this.workerId,
    required this.fullName,
    required this.city,
    required this.experienceYears,
    this.bio,
    this.profileImageUrl,
    required this.skills,
    required this.portfolioImages,
    this.averageRating,
    this.reviewCount = 0,
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
      portfolioImages: (json['portfolio_images'] as List? ?? [])
          .map((e) => PortfolioImageInfo.fromJson(e))
          .toList(),
      
      averageRating: json['average_rating'] != null
        ? double.tryParse(
            json['average_rating'].toString(),
          )
        : null,
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class ReviewInfo {
  final int id;
  final int rating;
  final String? comment;
  final String? customerName;
  final String createdAt;

  ReviewInfo({
    required this.id,
    required this.rating,
    this.comment,
    this.customerName,
    required this.createdAt,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    return ReviewInfo(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      customerName: json['customer_name'],
      createdAt: json['created_at'],
    );
  }
}