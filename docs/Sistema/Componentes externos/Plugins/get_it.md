### get_it

> [!info] Informações gerais
> A blazing-fast service locator for Dart and Flutter that makes dependency management simple.
> - [pub.dev](https://pub.dev/packages/get_it)
> - [repositório](https://github.com/flutter-it/get_it)

Uso básico

```dart
import 'package:get_it/get_it.dart';

// Create a global instance (or use GetIt.instance)
final getIt = GetIt.instance;

// 1. Define your services
class ApiClient {
  Future<void> fetchData() async { /* ... */ }
}

class UserRepository {
  final ApiClient apiClient;
  UserRepository(this.apiClient);
}

// 2. Register them at app startup
void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiClient>())
  );
}

// 3. Access from anywhere in your app
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // No BuildContext passing needed!
        getIt<UserRepository>().apiClient.fetchData();
      },
      child: Text('Fetch Data'),
    );
  }
}
```