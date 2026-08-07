class AdminSummary {
  final int totalWorkers;
  final int verifiedWorkers;
  final int totalCustomers;
  final int totalBookings;
  final int pendingVerifications;

  AdminSummary({
    required this.totalWorkers,
    required this.verifiedWorkers,
    required this.totalCustomers,
    required this.totalBookings,
    required this.pendingVerifications,
  });

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      totalWorkers: json['total_workers'],
      verifiedWorkers: json['verified_workers'],
      totalCustomers: json['total_customers'],
      totalBookings: json['total_bookings'],
      pendingVerifications: json['pending_verifications'],
    );
  }
}

class PendingVerification {
  final int verificationId;
  final int workerId;
  final String workerName;
  final String? workerPhone;
  final String? city;
  final int? experienceYears;
  final String? bio;
  final List<String> skills;
  final String documentType;
  final String documentUrl;
  final String submittedAt;

  PendingVerification({
    required this.verificationId,
    required this.workerId,
    required this.workerName,
    this.workerPhone,
    this.city,
    this.experienceYears,
    this.bio,
    required this.skills,
    required this.documentType,
    required this.documentUrl,
    required this.submittedAt,
  });

  factory PendingVerification.fromJson(Map<String, dynamic> json) {
    return PendingVerification(
      verificationId: json['verification_id'],
      workerId: json['worker_id'],
      workerName: json['worker_name'] ?? 'Worker',
      workerPhone: json['worker_phone'],
      city: json['city'],
      experienceYears: json['experience_years'],
      bio: json['bio'],
      skills: List<String>.from(json['skills'] ?? []),
      documentType: json['document_type'],
      documentUrl: json['document_url'],
      submittedAt: json['submitted_at'],
    );
  }
}