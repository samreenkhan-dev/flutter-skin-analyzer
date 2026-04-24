import 'package:equatable/equatable.dart';
import '../../data/models/scan_model.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<ScanModel> scans;
  HistoryLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}

class HistoryEmpty extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}