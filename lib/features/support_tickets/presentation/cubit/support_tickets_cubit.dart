import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/create_ticket_request.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/ticket_status_enum.dart';
import '../../data/repositories/support_tickets_repository.dart';
import 'support_tickets_state.dart';

class SupportTicketsCubit extends BaseCubit<SupportTicketsState> {
  SupportTicketsCubit({required SupportTicketsRepository repository})
      : _repository = repository,
        super(const SupportTicketsState());

  final SupportTicketsRepository _repository;

  Future<void> load({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        emit(
          state.copyWith(
            status: SupportTicketsStatus.loading,
            errorMessage: () => null,
          ),
        );
      }

      final tickets = await _repository.getTickets();

      emit(
        state.copyWith(
          status: SupportTicketsStatus.loaded,
          tickets: tickets,
        ),
      );
    } on ServerException catch (e) {
      logger.error('ServerException loading tickets: ${e.message}');
      emit(
        state.copyWith(
          status: SupportTicketsStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('Failed to load tickets: $e');
      emit(state.copyWith(status: SupportTicketsStatus.error));
    }
  }

  Future<void> loadDetail(String id) async {
    emit(
      state.copyWith(
        detailStatus: TicketDetailStatus.loading,
        detailErrorMessage: () => null,
        selectedTicket: () => state.findById(id) ?? state.selectedTicket,
      ),
    );

    try {
      final ticket = await _repository.getTicketById(id);
      emit(
        state.copyWith(
          detailStatus: TicketDetailStatus.loaded,
          selectedTicket: () => ticket,
          tickets: [
            for (final t in state.tickets)
              if (t.id == id) ticket.copyWith(replies: const []) else t,
          ],
        ),
      );
    } on ServerException catch (e) {
      logger.error('ServerException loading ticket $id: ${e.message}');
      emit(
        state.copyWith(
          detailStatus: TicketDetailStatus.error,
          detailErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('Failed to load ticket $id: $e');
      emit(state.copyWith(detailStatus: TicketDetailStatus.error));
    }
  }

  Future<TicketModel?> create(CreateTicketRequest request) async {
    emit(
      state.copyWith(
        crudStatus: SupportTicketsCrudStatus.loading,
        crudErrorMessage: () => null,
      ),
    );

    try {
      final ticket = await _repository.createTicket(request);
      emit(
        state.copyWith(
          tickets: [ticket, ...state.tickets],
          crudStatus: SupportTicketsCrudStatus.created,
        ),
      );
      return ticket;
    } on ServerException catch (e) {
      logger.error('Failed to create ticket: ${e.message}');
      emit(
        state.copyWith(
          crudStatus: SupportTicketsCrudStatus.error,
          crudErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('Failed to create ticket: $e');
      emit(state.copyWith(crudStatus: SupportTicketsCrudStatus.error));
    }
    return null;
  }

  Future<void> closeTicket(String id) async {
    final previousTickets = List<TicketModel>.from(state.tickets);
    final previousSelected = state.selectedTicket;

    emit(
      state.copyWith(
        tickets: [
          for (final t in previousTickets)
            if (t.id == id) t.copyWith(status: TicketStatusEnum.closed) else t,
        ],
        selectedTicket: previousSelected?.id == id
            ? () =>
                previousSelected!.copyWith(status: TicketStatusEnum.closed)
            : null,
        mutatingIds: {...state.mutatingIds, id},
        crudStatus: SupportTicketsCrudStatus.loading,
        crudErrorMessage: () => null,
      ),
    );

    try {
      final updated = await _repository.closeTicket(id);

      emit(
        state.copyWith(
          tickets: [
            for (final t in state.tickets)
              if (t.id == id) updated.copyWith(replies: const []) else t,
          ],
          selectedTicket: previousSelected?.id == id ? () => updated : null,
          mutatingIds: {...state.mutatingIds}..remove(id),
          crudStatus: SupportTicketsCrudStatus.closed,
        ),
      );
    } on ServerException catch (e) {
      logger.error('Failed to close ticket $id: ${e.message}');
      emit(
        state.copyWith(
          tickets: previousTickets,
          selectedTicket: previousSelected != null
              ? () => previousSelected
              : null,
          mutatingIds: {...state.mutatingIds}..remove(id),
          crudStatus: SupportTicketsCrudStatus.error,
          crudErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('Failed to close ticket $id: $e');
      emit(
        state.copyWith(
          tickets: previousTickets,
          selectedTicket: previousSelected != null
              ? () => previousSelected
              : null,
          mutatingIds: {...state.mutatingIds}..remove(id),
          crudStatus: SupportTicketsCrudStatus.error,
        ),
      );
    }
  }
}
