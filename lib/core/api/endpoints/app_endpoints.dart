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
  String get userLanguage => '${baseUrl}api/users/me/language';

  // Categories
  String get quizCategories => '${baseUrl}api/quiz/categories';

  // Levels
  String levelsByCategoryId(int categoryId) =>
      '${baseUrl}api/quiz/categories/$categoryId/levels';

  // Quiz
  String questionsByLevelId(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/questions';
  String submitQuiz(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/submit';

  // Draft Questions
  String get drafts => '${baseUrl}api/drafts';
  String get draftsBulk => '${baseUrl}api/drafts/bulk';
  String draftById(int id) => '${baseUrl}api/drafts/$id';

  // Support Tickets
  String get supportTickets => '${baseUrl}api/support/tickets';
  String supportTicketById(String id) => '${baseUrl}api/support/tickets/$id';
  String closeSupportTicket(String id) =>
      '${baseUrl}api/support/tickets/$id/close';
}
