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

class LoadMyClansRequested extends ClanEvent {
  final String userId;
  const LoadMyClansRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class JoinClanRequested extends ClanEvent {
  final String clanId;
  final String userId;
  const JoinClanRequested(this.clanId, this.userId);
  @override
  List<Object?> get props => [clanId, userId];
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

class MyClansUpdated extends ClanEvent {
  final List<ClanModel> myClans;
  const MyClansUpdated(this.myClans);
  @override
  List<Object?> get props => [myClans];
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
  final List<ClanModel> myClans;
  const ClanLoaded({this.clans = const [], this.myClans = const []});
  @override
  List<Object?> get props => [clans, myClans];
}

class ClanOperationSuccess extends ClanState {}

class ClanFailure extends ClanState {
  final String message;
  const ClanFailure(this.message);
  @override
  List<Object?> get props => [message];
}
