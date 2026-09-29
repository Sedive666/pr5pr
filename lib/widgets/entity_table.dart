import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final ValueChanged<bool>? onToggleAll;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? muted;
  final ValueChanged<T>? onTap;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.onToggleAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.muted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortIndex = columns.indexWhere(
      (c) => c.sortField != null && c.sortField == sortField,
    );
    final mutedColor = WidgetStatePropertyAll(
      Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            sortColumnIndex: sortIndex < 0 ? null : sortIndex,
            sortAscending: sortAscending,
            showCheckboxColumn: onToggleSelect != null,
            onSelectAll: onToggleAll == null
                ? null
                : (v) => onToggleAll!(v ?? false),
            columns: [
              for (final c in columns)
                DataColumn(
                  label: Text(c.label),
                  numeric: c.numeric,
                  onSort: c.sortField == null || onSort == null
                      ? null
                      : (_, _) => onSort!(c.sortField!),
                ),
              if (actions != null) const DataColumn(label: Text('Действия')),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  selected: selected.contains(idOf(item)),
                  onSelectChanged: onToggleSelect == null
                      ? null
                      : (_) => onToggleSelect!(idOf(item)),
                  color: muted?.call(item) ?? false ? mutedColor : null,
                  cells: [
                    for (final c in columns)
                      DataCell(
                        c.build(item),
                        onTap: onTap == null ? null : () => onTap!(item),
                      ),
                    if (actions != null)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!(item),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
