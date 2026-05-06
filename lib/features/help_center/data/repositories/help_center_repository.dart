import '../../../support_tickets/data/models/create_ticket_request.dart';
import '../../../support_tickets/data/repositories/support_tickets_repository.dart';
import '../models/support_request_model.dart';

abstract class HelpCenterRepository {
  Future<SupportRequestModel> sendSupportRequest(SupportRequestModel request);
}

class HelpCenterRepositoryImpl implements HelpCenterRepository {
  HelpCenterRepositoryImpl({
    required SupportTicketsRepository ticketsRepository,
  }) : _ticketsRepository = ticketsRepository;

  final SupportTicketsRepository _ticketsRepository;

  @override
  Future<SupportRequestModel> sendSupportRequest(
    SupportRequestModel request,
  ) async {
    final ticket = await _ticketsRepository.createTicket(
      CreateTicketRequest(
        topic: request.topic,
        title: request.subject,
        body: request.message,
      ),
    );
    return SupportRequestModel(
      id: ticket.id.hashCode,
      topic: ticket.topic,
      subject: ticket.title,
      message: ticket.body,
      createdAt: ticket.createdAt,
    );
  }
}
