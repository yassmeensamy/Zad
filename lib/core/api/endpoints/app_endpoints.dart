class AppEndpoint {
  final String baseUrl;

  const AppEndpoint({required this.baseUrl});

  // Authentication
  String get signup => '${baseUrl}api/auth/signup';
  String get login => '${baseUrl}api/auth/login';
  String get logout => '${baseUrl}api/auth/logout';
  String get refresh => '${baseUrl}api/auth/refresh';
  String get google => '${baseUrl}api/auth/google';
  String get switchAccount => '${baseUrl}api/auth/switch';
  String get forgotPassword => '${baseUrl}api/auth/forgot-password';
  String get resetPassword => '${baseUrl}api/auth/reset-password';

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

  // Reset progress
  String get resetQuiz => '${baseUrl}api/quiz/reset';
  String resetCategory(int categoryId) =>
      '${baseUrl}api/quiz/categories/$categoryId/reset';
  String resetLevel(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/reset';

  // Draft Questions
  String get drafts => '${baseUrl}api/drafts';
  String get draftsBulk => '${baseUrl}api/drafts/bulk';
  String draftById(int id) => '${baseUrl}api/drafts/$id';

  // Support Tickets
  String get supportTickets => '${baseUrl}api/support/tickets';
  String supportTicketById(String id) => '${baseUrl}api/support/tickets/$id';
  String closeSupportTicket(String id) =>
      '${baseUrl}api/support/tickets/$id/close';

  // Avatars
  String get avatars => '${baseUrl}api/avatars';
  String avatarImage(String id) => '${baseUrl}api/avatars/$id/image';

  // Teams
  String get teams => '${baseUrl}api/teams';
  String get joinTeam => '${baseUrl}api/teams/join';
  String get leaveTeam => '${baseUrl}api/teams/leave';
  String get myTeam => '${baseUrl}api/teams/my-team';
  String get myTeamMembers => '${baseUrl}api/teams/my-team/members';
  String get myTeamProgress => '${baseUrl}api/teams/my-team/progress';
  String get myTeamProgressSummary =>
      '${baseUrl}api/teams/my-team/progress/summary';

  // Rankings (global leaderboards)
  String get rankingTeams => '${baseUrl}api/rankings/teams';
  String get rankingIndividuals => '${baseUrl}api/rankings/individuals';
}
