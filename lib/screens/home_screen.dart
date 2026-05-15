import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/trip_model.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import '../screens/user_management_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeTrips = ref.watch(activeTripsProvider);
    final closedTrips = ref.watch(closedTripsProvider);
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KafadanKasa'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedTabIndex == 0
          ? _buildActiveTripsTab(activeTrips, users)
          : _buildClosedTripsTab(closedTrips),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Kapanmış',
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateTripDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildActiveTripsTab(List<Trip> trips, List<User> users) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_travel, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Aktif seyahat yok'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showCreateTripDialog(),
              child: const Text('Yeni Seyahat'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(trip: trip, users: users);
      },
    );
  }

  Widget _buildClosedTripsTab(List<Trip> trips) {
    if (trips.isEmpty) {
      return const Center(
        child: Text('Kapanmış seyahat yok'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(trip.name),
            subtitle: Text('${trip.startLocation.fullLocation} → ${trip.endLocation.fullLocation}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  void _showCreateTripDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Seyahat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Seyahat Adı',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.border),
                    child: const Text('İptal', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final newTrip = Trip(
                          id: const Uuid().v4(),
                          name: nameController.text,
                          description: descriptionController.text,
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          startLocation: const Location(province: 'İstanbul', district: 'Beşiktaş'),
                          endLocation: const Location(province: 'Ankara', district: 'Keçiören'),
                          participantIds: [],
                          status: 'active',
                          createdAt: DateTime.now(),
                        );

                        ref.read(tripsProvider.notifier).addTrip(newTrip);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Seyahat oluşturuldu')),
                        );
                      }
                    },
                    child: const Text('Oluştur'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final List<User> users;

  const TripCard({
    Key? key,
    required this.trip,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trip.coverImagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(trip.coverImagePath!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  trip.description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.startLocation.fullLocation} → ${trip.endLocation.fullLocation}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Seyahat detay ekranına git
                    },
                    child: const Text('Detaylar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
