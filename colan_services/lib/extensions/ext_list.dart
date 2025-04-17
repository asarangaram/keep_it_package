extension ExtDimension<T> on List<T> {
  List<T> firstNItems(int n) {
    if (length <= n) {
      return this; // Return the list as it is
    } else {
      return sublist(0, n); // Return the first N items
    }
  }

  List<T> removeFirstItem() {
    if (isNotEmpty) {
      return List<T>.from(this)..removeAt(0);
    } else {
      return this;
    }
  }
}

extension IDGenerator on List<String> {
  String toID() => join(' ');
}
