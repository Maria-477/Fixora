import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/review_service.dart';


class LeaveReviewScreen extends StatefulWidget {
  final int bookingId;

  const LeaveReviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<LeaveReviewScreen> createState() =>
      _LeaveReviewScreenState();
}


class _LeaveReviewScreenState
    extends State<LeaveReviewScreen> {

  final _commentController =
      TextEditingController();

  final _reviewService = ReviewService();

  int _rating = 5;

  bool _isSubmitting = false;

  String? _error;


  Future<void> _submit() async {

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success =
        await _reviewService.submitReview(
      bookingId: widget.bookingId,
      rating: _rating,
      comment:
          _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      context.pop();
    } else {
      setState(() {
        _error =
            'Could not submit review. '
            'It may have already been reviewed.';
      });
    }
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a review'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            const Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children:
                  List.generate(
                5,
                (index) {

                  final starValue =
                      index + 1;

                  return IconButton(
                    iconSize: 40,

                    onPressed: () {
                      setState(() {
                        _rating =
                            starValue;
                      });
                    },

                    icon: Icon(
                      starValue <= _rating
                          ? Icons.star
                          : Icons.star_border,

                      color: Colors.amber,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller:
                  _commentController,

              maxLines: 4,

              decoration:
                  const InputDecoration(
                labelText:
                    'Add a comment (optional)',

                border:
                    OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),

              Text(
                _error!,
                style: TextStyle(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .error,
                ),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : _submit,

              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit review',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}