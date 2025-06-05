import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class StoreURL {
  const StoreURL(this.uri);
  factory StoreURL.fromString(String url) {
    return StoreURL(Uri.parse(url));
  }
  final Uri uri;
  String get scheme => uri.scheme;
  String get name => uri.host.isNotEmpty ? uri.host : uri.path;

  @override
  bool operator ==(covariant StoreURL other) {
    if (identical(this, other)) return true;

    return other.uri == uri;
  }

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => '$uri';
}

final defaultStore = StoreURL.fromString('local://default');

@immutable
class AvailableStores {
  factory AvailableStores(
      {List<StoreURL>? availableStores, int activeStoreIndex = 0}) {
    final stores = availableStores ?? [defaultStore];

    if (activeStoreIndex >= stores.length) {
      activeStoreIndex = 0;
    }
    return AvailableStores._(
        availableStores: stores, activeStoreIndex: activeStoreIndex);
  }
  const AvailableStores._({
    required this.availableStores,
    required this.activeStoreIndex,
  });
  final List<StoreURL> availableStores;
  final int activeStoreIndex;

  AvailableStores copyWith({
    List<StoreURL>? availableStores,
    int? activeStoreIndex,
  }) {
    return AvailableStores._(
      availableStores: availableStores ?? this.availableStores,
      activeStoreIndex: activeStoreIndex ?? this.activeStoreIndex,
    );
  }

  @override
  bool operator ==(covariant AvailableStores other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.availableStores, availableStores) &&
        other.activeStoreIndex == activeStoreIndex;
  }

  @override
  int get hashCode => availableStores.hashCode ^ activeStoreIndex.hashCode;

  @override
  String toString() =>
      'AvailableStores(availableStores: $availableStores, activeStoreIndex: $activeStoreIndex)';

  AvailableStores setActiveStore(StoreURL storeURL) {
    if (!availableStores.contains(storeURL)) {
      throw Exception('Store is not registered');
    }
    return copyWith(
        activeStoreIndex: availableStores.indexWhere((e) => e == storeURL));
  }

  AvailableStores addStore(StoreURL storeURL) {
    if (availableStores.contains(storeURL)) {
      throw Exception('Store already exists');
    }
    final stores = List<StoreURL>.from(availableStores)
      ..add(storeURL)
      ..sort();

    final index = stores.indexWhere((e) => e == storeURL);
    return copyWith(availableStores: stores, activeStoreIndex: index);
  }

  AvailableStores removeStore(StoreURL storeURL) {
    if (!availableStores.contains(storeURL)) {
      throw Exception('Store is not registered');
    }
    if (isDefaultStore(storeURL)) {
      throw Exception("Default store can't be removed");
    }
    final index = (isActiveStore(storeURL)) ? 0 : activeStoreIndex;

    final stores = List<StoreURL>.from(availableStores)..remove(storeURL);
    return copyWith(availableStores: stores, activeStoreIndex: index);
  }

  bool isDefaultStore(StoreURL storeURL) {
    return storeURL == defaultStore;
  }

  bool isActiveStore(StoreURL storeURL) {
    return storeURL == availableStores[activeStoreIndex];
  }

  StoreURL get activeStore => availableStores[activeStoreIndex];
}
