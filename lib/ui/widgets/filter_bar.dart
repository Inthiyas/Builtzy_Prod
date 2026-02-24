import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final Widget searchField;
  final List<Widget> filterDropdowns;

  const FilterBar({
    super.key,
    required this.searchField,
    required this.filterDropdowns,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop/Tablet: Row layout
            return Row(
              children: [
                Expanded(flex: 2, child: searchField),
                const SizedBox(width: 16),
                ...filterDropdowns.map((dropdown) => Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: dropdown,
                      ),
                    )),
              ],
            );
          } else {
            // Mobile: Column layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: filterDropdowns.map((dropdown) => 
                     SizedBox(
                       width: (constraints.maxWidth - 16) / 2, // Half width minus spacing on mobile
                       child: dropdown,
                     )
                  ).toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
