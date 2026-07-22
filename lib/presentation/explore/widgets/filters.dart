import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {

  final List<String> filters = [
    "FEED",
    "DISCOVER",
    "GROUPS",
    "ACTIVITY",
  ];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow : Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey
                )
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.black87 : null,
                ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
