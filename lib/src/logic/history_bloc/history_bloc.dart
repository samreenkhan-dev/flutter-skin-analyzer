import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_event.dart';
import 'history_state.dart';
import '../../data/repositories/scan_repository.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ScanRepository _scanRepository;

  HistoryBloc(this._scanRepository) : super(HistoryInitial()) {
    on<FetchHistoryRequested>(_onFetchHistory);
    on<RefreshHistoryRequested>(_onFetchHistory); // Both do the same logic
  }

  Future<void> _onFetchHistory(HistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final scans = await _scanRepository.getHistory();

      if (scans.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(scans));
      }
    } catch (e) {
      emit(HistoryError("Could not load history: ${e.toString()}"));
      print("BLOC ERROR: $e");
    }
  }
}