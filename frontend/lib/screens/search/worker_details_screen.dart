import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/worker_models.dart';
import '../../services/api_client.dart';
import '../../services/worker_service.dart';
import '../../services/review_service.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final String workerId;

  const WorkerDetailsScreen({
    super.key,
    required this.workerId,
  });

  @override
  State<WorkerDetailsScreen> createState() =>
      _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState
    extends State<WorkerDetailsScreen> {
  final _workerService = WorkerService();
  final _reviewService = ReviewService();

  WorkerDetails? _details;
  List<ReviewInfo> _reviews = [];

  bool _isLoading = true;
  bool _reviewsLoading = true;

  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
  final workerId = int.parse(widget.workerId);

  final result = await _workerService.getWorkerDetails(
    workerId,
  );

  final reviews = await _reviewService.getWorkerReviews(
    workerId,
  );

  if (!mounted) return;

  setState(() {
    _details = result;
    _reviews = reviews;

    _isLoading = false;
    _reviewsLoading = false;

    if (result == null) {
      _error = 'Could not load this worker.';
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Details'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text(_error!),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              _details!.profileImageUrl != null
                                  ? NetworkImage(
                                      ApiClient.imageUrl(
                                        _details!.profileImageUrl!,
                                      ),
                                    )
                                  : null,
                          child: _details!.profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 48,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          _details!.fullName,
                          style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (_details!.reviewCount > 0)
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_details!.averageRating} '
                                '(${_details!.reviewCount} reviews)',
                              ),
                            ],
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      if (_details!.skills.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: _details!.skills
                              .map(
                                (skill) => Chip(
                                  label: Text(skill),
                                ),
                              )
                              .toList(),
                        ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_details!.city),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.work_outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_details!.experienceYears} years experience',
                            ),
                          ),
                        ],
                      ),

                      if (_details!.bio != null &&
                          _details!.bio!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_details!.bio!),
                      ],

                      // ==========================
                      // Portfolio Section
                      // ==========================
                      if (_details!.portfolioImages.isNotEmpty) ...[
                        const SizedBox(height: 24),

                        const Text(
                          'Work Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                _details!.portfolioImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final image = _details!
                                  .portfolioImages[index];

                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          insetPadding: const EdgeInsets.all(12),
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              ApiClient.imageUrl(image.url),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        ApiClient.imageUrl(image.url),
                                        width: 140,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 140,
                                          height: 100,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),      
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (image.caption != null &&
                                      image.caption!.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        top: 6,
                                      ),
                                      child: SizedBox(
                                        width: 140,
                                        child: Text(
                                          image.caption!,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),

                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_reviewsLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (_reviews.isEmpty)
                        const Text(
                          'No reviews yet',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      else
                        ..._reviews.map(
                          (review) => Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.customerName ??
                                          'Customer',
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (review.comment != null &&
                                  review.comment!
                                      .trim()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review.comment!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),


                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          context.push(
                            '/booking/create/${_details!.workerId}',
                          );
                        },
                        child: const Text(
                          'Book this worker',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}