class Booking {
  final int id;
  final int workerId;
  final int customerId;
  final String status;
  final String? serviceDescription;
  final DateTime scheduledAt;
  final String? workerName;
  final String? customerName;
  final double? suggestedPrice;

  Booking({
    required this.id,
    required this.workerId,
    required this.customerId,
    required this.status,
    this.serviceDescription,
    required this.scheduledAt,
    this.workerName,
    this.customerName,
    this.suggestedPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      workerId: json['worker_id'],
      customerId: json['customer_id'],
      status: json['status'],
      serviceDescription: json['service_description'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      workerName: json['worker_name'],
      customerName: json['customer_name'],
      suggestedPrice: json['suggested_price'] != null
          ? double.tryParse(
              json['suggested_price'].toString(),
            )
          : null,
    );
  }
}