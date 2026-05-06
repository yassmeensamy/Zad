import 'package:flutter/foundation.dart';

import '../../data/models/ticket_model.dart';

enum SupportTicketsStatus { initial, loading, loaded, error }

enum TicketDetailStatus { initial, loading, loaded, error }

enum SupportTicketsCrudStatus { idle, loading, created, closed, error }

class SupportTicketsState {
  const SupportTicketsState({
    this.status = SupportTicketsStatus.initial,
    this.tickets = const [],
    this.selectedTicket,
    this.detailStatus = TicketDetailStatus.initial,
    this.detailErrorMessage,
    this.mutatingIds = const {},
    this.errorMessage,
    this.crudStatus = SupportTicketsCrudStatus.idle,
    this.crudErrorMessage,
  });

  final SupportTicketsStatus status;
  final List<TicketModel> tickets;

  final TicketModel? selectedTicket;
  final TicketDetailStatus detailStatus;
  final String? detailErrorMessage;

  final Set<String> mutatingIds;
  final String? errorMessage;

  final SupportTicketsCrudStatus crudStatus;
  final String? crudErrorMessage;

  SupportTicketsState copyWith({
    SupportTicketsStatus? status,
    List<TicketModel>? tickets,
    TicketModel? Function()? selectedTicket,
    TicketDetailStatus? detailStatus,
    String? Function()? detailErrorMessage,
    Set<String>? mutatingIds,
    String? Function()? errorMessage,
    SupportTicketsCrudStatus? crudStatus,
    String? Function()? crudErrorMessage,
  }) =>
      SupportTicketsState(
        status: status ?? this.status,
        tickets: tickets ?? this.tickets,
        selectedTicket:
            selectedTicket != null ? selectedTicket() : this.selectedTicket,
        detailStatus: detailStatus ?? this.detailStatus,
        detailErrorMessage: detailErrorMessage != null
            ? detailErrorMessage()
            : this.detailErrorMessage,
        mutatingIds: mutatingIds ?? this.mutatingIds,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
        crudStatus: crudStatus ?? this.crudStatus,
        crudErrorMessage: crudErrorMessage != null
            ? crudErrorMessage()
            : this.crudErrorMessage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupportTicketsState &&
        other.status == status &&
        listEquals(other.tickets, tickets) &&
        other.selectedTicket == selectedTicket &&
        other.detailStatus == detailStatus &&
        other.detailErrorMessage == detailErrorMessage &&
        setEquals(other.mutatingIds, mutatingIds) &&
        other.errorMessage == errorMessage &&
        other.crudStatus == crudStatus &&
        other.crudErrorMessage == crudErrorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(tickets),
        selectedTicket,
        detailStatus,
        detailErrorMessage,
        Object.hashAllUnordered(mutatingIds),
        errorMessage,
        crudStatus,
        crudErrorMessage,
      );
}

extension SupportTicketsStateX on SupportTicketsState {
  bool get isInitial => status == SupportTicketsStatus.initial;
  bool get isLoading => status == SupportTicketsStatus.loading;
  bool get isLoaded => status == SupportTicketsStatus.loaded;
  bool get isError => status == SupportTicketsStatus.error;

  bool get hasTickets => tickets.isNotEmpty;
  bool isMutating(String id) => mutatingIds.contains(id);

  bool get isDetailInitial => detailStatus == TicketDetailStatus.initial;
  bool get isDetailLoading => detailStatus == TicketDetailStatus.loading;
  bool get isDetailLoaded => detailStatus == TicketDetailStatus.loaded;
  bool get isDetailError => detailStatus == TicketDetailStatus.error;

  bool get isCrudIdle => crudStatus == SupportTicketsCrudStatus.idle;
  bool get isCrudLoading => crudStatus == SupportTicketsCrudStatus.loading;
  bool get isCrudCreated => crudStatus == SupportTicketsCrudStatus.created;
  bool get isCrudClosed => crudStatus == SupportTicketsCrudStatus.closed;
  bool get isCrudError => crudStatus == SupportTicketsCrudStatus.error;

  TicketModel? findById(String id) {
    for (final t in tickets) {
      if (t.id == id) return t;
    }
    return null;
  }
}
