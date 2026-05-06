import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';

abstract class SupportTicketsRemoteDataSource {
  Future<List<TicketModel>> getTickets();
  Future<TicketModel> getTicketById(String id);
  Future<TicketModel> closeTicket(String id);
  Future<TicketModel> createTicket(CreateTicketRequest request);
}

class SupportTicketsRemoteDataSourceImpl
    implements SupportTicketsRemoteDataSource {
  SupportTicketsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  })  : _networkService = networkService,
        _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201, 204],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<List<TicketModel>> getTickets() async {
    final response = await _networkService.get(_endpoints.supportTickets);
    _validateResponse(response);
    return (response.data as List<dynamic>)
        .map((e) => TicketModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TicketModel> getTicketById(String id) async {
    final response =
        await _networkService.get(_endpoints.supportTicketById(id));
    _validateResponse(response);
    return TicketModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TicketModel> closeTicket(String id) async {
    final response =
        await _networkService.patch(_endpoints.closeSupportTicket(id));
    _validateResponse(response);
    return TicketModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) async {
    final response = await _networkService.post(
      _endpoints.supportTickets,
      data: request.toMap(),
    );
    _validateResponse(response);
    return TicketModel.fromMap(response.data as Map<String, dynamic>);
  }
}
