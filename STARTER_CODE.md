# KafadanKasa - Başlangıç Kod Yapısı

## 📂 Klasör Yapısı Oluşturma

```bash
lib/
├── main.dart
├── config/
│   ├── theme.dart
│   ├── routes.dart
│   └── constants.dart
├── models/
│   ├── user_model.dart
│   ├── trip_model.dart
│   ├── expense_model.dart
│   ├── gps_log_model.dart
│   └── memory_model.dart
├── services/
│   ├── database_service.dart
│   ├── gps_service.dart
│   ├── camera_service.dart
│   ├── ocr_service.dart
│   ├── balance_service.dart
│   └── export_service.dart
├── providers/
│   ├── user_provider.dart
│   ├── trip_provider.dart
│   └── expense_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   └── ...
├── widgets/
│   ├── common/
│   ├── animations/
│   └── category/
└── utils/
    ├── extensions.dart
    ├── validators.dart
    └── format_utils.dart
```

---

## 📝 Model Tanımlamaları

### user_model.dart

```dart
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String firstName;
  
  @HiveField(2)
  final String lastName;
  
  @HiveField(3)
  final int age;
  
  @HiveField(4)
  final String profession;
  
  @HiveField(5)
  final String nickname;
  
  @HiveField(6)
  final String bankName;
  
  @HiveField(7)
  final String iban;
  
  @HiveField(8)
  final String? profileImagePath;
  
  @HiveField(9)
  final bool isAdmin;
  
  @HiveField(10)
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.profession,
    required this.nickname,
    required this.bankName,
    required this.iban,
    this.profileImagePath,
    required this.isAdmin,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? age,
    String? profession,
    String? nickname,
    String? bankName,
    String? iban,
    String? profileImagePath,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      profession: profession ?? this.profession,
      nickname: nickname ?? this.nickname,
      bankName: bankName ?? this.bankName,
      iban: iban ?? this.iban,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### trip_model.dart

```dart
import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 1)
class Location {
  @HiveField(0)
  final String province;
  
  @HiveField(1)
  final String district;

  Location({required this.province, required this.district});

  String get fullLocation => '$district, $province';
}

@HiveType(typeId: 2)
class Trip {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime startDate;
  
  @HiveField(4)
  final DateTime endDate;
  
  @HiveField(5)
  final Location startLocation;
  
  @HiveField(6)
  final Location endLocation;
  
  @HiveField(7)
  final List<String> participantIds; // User IDs
  
  @HiveField(8)
  final String? coverImagePath;
  
  @HiveField(9)
  final String status; // 'active' or 'closed'
  
  @HiveField(10)
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.endLocation,
    required this.participantIds,
    this.coverImagePath,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';

  Trip copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    Location? startLocation,
    Location? endLocation,
    List<String>? participantIds,
    String? coverImagePath,
    String? status,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      participantIds: participantIds ?? this.participantIds,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### expense_model.dart

```dart
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 3)
class ExpenseLocation {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final String address;

  ExpenseLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

@HiveType(typeId: 4)
class Expense {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String tripId;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final double amount;
  
  @HiveField(5)
  final String currency; // 'TRY'
  
  @HiveField(6)
  final String paidBy; // User ID
  
  @HiveField(7)
  final List<String> splitBetween; // User IDs
  
  @HiveField(8)
  final String? receiptImagePath;
  
  @HiveField(9)
  final ExpenseLocation? location;
  
  @HiveField(10)
  final DateTime date;
  
  @HiveField(11)
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.category,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.splitBetween,
    this.receiptImagePath,
    this.location,
    required this.date,
    required this.createdAt,
  });

  double get perPersonAmount => amount / splitBetween.length;

  Expense copyWith({
    String? id,
    String? tripId,
    String? category,
    String? description,
    double? amount,
    String? currency,
    String? paidBy,
    List<String>? splitBetween,
    String? receiptImagePath,
    ExpenseLocation? location,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidBy: paidBy ?? this.paidBy,
      splitBetween: splitBetween ?? this.splitBetween,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### gps_log_model.dart

```dart
import 'package:hive/hive.dart';

part 'gps_log_model.g.dart';

@HiveType(typeId: 5)
class GPSLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String tripId;
  
  @HiveField(2)
  final double latitude;
  
  @HiveField(3)
  final double longitude;
  
  @HiveField(4)
  final double altitude;
  
  @HiveField(5)
  final double speed; // km/h
  
  @HiveField(6)
  final double accuracy; // meter
  
  @HiveField(7)
  final DateTime timestamp;
  
  @HiveField(8)
  final String type; // 'vehicle' or 'walking'

  GPSLog({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
    required this.type,
  });

  GPSLog copyWith({
    String? id,
    String? tripId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? accuracy,
    DateTime? timestamp,
    String? type,
  }) {
    return GPSLog(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
```

### memory_model.dart

```dart
import 'package:hive/hive.dart';

part 'memory_model.g.dart';

@HiveType(typeId: 6)
class Memory {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String tripId;
  
  @HiveField(2)
  final String mediaType; // 'photo' or 'video'
  
  @HiveField(3)
  final String mediaPath;
  
  @HiveField(4)
  final String? thumbnailPath;
  
  @HiveField(5)
  final DateTime uploadedAt;

  Memory({
    required this.id,
    required this.tripId,
    required this.mediaType,
    required this.mediaPath,
    this.thumbnailPath,
    required this.uploadedAt,
  });

  bool get isPhoto => mediaType == 'photo';
  bool get isVideo => mediaType == 'video';

  Memory copyWith({
    String? id,
    String? tripId,
    String? mediaType,
    String? mediaPath,
    String? thumbnailPath,
    DateTime? uploadedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      mediaType: mediaType ?? this.mediaType,
      mediaPath: mediaPath ?? this.mediaPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
```

---

## 🔧 Hive Setup (database_service.dart)

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../models/gps_log_model.dart';
import '../models/memory_model.dart';

class DatabaseService {
  static const String usersBox = 'users';
  static const String tripsBox = 'trips';
  static const String expensesBox = 'expenses';
  static const String gpsLogsBox = 'gps_logs';
  static const String memoriesBox = 'memories';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Adapters kaydet
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(LocationAdapter());
    Hive.registerAdapter(TripAdapter());
    Hive.registerAdapter(ExpenseLocationAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(GPSLogAdapter());
    Hive.registerAdapter(MemoryAdapter());
    
    // Boxları aç
    await Hive.openBox<User>(usersBox);
    await Hive.openBox<Trip>(tripsBox);
    await Hive.openBox<Expense>(expensesBox);
    await Hive.openBox<GPSLog>(gpsLogsBox);
    await Hive.openBox<Memory>(memoriesBox);
  }

  // User işlemleri
  static Future<void> addUser(User user) async {
    final box = Hive.box<User>(usersBox);
    await box.put(user.id, user);
  }

  static Future<void> updateUser(User user) async {
    final box = Hive.box<User>(usersBox);
    await box.put(user.id, user);
  }

  static Future<void> deleteUser(String userId) async {
    final box = Hive.box<User>(usersBox);
    await box.delete(userId);
  }

  static List<User> getAllUsers() {
    final box = Hive.box<User>(usersBox);
    return box.values.toList();
  }

  static User? getUser(String userId) {
    final box = Hive.box<User>(usersBox);
    return box.get(userId);
  }

  // Trip işlemleri
  static Future<void> addTrip(Trip trip) async {
    final box = Hive.box<Trip>(tripsBox);
    await box.put(trip.id, trip);
  }

  static List<Trip> getAllTrips() {
    final box = Hive.box<Trip>(tripsBox);
    return box.values.toList();
  }

  static List<Trip> getActiveTrips() {
    final box = Hive.box<Trip>(tripsBox);
    return box.values.where((t) => t.isActive).toList();
  }

  // Expense işlemleri
  static Future<void> addExpense(Expense expense) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.put(expense.id, expense);
  }

  static List<Expense> getTripExpenses(String tripId) {
    final box = Hive.box<Expense>(expensesBox);
    return box.values.where((e) => e.tripId == tripId).toList();
  }

  // GPS işlemleri
  static Future<void> addGPSLog(GPSLog log) async {
    final box = Hive.box<GPSLog>(gpsLogsBox);
    await box.put(log.id, log);
  }

  static List<GPSLog> getTripGPSLogs(String tripId) {
    final box = Hive.box<GPSLog>(gpsLogsBox);
    return box.values.where((g) => g.tripId == tripId).toList();
  }

  // Memory işlemleri
  static Future<void> addMemory(Memory memory) async {
    final box = Hive.box<Memory>(memoriesBox);
    await box.put(memory.id, memory);
  }

  static List<Memory> getTripMemories(String tripId) {
    final box = Hive.box<Memory>(memoriesBox);
    return box.values.where((m) => m.tripId == tripId).toList();
  }

  // Temizlik
  static Future<void> deleteAllData() async {
    await Hive.deleteBoxFromDisk(usersBox);
    await Hive.deleteBoxFromDisk(tripsBox);
    await Hive.deleteBoxFromDisk(expensesBox);
    await Hive.deleteBoxFromDisk(gpsLogsBox);
    await Hive.deleteBoxFromDisk(memoriesBox);
  }
}
```

---

## 🎨 Theme Konfigürasyonu (config/theme.dart)

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E88E5);
  static const secondary = Color(0xFFFF6F00);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFDD835);
  static const error = Color(0xFFE53935);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const border = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
```

---

## 📱 Main Entry Point (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'KafadanKasa',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wallet_travel, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'KafadanKasa',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}
```

---

## 📋 Sonraki Adımlar

1. **Models oluştur**: `user_model.dart`, `trip_model.dart`, vb.
2. **Database bağlantısı kur**: `database_service.dart`
3. **Riverpod providers** yaz
4. **Servisler** geliştir (GPS, Kamera, OCR)
5. **Screens** başla
6. **Widgets** bileşenleri ekle
7. **Testing** yap

---

**Versiyon**: 1.0  
**Son Güncelleme**: 15.05.2026
