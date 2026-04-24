import 'package:equatable/equatable.dart';
import '../../data/models/scan_model.dart';

abstract class ScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {} // Is state par "Laser" chalegi

class ScannerSuccess extends ScannerState {
  final ScanModel result;
  ScannerSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class ScannerError extends ScannerState {
  final String message;
  ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}