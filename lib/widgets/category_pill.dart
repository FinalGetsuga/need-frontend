import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/utils/category_colors.dart';

import '../models/category.dart';

class CategoryPill extends StatelessWidget{
  final Category category;
  const CategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = CategoryColors.forId(category.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(20)),
      child: Text(category.name, style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}