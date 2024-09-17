import 'dart:async';

abstract class DataStream<T> {
  late final StreamController<T> streamController;

  void init() {
    streamController = StreamController<T>();
    reload();
  }

  Stream<T> get stream => streamController.stream;

  void addData(T data) {
    streamController.sink.add(data);
  }

  void addError(dynamic e) {
    streamController.sink.addError(e);
  }

  void reload();

  void dispose() {
    streamController.close();
  }
}
