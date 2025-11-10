import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:provider/provider.dart';

import 'example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Анкета',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          // primary: Colors.deepPurple,
          primary: Color(0xFF5801fd),
          onPrimary: Colors.white,
          secondary: Colors.orange,
          onSecondary: Colors.white,
          surface: Colors.grey.shade100,
          onSurface: Colors.grey.shade700,
          background: Colors.white,
          onBackground: Colors.grey.shade700,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          linearTrackColor: Colors.orange.shade100,
          color: Colors.orange,
        ),
      ),
      home: ProviderExamplePage.provider(),
    );
  }
}

class ProviderExamplePage extends StatelessWidget {
  const ProviderExamplePage._({Key? key}) : super(key: key);

  static Provider provider({Key? key}) {
    return Provider<ProviderExamplePageProvider>(
      create: (_) => ProviderExamplePageProvider(),
      dispose: (_, provider) => provider.dispose(),
      child: ProviderExamplePage._(
        key: key,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider = Provider.of<ProviderExamplePageProvider>(
      context,
    );
    return DefaultWizardController(
      stepControllers: [
        WizardStepController(
          step: provider.stepOneProvider,
        ),
        WizardStepController(
          step: provider.stepTwoProvider,
          isNextEnabled: true,
        ),
        WizardStepController(
          step: provider.stepThreeProvider,
        ),
        WizardStepController(
          step: provider.stepFourProvider,
        ),
      ],
      // Wrapping with a builder so the context contains the [WizardController]
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            appBar: AppBar(
              title: StreamBuilder<int>(
                stream: context.wizardController.indexStream,
                initialData: context.wizardController.index,
                builder: (context, snapshot) {
                  return Text("Анкета - шаг ${snapshot.data! + 1}");
                },
              ),
            ),
            body: WizardEventListener(
              listener: (context, event) {
                debugPrint('### ${event.runtimeType} received');
                if (event is WizardForcedGoBackToEvent) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Step ${event.toIndex + 2} got disabled so the wizard is moving back to step ${event.toIndex + 1}.',
                    ),
                    dismissDirection: DismissDirection.horizontal,
                  ));
                } else if (event is WizardGoBackEvent) {
                  // print('!!! ${context.wizardController.index}');
                  // context.wizardController.goTo(index: 0);
                  // context.wizardController.goBack();
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      _buildProgressIndicator(
                        context,
                      ),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight,
                            maxWidth: 1024,
                          ),
                          child: Container(
                            color: Colors.grey[200],
                            padding: const EdgeInsets.all(10),
                            child: _buildWizard(
                              context,
                              provider: provider,
                              constraints: constraints,
                              orientation: orientation,
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight,
                            maxWidth: 1024,
                          ),
                          child: const ActionBar()),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      onStepChanged: (prev, next) {
        // print('$prev =========================> $next');
      },
    );
  }

  Widget _buildWizard(
    BuildContext context, {
    required ProviderExamplePageProvider provider,
    required BoxConstraints constraints,
    required Orientation orientation,
  }) {
    final wizard = StreamBuilder<int>(
        stream: context.wizardController.indexStream,
        initialData: context.wizardController.index,
        builder: (context, snapshot) {
          final index = snapshot.data!;
          return Wizard(
            stepBuilder: (context, state) {
              switch (index) {
                case 0:
                  return StepOne(
                    provider: provider.stepOneProvider,
                  );

                case 1:
                  return StepTwo(
                    provider: provider.stepTwoProvider,
                  );

                case 2:
                  return StepThree(
                    provider: provider.stepThreeProvider,
                  );

                case 3:
                  return StepFour(
                    provider: provider.stepFourProvider,
                  );

                default:
                  return Container();
              }
            },
          );
        });
    final narrow = constraints.maxWidth <= 800;
    if (narrow) {
      return wizard;
    }
    return Row(
      children: [
        const SizedBox(
          width: 150,
          child: StepsOverview(),
        ),
        Expanded(
            child: Padding(
          padding:
              const EdgeInsets.only(top: 6.0, bottom: 6, left: 0, right: 0),
          child: wizard,
        ))
      ],
    );
  }

  Widget _buildProgressIndicator(
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
        return StepsProgressIndicator(
          count: context.wizardController.stepCount,
          index: index,
        );
      },
    );
  }
}

class ProviderExamplePageProvider {
  ProviderExamplePageProvider()
      : stepOneProvider = StepOneProvider(),
        stepTwoProvider = StepTwoProvider(),
        stepThreeProvider = StepThreeProvider(),
        stepFourProvider = StepFourProvider();

  final StepOneProvider stepOneProvider;
  final StepTwoProvider stepTwoProvider;
  final StepThreeProvider stepThreeProvider;
  final StepFourProvider stepFourProvider;

  Future<void> reportIssue() async {
    debugPrint('Finished!');
  }

  Future<void> dispose() async {
    stepOneProvider.dispose();
    stepTwoProvider.dispose();
    stepThreeProvider.dispose();
    stepFourProvider.dispose();
  }
}
