import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../categories/data/models/category_model.dart';
import '../../data/repositories/downloads_repository.dart';
import 'downloads_state.dart';

class DownloadsCubit extends BaseCubit<DownloadsState> {
  DownloadsCubit({required DownloadsRepository repository})
    : _repository = repository,
      super(const DownloadsState());

  final DownloadsRepository _repository;

  /// Loads which categories are already downloaded (for badges and the
  /// management screen).
  Future<void> load() async {
    emit(state.copyWith(status: DownloadsStatus.loading));
    try {
      final categories = await _repository.getDownloadedCategories();
      emit(state.copyWith(
        status: DownloadsStatus.loaded,
        downloadedCategories: categories,
        downloadedIds: categories.map((c) => c.id).toSet(),
      ));
    } catch (e) {
      logger.error('DownloadsCubit.load failed: $e');
      emit(state.copyWith(
        status: DownloadsStatus.error,
        errorMessage: () => 'downloads.error',
      ));
    }
  }

  Future<void> download(CategoryModel category) async {
    if (state.isDownloading(category.id)) return;
    emit(state.copyWith(
      downloadingIds: {...state.downloadingIds, category.id},
      progress: {...state.progress, category.id: 0},
      errorMessage: () => null,
    ));
    try {
      await _repository.downloadCategory(
        category,
        onProgress: (fetched, total) {
          final value = total == 0 ? 1.0 : fetched / total;
          emit(state.copyWith(
            progress: {...state.progress, category.id: value},
          ));
        },
      );
      emit(state.copyWith(
        downloadedIds: {...state.downloadedIds, category.id},
        downloadingIds: {...state.downloadingIds}..remove(category.id),
        progress: {...state.progress}..remove(category.id),
        downloadedCategories: _withCategory(category),
      ));
    } on ServerException catch (e) {
      _failDownload(category.id, e.message);
    } catch (e) {
      logger.error('DownloadsCubit.download failed: $e');
      _failDownload(category.id, 'downloads.error');
    }
  }

  Future<void> remove(int categoryId) async {
    try {
      await _repository.removeDownload(categoryId);
      emit(state.copyWith(
        downloadedIds: {...state.downloadedIds}..remove(categoryId),
        downloadedCategories: state.downloadedCategories
            .where((c) => c.id != categoryId)
            .toList(),
      ));
    } catch (e) {
      logger.error('DownloadsCubit.remove failed: $e');
      emit(state.copyWith(errorMessage: () => 'downloads.error'));
    }
  }

  void _failDownload(int categoryId, String message) {
    emit(state.copyWith(
      downloadingIds: {...state.downloadingIds}..remove(categoryId),
      progress: {...state.progress}..remove(categoryId),
      errorMessage: () => message,
    ));
  }

  List<CategoryModel> _withCategory(CategoryModel category) {
    if (state.downloadedCategories.any((c) => c.id == category.id)) {
      return state.downloadedCategories;
    }
    return [...state.downloadedCategories, category];
  }
}
