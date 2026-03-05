import 'package:flutter/foundation.dart';

class CounterState with ChangeNotifier {
  int count = 0;

  bool get isEven => count % 2 == 0;

  void increment() {
    count++;
    notifyListeners();
  }

  void decrement() {
    if (count > 0) {
      count--;
      notifyListeners();
    }
  }

  void reset() {
    count = 0;
    notifyListeners();
  }
}
