part of 'cell_service.dart';

typedef CellByFieldId = LinkedHashMap<String, CellIdentifier>;

class GridBaseCell {
  dynamic object;
  GridBaseCell({
    required this.object,
  });
}

/// Use to index the cell in the grid.
/// We use [fieldId + rowId] to identify the cell.
class CellCacheKey {
  final String fieldId;
  final String rowId;
  CellCacheKey({
    required this.fieldId,
    required this.rowId,
  });
}

/// GridCellCache is used to cache cell data of each block.
/// We use GridCellCacheKey to index the cell in the cache.
/// Read https://appflowy.gitbook.io/docs/essential-documentation/contribute-to-appflowy/architecture/frontend/grid
/// for more information
class CellCache {
  final String viewId;

  /// fieldId: {cacheKey: GridCell}
  final Map<String, Map<String, dynamic>> _cellDataByFieldId = {};
  CellCache({
    required this.viewId,
  });

  void removeCellWithFieldId(String fieldId) {
    _cellDataByFieldId.remove(fieldId);
  }

  void remove(CellCacheKey key) {
    var map = _cellDataByFieldId[key.fieldId];
    if (map != null) {
      map.remove(key.rowId);
    }
  }

  void insert<T extends GridBaseCell>(CellCacheKey key, T value) {
    var map = _cellDataByFieldId[key.fieldId];
    if (map == null) {
      _cellDataByFieldId[key.fieldId] = {};
      map = _cellDataByFieldId[key.fieldId];
    }

    map![key.rowId] = value.object;
  }

  T? get<T>(CellCacheKey key) {
    final map = _cellDataByFieldId[key.fieldId];
    if (map == null) {
      return null;
    } else {
      final value = map[key.rowId];
      if (value is T) {
        return value;
      } else {
        if (value != null) {
          Log.error("Expected value type: $T, but receive $value");
        }
        return null;
      }
    }
  }

  Future<void> dispose() async {
    _cellDataByFieldId.clear();
  }
}
