import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/worker_models.dart';
import '../../services/api_client.dart';
import '../../services/worker_service.dart';

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

  WorkerDetails? _details;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
    final result = await _workerService.getWorkerDetails(
      int.parse(widget.workerId),
    );

    if (!mounted) return;

    setState(() {
      _details = result;
      _isLoading = false;

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