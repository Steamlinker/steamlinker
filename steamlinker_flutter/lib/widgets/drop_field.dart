import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DropField extends StatefulWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String>? onChanged;

  const DropField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  State<DropField> createState() => _DropFieldState();
}

class _DropFieldState extends State<DropField> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            color: SteamColors.textSec,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selected,
          isExpanded: true,
          dropdownColor: SteamColors.bgPanel,
          icon: const Icon(Icons.expand_more, color: SteamColors.muted, size: 18),
          style: const TextStyle(color: SteamColors.light, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: SteamColors.bgInput,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: SteamColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: SteamColors.blue, width: 1.5),
            ),
          ),
          items: widget.items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                          color: SteamColors.light, fontSize: 13),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _selected = v);
            widget.onChanged?.call(v);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
