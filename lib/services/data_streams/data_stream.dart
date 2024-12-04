import 'dart:async';

abstract class DataStream<T> {
  late final StreamController<T> streamController;

  void init() {
    // Use a broadcast stream to allow multiple listeners
    streamController = StreamController<T>.broadcast();
    reload();
  }

  // Expose the broadcast stream
  Stream<T> get stream => streamController.stream;

  void addData(T data) {
    // Ensure the stream is not closed before adding data
    if (!streamController.isClosed) {
      streamController.sink.add(data);
    }
  }

  void addError(dynamic e) {
    // Ensure the stream is not closed before adding an error
    if (!streamController.isClosed) {
      streamController.sink.addError(e);
    }
  }

  /// Abstract method to be implemented by subclasses to reload data
  void reload();

  void dispose() {
    // Close the stream when the object is disposed
    streamController.close();
  }
}
