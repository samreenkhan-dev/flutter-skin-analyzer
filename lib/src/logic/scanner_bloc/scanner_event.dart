import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartAnalysisEvent extends ScannerEvent {
  final File image;
  StartAnalysisEvent(this.image);

  @override
  List<Object?> get props => [image];
}
class ResetScannerEvent extends ScannerEvent {}