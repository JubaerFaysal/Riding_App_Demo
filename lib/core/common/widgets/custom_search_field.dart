import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  final String hintText;
  final double borderRadius;
  final Color borderColor;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onClear,
    this.hintText = "Search",
    this.borderRadius = 12,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isFocused ? Colors.black : borderColor,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 20, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}