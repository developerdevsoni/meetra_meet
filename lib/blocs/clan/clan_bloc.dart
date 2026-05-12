import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';

class ClanBloc extends Bloc<ClanEvent, ClanState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _clansSubscription;
  StreamSubscription? _myClansSubscription;
  
  List<ClanModel> _currentClans = [];
  List<ClanModel> _myClans = [];

  ClanBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(ClanInitial()) {
    on<LoadClansByLocation>(_onLoadClansByLocation);
    on<LoadMyClansRequested>(_onLoadMyClansRequested);
    on<JoinClanRequested>(_onJoinClanRequested);
    on<ClansUpdated>(_onClansUpdated);
    on<MyClansUpdated>(_onMyClansUpdated);
    on<CreateClanRequested>(_onCreateClanRequested);
  }

  void _onLoadClansByLocation(LoadClansByLocation event, Emitter<ClanState> emit) {
    emit(ClanLoading());
    _clansSubscription?.cancel();
    _clansSubscription = _firestoreService.getClansByLocation(event.city).listen(
      (clans) => add(ClansUpdated(clans)),
      onError: (e) => add(ClansUpdated([])), // Handle error silently for stream
    );
  }

  void _onLoadMyClansRequested(LoadMyClansRequested event, Emitter<ClanState> emit) {
    _myClansSubscription?.cancel();
    _myClansSubscription = _firestoreService.getMyClans(event.userId).listen(
      (clans) => add(MyClansUpdated(clans)),
      onError: (e) => add(MyClansUpdated([])),
    );
  }

  Future<void> _onJoinClanRequested(JoinClanRequested event, Emitter<ClanState> emit) async {
    try {
      await _firestoreService.joinClan(event.userId, event.clanId);
      // Success will be reflected via subscriptions
    } catch (e) {
      emit(ClanFailure(e.toString()));
    }
  }

  void _onClansUpdated(ClansUpdated event, Emitter<ClanState> emit) {
    _currentClans = event.clans;
    emit(ClanLoaded(clans: _currentClans, myClans: _myClans));
  }

  void _onMyClansUpdated(MyClansUpdated event, Emitter<ClanState> emit) {
    _myClans = event.myClans;
    emit(ClanLoaded(clans: _currentClans, myClans: _myClans));
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
    _myClansSubscription?.cancel();
    return super.close();
  }
}
