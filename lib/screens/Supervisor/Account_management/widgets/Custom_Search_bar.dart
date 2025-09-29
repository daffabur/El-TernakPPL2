import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';


class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(


          constraints: const BoxConstraints(maxHeight: 48),
          prefixIcon: Icon(
            Icons.search,
            color: AppStyles.primaryColor,
          ),
          hintText: 'Search...',

          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide:  BorderSide(
              width: 2.0,
              color: AppStyles.primaryColor
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              width: 3.0,
              color: AppStyles.primaryColor,
            ),
          ),
        ),
    );
  }
}
