import 'dart:math';

import 'package:example/src/widgets/cv_widget.dart';
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
    print('before get provider');

    final provider = Provider.of<ProviderExamplePageProvider>(
      context,
    );
    print('after get provider');


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
          style: OutlinedButton.styleFrom(
            // backgroundColor: Color(0xFF5801fd),
            foregroundColor: Colors.black54,
            // foregroundColor: Colors.white,
            side: BorderSide(color: Colors.black12),
          ),
        );        
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

      _openFullScreenDialog(context, cvWidget);
    }  
  }

  void _openFullScreenDialog(BuildContext context, Widget content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black54, // Полупрозрачный фон
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width:  min(820.0, MediaQuery.of(context).size.width * 0.9),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Stack(
                  children: [
                    // Контент с прокруткой
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                        child: SingleChildScrollView(
                          child: content,
                        ),
                      ),
                    ),
                    
                    // Кнопка закрытия
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }


}
