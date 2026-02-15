import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/join_request_repository.dart';
import 'join_request_event.dart';
import 'join_request_state.dart';

class JoinRequestBloc extends Bloc<JoinRequestEvent, JoinRequestState> {
  final JoinRequestRepository repository;

  JoinRequestBloc(this.repository) : super(JoinRequestInitial()) {
    on<CreateJoinRequestEvent>(_onCreateJoinRequest);
    on<ApproveJoinRequestEvent>(_onApproveJoinRequest);
    on<RejectJoinRequestEvent>(_onRejectJoinRequest);
    on<CancelJoinRequestEvent>(_onCancelJoinRequest);
    on<LoadGroupJoinRequestsEvent>(_onLoadGroupJoinRequests);
    on<LoadMyJoinRequestsEvent>(_onLoadMyJoinRequests);
    on<LoadPendingCountEvent>(_onLoadPendingCount);
    on<GenerateShareLinkEvent>(_onGenerateShareLink);
  }

  Future<void> _onCreateJoinRequest(
    CreateJoinRequestEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.createJoinRequest(
      groupId: event.groupId,
      message: event.message,
    );

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (joinRequest) => emit(JoinRequestCreated(joinRequest)),
    );
  }

  Future<void> _onApproveJoinRequest(
    ApproveJoinRequestEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.approveJoinRequest(
      requestId: event.requestId,
      note: event.note,
    );

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (joinRequest) => emit(JoinRequestReviewed(joinRequest)),
    );
  }

  Future<void> _onRejectJoinRequest(
    RejectJoinRequestEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.rejectJoinRequest(
      requestId: event.requestId,
      note: event.note,
    );

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (joinRequest) => emit(JoinRequestReviewed(joinRequest)),
    );
  }

  Future<void> _onCancelJoinRequest(
    CancelJoinRequestEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.cancelJoinRequest(event.requestId);

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (_) => emit(JoinRequestCancelled()),
    );
  }

  Future<void> _onLoadGroupJoinRequests(
    LoadGroupJoinRequestsEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.getGroupJoinRequests(event.groupId);

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (joinRequests) => emit(JoinRequestsLoaded(joinRequests)),
    );
  }

  Future<void> _onLoadMyJoinRequests(
    LoadMyJoinRequestsEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.getMyJoinRequests();

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (joinRequests) => emit(JoinRequestsLoaded(joinRequests)),
    );
  }

  Future<void> _onLoadPendingCount(
    LoadPendingCountEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    final result = await repository.getPendingJoinRequestsCount(event.groupId);

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (count) => emit(PendingCountLoaded(count)),
    );
  }

  Future<void> _onGenerateShareLink(
    GenerateShareLinkEvent event,
    Emitter<JoinRequestState> emit,
  ) async {
    emit(JoinRequestLoading());

    final result = await repository.generateShareLink(event.groupId);

    result.fold(
      (failure) => emit(JoinRequestError(failure.message)),
      (shareLink) => emit(ShareLinkGenerated(shareLink)),
    );
  }
}
