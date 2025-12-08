import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart, size: 100, color: AppColors.primaryLight),
          const SizedBox(height: 20),
          Text(
            "Hoşgeldin!",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Bütçe akışını yönetmeye başlamak için hazırsın.\nVeriler ve grafikler yakında burada olacak.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
