import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';
import '../remote/support_tickets_remote_data_source.dart';

abstract class SupportTicketsRepository {
  Future<List<TicketModel>> getTickets();
  Future<TicketModel> getTicketById(String id);
  Future<TicketModel> closeTicket(String id);
  Future<TicketModel> createTicket(CreateTicketRequest request);
}

class SupportTicketsRepositoryImpl implements SupportTicketsRepository {
  SupportTicketsRepositoryImpl({
    required SupportTicketsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SupportTicketsRemoteDataSource _remoteDataSource;

  @override
  Future<List<TicketModel>> getTickets() => _remoteDataSource.getTickets();

  @override
  Future<TicketModel> getTicketById(String id) =>
      _remoteDataSource.getTicketById(id);

  @override
  Future<TicketModel> closeTicket(String id) =>
      _remoteDataSource.closeTicket(id);

  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) =>
      _remoteDataSource.createTicket(request);
}
