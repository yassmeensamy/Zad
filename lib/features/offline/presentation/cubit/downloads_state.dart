import '../../../categories/data/models/category_model.dart';

enum DownloadsStatus { initial, loading, loaded, error }

class DownloadsState {
  const DownloadsState({
    this.status = DownloadsStatus.initial,
    this.downloadedIds = const {},
    this.downloadingIds = const {},
    this.progress = const {},
    this.downloadedCategories = const [],
    this.errorMessage,
  });

  final DownloadsStatus status;

  /// Category ids with a complete local copy.
  final Set<int> downloadedIds;

  /// Category ids whose download is currently in flight.
  final Set<int> downloadingIds;

  /// In-flight download progress per category id, 0..1.
  final Map<int, double> progress;

  /// Downloaded categories, for the management screen.
  final List<CategoryModel> downloadedCategories;

  final String? errorMessage;

  bool isDownloaded(int id) => downloadedIds.contains(id);
  bool isDownloading(int id) => downloadingIds.contains(id);

  DownloadsState copyWith({
    DownloadsStatus? status,
    Set<int>? downloadedIds,
    Set<int>? downloadingIds,
    Map<int, double>? progress,
    List<CategoryModel>? downloadedCategories,
    String? Function()? errorMessage,
  }) => DownloadsState(
    status: status ?? this.status,
    downloadedIds: downloadedIds ?? this.downloadedIds,
    downloadingIds: downloadingIds ?? this.downloadingIds,
    progress: progress ?? this.progress,
    downloadedCategories: downloadedCategories ?? this.downloadedCategories,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );
}
