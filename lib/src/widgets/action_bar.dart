import 'dart:math';

import 'package:example/src/utils.dart';
import 'package:example/src/widgets/cv_widget.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:provider/provider.dart';

import '../../example.dart';
import '../../register.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider = Provider.of<ProviderExamplePageProvider>(
      context,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth <= 800;
        return Padding(
          padding: const EdgeInsets.only(top: kRegularPadding, bottom: kRegularPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 7, child: _buildPreviewButton(context, provider)),
              const SizedBox(width: kRegularPadding),
              if (narrow && context.wizardController.index > 0)
                const Expanded(flex: 4, child: PreviousButton()),
              if (!narrow && context.wizardController.index > 0) const PreviousButton(),
              const SizedBox(width: kRegularPadding),
              if (narrow) Expanded(flex: 4, child: _buildForwardButton(context)),
              if (!narrow) _buildForwardButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForwardButton(
    BuildContext context,
  ) {
    return StreamBuilder<int>(
      stream: context.wizardController.indexStream,
      initialData: context.wizardController.index,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final index = snapshot.data!;
        if (context.wizardController.isLastStep(index)) {
          return const FinishedButton();
        }
        return const NextButton();
      },
    );
  }

  _buildPreviewButton(BuildContext context, ProviderExamplePageProvider provider) {
    return StreamBuilder<int>(
      stream: context.wizardController.indexStream,
      initialData: context.wizardController.index,
      builder: (context, snapshot) {
        final index = snapshot.data!;
        return ElevatedButton(
            child: const Text("Предпросмотр"),
            onPressed: () => _onPreview(context, provider),
            style: whiteButtonStyle);
      },
    );
  }

  void _onPreview(BuildContext context, ProviderExamplePageProvider provider) {
    Widget cvWidget = Text('No data');

    if (provider.cv != null) {
      // save current step
      provider.getStepProvider(context.wizardController.index).updateCV(provider.cv!);
      print('after update cv');
      cvWidget = CVWidget(cv: provider.cv!);

      // context.wizardController.stepControllers[context.wizardController.index].step.updateCV();
      // CV? cv = authProvider.userCV;

      openFullScreenDialog(context, cvWidget, 820);
    }
  }
}
