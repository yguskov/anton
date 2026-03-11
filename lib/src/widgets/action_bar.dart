import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../../example.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth <= 800;
        return Padding(
          padding: const EdgeInsets.only(top: kRegularPadding, bottom: kRegularPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 7, child: _buildPreviewButton(context)),
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

  _buildPreviewButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Предпросмотр"),
      onPressed: () => false,
      style: OutlinedButton.styleFrom(
        // backgroundColor: Color(0xFF5801fd),
        foregroundColor: Colors.black54,
        // foregroundColor: Colors.white,
        side: BorderSide(color: Colors.black12),
      ),
    );
  }
}
