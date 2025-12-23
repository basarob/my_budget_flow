import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleAbout)),
      body: const Center(child: Placeholder()),
    );
  }
}
