import 'dart:convert';

import '../../features/categories/data/models/category_model.dart';
import '../../features/drafts/data/models/draft_model.dart';
import '../../features/levels/data/models/level_model.dart';
import '../../features/support_tickets/data/models/ticket_model.dart';

/// Serializer for the values the app hands to go_router as `extra`.
///
/// go_router does not keep `extra` alive as an object. After every navigation
/// it encodes the whole match list — `extra` included — into the route
/// information it reports to the platform, and decodes it again on the next
/// `refresh()`.
///
/// Without a codec go_router falls back to `json.encode`, which calls the
/// models' `toJson()`. Ours return a *String* (`json.encode(toMap())`), so a
/// `CategoryModel` came back as a String and `state.extra as CategoryModel?`
/// threw `type 'String' is not a subtype of type 'CategoryModel?'` on the
/// first refresh after opening a category.
///
/// Only immutable value objects belong here. Live objects (Cubits) can never
/// survive serialization under any codec, so none are passed as `extra` any
/// more — a route that needs one either owns it or reads it from a provider
/// hoisted above the route. Route builders still read `extra` with type tests
/// and treat it as an optional hint on top of the path parameters.
class AppExtraCodec extends Codec<Object?, Object?> {
  const AppExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();
}

const String _typeKey = 'type';
const String _valueKey = 'value';

const String _stringType = 'string';
const String _categoryType = 'category';
const String _levelType = 'level';
const String _ticketType = 'ticket';
const String _draftType = 'draft';

/// Wraps a model's own JSON in a tagged envelope. The payload stays a plain
/// [String] so it survives the platform channel with its typing intact — a
/// nested map would come back as `Map<Object?, Object?>`, which `fromMap`
/// rejects.
Map<String, Object?> _tagged(String type, String value) => <String, Object?>{
  _typeKey: type,
  _valueKey: value,
};

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input is String) return _tagged(_stringType, input);
    if (input is CategoryModel) return _tagged(_categoryType, input.toJson());
    if (input is LevelModel) return _tagged(_levelType, input.toJson());
    if (input is TicketModel) return _tagged(_ticketType, input.toJson());
    if (input is DraftModel) return _tagged(_draftType, input.toJson());
    return null;
  }
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input is! Map) return null;
    final value = input[_valueKey];
    if (value is! String) return null;
    final type = input[_typeKey];
    if (type == _stringType) return value;
    // A restored route can outlive the schema that wrote it (the OS restores an
    // app that has since been updated). Routing must never throw over a stale
    // payload — degrading to `null` puts the route on its normal fallback.
    try {
      if (type == _categoryType) return CategoryModel.fromJson(value);
      if (type == _levelType) return LevelModel.fromJson(value);
      if (type == _ticketType) return TicketModel.fromJson(value);
      if (type == _draftType) return DraftModel.fromJson(value);
    } catch (_) {
      return null;
    }
    return null;
  }
}
