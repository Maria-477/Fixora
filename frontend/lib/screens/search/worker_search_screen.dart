import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';

class WorkerSearchScreen extends StatefulWidget {
  const WorkerSearchScreen({super.key});

  @override
  State<WorkerSearchScreen> createState() => _WorkerSearchScreenState();
}

class _WorkerSearchScreenState extends State<WorkerSearchScreen> {
  final Dio _dio = ApiClient().dio;
  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedSkill;

  final _skills = ['Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Mechanic', 'AC Technician', 'Cleaning'];

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _error = 'Location permission is needed to find nearby workers';
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();

      final response = await _dio.get('/search/workers', queryParameters: {
        'lat': position.latitude,
        'lng': position.longitude,
        if (_selectedSkill != null) 'skill': _selectedSkill,
      });

      setState(() {
        _results = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not find workers right now';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a worker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedSkill == null,
                    onSelected: (_) {
                      setState(() => _selectedSkill = null);
                      _search();
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._skills.map((skill) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(skill),
                          selected: _selectedSkill == skill,
                          onSelected: (_) {
                            setState(() => _selectedSkill = skill);
                            _search();
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _results.isEmpty && !_isLoading
                ? const Center(child: Text('No workers found nearby'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final worker = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: worker['profile_image_url'] != null
                              ? NetworkImage(ApiClient.imageUrl(worker['profile_image_url']))
                              : null,
                          child: worker['profile_image_url'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(worker['full_name'] ?? 'Worker'),
                        subtitle: Text('${worker['city']} • ${worker['experience_years']} yrs • ${worker['distance_km']} km away'),
                        onTap: () => context.push('/worker/${worker['worker_id']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}