import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'clan_state.dart';

class ClanBloc extends Bloc<ClanEvent, ClanState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _clansSubscription;

  ClanBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(ClanInitial()) {
    on<LoadClansByLocation>(_onLoadClansByLocation);
    on<ClansUpdated>(_onClansUpdated);
    on<CreateClanRequested>(_onCreateClanRequested);
  }

  void _onLoadClansByLocation(LoadClansByLocation event, Emitter<ClanState> emit) {
    emit(ClanLoading());
    _clansSubscription?.cancel();
    _clansSubscription = _firestoreService.getClansByLocation(event.city).listen(
      (clans) => add(ClansUpdated(clans)),
      onError: (e) => emit(ClanFailure(e.toString())),
    );
  }

  void _onClansUpdated(ClansUpdated event, Emitter<ClanState> emit) {
    emit(ClanLoaded(event.clans));
  }

  Future<void> _onCreateClanRequested(CreateClanRequested event, Emitter<ClanState> emit) async {
    try {
      await _firestoreService.createClan(event.clan);
      emit(ClanOperationSuccess());
    } catch (e) {
      emit(ClanFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _clansSubscription?.cancel();
    return super.close();
  }
}
