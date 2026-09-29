import 'package:flutter/material.dart';

class EntityCardList<T> extends StatelessWidget {
  final List<T> items;
  final int Function(T item) idOf;
  final String Function(T item) title;
  final String Function(T item) subtitle;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? muted;
  final ValueChanged<T>? onTap;

  const EntityCardList({
    super.key,
    required this.items,
    required this.idOf,
    required this.title,
    required this.subtitle,
    this.selected = const {},
    this.onToggleSelect,
    this.actions,
    this.muted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.errorContainer;
    return Column(
      children: [
        for (final item in items)
          Card(
            color: muted?.call(item) ?? false ? mutedColor : null,
            child: ListTile(
              leading: onToggleSelect == null
                  ? null
                  : Checkbox(
                      value: selected.contains(idOf(item)),
                      onChanged: (_) => onToggleSelect!(idOf(item)),
                    ),
              title: Text(title(item)),
              subtitle: Text(subtitle(item)),
              onTap: onTap == null ? null : () => onTap!(item),
              trailing: actions == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!(item),
                    ),
            ),
          ),
      ],
    );
  }
}
