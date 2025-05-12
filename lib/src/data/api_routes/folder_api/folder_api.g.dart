// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getFoldersHash() => r'b4ce3395f9f4eee69fe0e7f1d3f045e0ee7d5c80';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getFolders].
@ProviderFor(getFolders)
const getFoldersProvider = GetFoldersFamily();

/// See also [getFolders].
class GetFoldersFamily extends Family<AsyncValue<List<Folder>>> {
  /// See also [getFolders].
  const GetFoldersFamily();

  /// See also [getFolders].
  GetFoldersProvider call({
    required String eventId,
    int? pageNo,
    int? limit,
  }) {
    return GetFoldersProvider(
      eventId: eventId,
      pageNo: pageNo,
      limit: limit,
    );
  }

  @override
  GetFoldersProvider getProviderOverride(
    covariant GetFoldersProvider provider,
  ) {
    return call(
      eventId: provider.eventId,
      pageNo: provider.pageNo,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getFoldersProvider';
}

/// See also [getFolders].
class GetFoldersProvider extends AutoDisposeFutureProvider<List<Folder>> {
  /// See also [getFolders].
  GetFoldersProvider({
    required String eventId,
    int? pageNo,
    int? limit,
  }) : this._internal(
          (ref) => getFolders(
            ref as GetFoldersRef,
            eventId: eventId,
            pageNo: pageNo,
            limit: limit,
          ),
          from: getFoldersProvider,
          name: r'getFoldersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getFoldersHash,
          dependencies: GetFoldersFamily._dependencies,
          allTransitiveDependencies:
              GetFoldersFamily._allTransitiveDependencies,
          eventId: eventId,
          pageNo: pageNo,
          limit: limit,
        );

  GetFoldersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
    required this.pageNo,
    required this.limit,
  }) : super.internal();

  final String eventId;
  final int? pageNo;
  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<Folder>> Function(GetFoldersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetFoldersProvider._internal(
        (ref) => create(ref as GetFoldersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
        pageNo: pageNo,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Folder>> createElement() {
    return _GetFoldersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFoldersProvider &&
        other.eventId == eventId &&
        other.pageNo == pageNo &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);
    hash = _SystemHash.combine(hash, pageNo.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetFoldersRef on AutoDisposeFutureProviderRef<List<Folder>> {
  /// The parameter `eventId` of this provider.
  String get eventId;

  /// The parameter `pageNo` of this provider.
  int? get pageNo;

  /// The parameter `limit` of this provider.
  int? get limit;
}

class _GetFoldersProviderElement
    extends AutoDisposeFutureProviderElement<List<Folder>> with GetFoldersRef {
  _GetFoldersProviderElement(super.provider);

  @override
  String get eventId => (origin as GetFoldersProvider).eventId;
  @override
  int? get pageNo => (origin as GetFoldersProvider).pageNo;
  @override
  int? get limit => (origin as GetFoldersProvider).limit;
}

String _$getFilesHash() => r'7283be2ec0c26d74a9c178b7bf82aa6d43b9eaf6';

/// See also [getFiles].
@ProviderFor(getFiles)
const getFilesProvider = GetFilesFamily();

/// See also [getFiles].
class GetFilesFamily extends Family<AsyncValue<Folder>> {
  /// See also [getFiles].
  const GetFilesFamily();

  /// See also [getFiles].
  GetFilesProvider call({
    required String folderId,
    String? type,
  }) {
    return GetFilesProvider(
      folderId: folderId,
      type: type,
    );
  }

  @override
  GetFilesProvider getProviderOverride(
    covariant GetFilesProvider provider,
  ) {
    return call(
      folderId: provider.folderId,
      type: provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getFilesProvider';
}

/// See also [getFiles].
class GetFilesProvider extends AutoDisposeFutureProvider<Folder> {
  /// See also [getFiles].
  GetFilesProvider({
    required String folderId,
    String? type,
  }) : this._internal(
          (ref) => getFiles(
            ref as GetFilesRef,
            folderId: folderId,
            type: type,
          ),
          from: getFilesProvider,
          name: r'getFilesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getFilesHash,
          dependencies: GetFilesFamily._dependencies,
          allTransitiveDependencies: GetFilesFamily._allTransitiveDependencies,
          folderId: folderId,
          type: type,
        );

  GetFilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
    required this.type,
  }) : super.internal();

  final String folderId;
  final String? type;

  @override
  Override overrideWith(
    FutureOr<Folder> Function(GetFilesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetFilesProvider._internal(
        (ref) => create(ref as GetFilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Folder> createElement() {
    return _GetFilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFilesProvider &&
        other.folderId == folderId &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetFilesRef on AutoDisposeFutureProviderRef<Folder> {
  /// The parameter `folderId` of this provider.
  String get folderId;

  /// The parameter `type` of this provider.
  String? get type;
}

class _GetFilesProviderElement extends AutoDisposeFutureProviderElement<Folder>
    with GetFilesRef {
  _GetFilesProviderElement(super.provider);

  @override
  String get folderId => (origin as GetFilesProvider).folderId;
  @override
  String? get type => (origin as GetFilesProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
