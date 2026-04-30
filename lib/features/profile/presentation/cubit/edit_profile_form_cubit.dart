import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/models/user_model.dart';
import 'edit_profile_form_state.dart';

class EditProfileFormCubit extends BaseCubit<EditProfileFormState> {
  EditProfileFormCubit() : super(const EditProfileFormState());

  void init(UserModel user) {
    emit(EditProfileFormState(updatedUser: user));
  }

  void setName(String value) {
    final updated = state.updatedUser?.copyWith(fullName: value);
    if (updated == null || updated == state.updatedUser) return;
    emit(state.copyWith(updatedUser: updated));
  }

  void setBirthDate(DateTime date) {
    final updated = state.updatedUser?.copyWith(birthDate: date);
    if (updated == null || updated == state.updatedUser) return;
    emit(state.copyWith(updatedUser: updated));
  }
}
