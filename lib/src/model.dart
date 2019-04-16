part of mutable_model;

abstract class Model extends ChangeNotifier {

  Iterable<Property> get properties;
  bool _flushing = false;
  bool _repeatFlush = false;

  /// Fires a change event and clears the change flag on all properties. Returns true if there were changes.
  bool flushChanges() {
    if(_flushing) {
      _repeatFlush = true;
      return false;
    }
    onFlushChanges();
    final changed = Set.from(properties.where((p) => p.changed));
    if(changed.isEmpty)
      return false;
    try {
      _flushing = true;
      notifyListeners();
    } finally {
      _flushing = false;
      for(var p in changed)
        p.changed = false;
      if(_repeatFlush) {
        _repeatFlush = false;
        flushChanges();
      }
    }
    return true;
  }

  /// A hook to perform calculations before firing [notifyListeners].
  @protected
  void onFlushChanges() {
  }

  /// Returns true if any of the properties has changed.
  bool get changed {
    for(var p in properties)
      if(p.changed)
        return true;
    return false;
  }

  void copyFrom(Model other, {bool clearChanges = true}) {
    var it0 = other.properties.iterator;
    var it1 = this.properties.iterator;
    while(it0.moveNext() && it1.moveNext()) {
      final p0 = it0.current;
      final p1 = it1.current;
      p1.copyFrom(p0);
      if(clearChanges)
        p1.changed = false;
    }
  }

}
