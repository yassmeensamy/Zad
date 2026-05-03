class AppEndpoint {
  final String baseUrl;

  const AppEndpoint({required this.baseUrl});

  // Authentication
  String get signup => '${baseUrl}api/auth/signup';
  String get login => '${baseUrl}api/auth/login';
  String get logout => '${baseUrl}api/auth/logout';
  String get refresh => '${baseUrl}api/auth/refresh';
  String get google => '${baseUrl}api/auth/google';

  // Child Management
  String get children => '${baseUrl}api/children';
  String get createChild => '${baseUrl}api/children';
  String childById(String childId) => '${baseUrl}api/children/$childId';

  // User Profile
  String get me => '${baseUrl}api/users/me';
  String get changePassword => '${baseUrl}api/users/me/password';

  // Categories
  String get quizCategories => '${baseUrl}api/quiz/categories';
}
