import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';
import '../../data/repositories/scan_repository.dart'; // Ensure this import is correct

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScanRepository _scanRepository; // Change from GeminiService to ScanRepository

  // This constructor now expects exactly ONE argument: the repository
  ScannerBloc(this._scanRepository) : super(ScannerInitial()) {
    on<StartAnalysisEvent>(_onStartAnalysis);
    on<ResetScannerEvent>(_onResetScanner);
  }

  Future<void> _onStartAnalysis(StartAnalysisEvent event, Emitter<ScannerState> emit) async {
    emit(ScannerLoading());
    try {
      final result = await _scanRepository.processNewScan(event.image);
      emit(ScannerSuccess(result));
    } catch (e) {
      emit(ScannerError("Analysis Failed: ${e.toString()}"));
    }
  }

  void _onResetScanner(ResetScannerEvent event, Emitter<ScannerState> emit) {
    emit(ScannerInitial());
  }
}