# Flutter Best Practices — Detailed Reference

## Dart Patterns with Examples

### Null Safety
```dart
// ❌ Avoid force-unwrap unless guaranteed
final name = user.name!;

// ✅ Use null-aware operators
final name = user.name ?? 'Unknown';
final length = user.name?.length ?? 0;
```

### Pattern Matching & Records
```dart
// ✅ Pattern matching with switch expression
String describe(Shape shape) => switch (shape) {
  Circle(radius: var r) => 'Circle with radius $r',
  Square(side: var s) => 'Square with side $s',
};

// ✅ Records for multiple return values
(String, int) getUserInfo() => ('Alice', 30);
final (name, age) = getUserInfo();
```

### Exhaustive Switch
```dart
// ✅ Exhaustive — compiler checks all cases
enum Status { loading, loaded, error }

String label(Status s) => switch (s) {
  Status.loading => 'Loading...',
  Status.loaded => 'Done',
  Status.error => 'Failed',
};
```

### Arrow Functions
```dart
// ✅ Arrow for simple one-liners
bool isEven(int n) => n % 2 == 0;
List<int> doubled(List<int> items) => items.map((e) => e * 2).toList();
```

### Async/Await with Error Handling
```dart
// ✅ Typed exception handling
Future<User> fetchUser(String id) async {
  try {
    final response = await api.get('/users/$id');
    return User.fromMap(response.data);
  } on NotFoundException {
    throw UserNotFoundException(id);
  } on NetworkException catch (e) {
    throw ServiceUnavailableException(e.message);
  }
}

// ✅ Stream usage
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    yield i;
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

---

## Documentation Style

```dart
/// Fetches the user's upcoming appointments from the API.
///
/// Returns an empty list if the user has no appointments scheduled.
/// Throws [ServerException] if the API request fails.
Future<List<AppointmentModel>> fetchUpcoming() async { ... }

/// A card displaying a single appointment summary.
///
/// Tapping the card navigates to the appointment detail screen.
class AppointmentCard extends StatelessWidget { ... }
```

---

## Visual Design Checklist

- [ ] Text contrast ratio >= 4.5:1 (normal) or 3:1 (large text 18pt+)
- [ ] Typography hierarchy: distinct sizes for hero → headline → body → caption
- [ ] Multi-layered shadows on cards for depth
- [ ] Icons accompany key navigation elements
- [ ] 60-30-10 color distribution (primary/secondary/accent)
- [ ] Interactive elements have visible focus/press states
- [ ] UI tested at 1.0x, 1.5x, 2.0x text scale
