class AppEndpoint {
  final String baseUrl;

  const AppEndpoint({required this.baseUrl});

  String get signup => '${baseUrl}api/auth/signup';
  String get login => '${baseUrl}api/auth/login';
  String get guestLogin => '${baseUrl}api/auth/guest';
  String get upgradeGuest => '${baseUrl}api/auth/upgrade-guest';
  String get logout => '${baseUrl}api/auth/logout';
  String get refresh => '${baseUrl}api/auth/refresh';
  String get google => '${baseUrl}api/auth/google';
  String get switchAccount => '${baseUrl}api/auth/switch';
  String get forgotPassword => '${baseUrl}api/auth/forgot-password';
  String get resetPassword => '${baseUrl}api/auth/reset-password';
  String get verifyEmail => '${baseUrl}api/auth/verify-email';
  String get resendVerification => '${baseUrl}api/auth/resend-verification';

  String get children => '${baseUrl}api/children';
  String get createChild => '${baseUrl}api/children';
  String childById(String childId) => '${baseUrl}api/children/$childId';

  String get me => '${baseUrl}api/users/me';
  String get changePassword => '${baseUrl}api/users/me/password';
  String get userLanguage => '${baseUrl}api/users/me/language';

  String get streak => '${baseUrl}api/users/me/streak';
  String get weeklyStreak => '${baseUrl}api/users/me/streak/weekly';

  String get randomQuranSign => '${baseUrl}api/quran-signs/random';

  String get quizCategories => '${baseUrl}api/quiz/categories';

  String levelsByCategoryId(int categoryId) =>
      '${baseUrl}api/quiz/categories/$categoryId/levels';

  String categoryDownload(int categoryId) =>
      '${baseUrl}api/quiz/categories/$categoryId/download';

  String questionsByLevelId(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/questions';
  String submitQuiz(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/submit';
  String get syncQuiz => '${baseUrl}api/quiz/sync';

  String get resetQuiz => '${baseUrl}api/quiz/reset';
  String resetCategory(int categoryId) =>
      '${baseUrl}api/quiz/categories/$categoryId/reset';
  String resetLevel(int levelId) =>
      '${baseUrl}api/quiz/levels/$levelId/reset';

  String get drafts => '${baseUrl}api/drafts';
  String get draftsBulk => '${baseUrl}api/drafts/bulk';
  String draftById(int id) => '${baseUrl}api/drafts/$id';

  String get supportTickets => '${baseUrl}api/support/tickets';
  String supportTicketById(String id) => '${baseUrl}api/support/tickets/$id';
  String closeSupportTicket(String id) =>
      '${baseUrl}api/support/tickets/$id/close';

  String get avatars => '${baseUrl}api/avatars';
  String avatarImage(String id) => '${baseUrl}api/avatars/$id/image';

  String get teams => '${baseUrl}api/teams';
  String get joinTeam => '${baseUrl}api/teams/join';
  String get leaveTeam => '${baseUrl}api/teams/leave';
  String get myTeam => '${baseUrl}api/teams/my-team';
  String get myTeamMembers => '${baseUrl}api/teams/my-team/members';
  String get myTeamProgress => '${baseUrl}api/teams/my-team/progress';
  String get myTeamProgressSummary =>
      '${baseUrl}api/teams/my-team/progress/summary';

  String get rankingTeams => '${baseUrl}api/rankings/teams';
  String get rankingIndividuals => '${baseUrl}api/rankings/individuals';

  String get notifications => '${baseUrl}api/notifications';
  String get notificationsUnreadCount =>
      '${baseUrl}api/notifications/unread-count';
  String get notificationsReadAll => '${baseUrl}api/notifications/read-all';
  String notificationById(int id) => '${baseUrl}api/notifications/$id';
}
