import 'package:equatable/equatable.dart';
import 'package:meetra_meet/models/clan_model.dart';

abstract class ClanEvent extends Equatable {
  const ClanEvent();
  @override
  List<Object?> get props => [];
}

class LoadClansByLocation extends ClanEvent {
  final String city;
  const LoadClansByLocation(this.city);
  @override
  List<Object?> get props => [city];
}

class CreateClanRequested extends ClanEvent {
  final ClanModel clan;
  const CreateClanRequested(this.clan);
  @override
  List<Object?> get props => [clan];
}

class ClansUpdated extends ClanEvent {
  final List<ClanModel> clans;
  const ClansUpdated(this.clans);
  @override
  List<Object?> get props => [clans];
}

abstract class ClanState extends Equatable {
  const ClanState();
  @override
  List<Object?> get props => [];
}

class ClanInitial extends ClanState {}

class ClanLoading extends ClanState {}

class ClanLoaded extends ClanState {
  final List<ClanModel> clans;
  const ClanLoaded(this.clans);
  @override
  List<Object?> get props => [clans];
}

class ClanOperationSuccess extends ClanState {}

class ClanFailure extends ClanState {
  final String message;
  const ClanFailure(this.message);
  @override
  List<Object?> get props => [message];
}
