import 'dart:html';

import 'package:example/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example/models/cv.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import 'example.dart';

GlobalKey<StepFinishState>? stepFinishKey = GlobalKey<StepFinishState>();

List<GlobalKey<StateStep>> stepGlobalKey = [
  GlobalKey<StepOneState>(),
  GlobalKey<StepTwoState>(),
  GlobalKey<StepThreeState>(),
  GlobalKey<StepFourState>(),
  GlobalKey<StepFiveState>(),
  GlobalKey<StepSixState>(),
  GlobalKey<StepSevenState>(),
];

class ProviderExamplePage extends StatelessWidget {
  ProviderExamplePage._({Key? key})
      : cv = CV.instance,
        super(key: key);

  CV cv;
  bool first = true;

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
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    if (first) {
      print('----first load user-----');
      if (authProvider.currentUser?.guid != null) {
        Future.microtask(() async {
          await authProvider.loadUserCV(authProvider.currentUser!.guid);
          cv = authProvider.userCV ?? CV.instance;
          ProviderExamplePageProvider pageProvider =
              Provider.of<ProviderExamplePageProvider>(context, listen: false);
          pageProvider.reloadDataFromCV(cv);
          print('----load cv with ${CV.instance.getValue('fio')}-----'); // @book load CV
        });
        first = false;
        return CircularProgressIndicator();
      } else {
        // try to load from local storage
        if (window.localStorage['cv'] != null) cv = CV.fromJson(window.localStorage['cv']!);
        print('----got  cv from LS ${CV.instance.getValue('fio')}-----');
      }
    }

    final provider = Provider.of<ProviderExamplePageProvider>(
      context,
    );

    provider.cv = cv;

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
        WizardStepController(
          step: provider.stepFiveProvider,
          isNextEnabled: true, // @fixme for debug
        ),
        WizardStepController(
          step: provider.stepSixProvider,
        ),
        WizardStepController(
          step: provider.stepSevenProvider,
        ),
        WizardStepController(
          step: provider.stepFinishProvider,
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
        // @todo save step data to CV
        provider.getStepProvider(prev).updateCV(cv);
        print('$prev =========================> $next');
      },

      // onControllerCreated: (wizardController) async {

      // },
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
                    key: stepGlobalKey[0],
                  );

                case 1:
                  return StepTwo(
                    provider: provider.stepTwoProvider,
                    key: stepGlobalKey[1],
                  );

                case 2:
                  return StepThree(
                    provider: provider.stepThreeProvider,
                    // key: stepGlobalKey[3],
                  );

                case 3:
                  return StepFour(
                    provider: provider.stepFourProvider,
                  );

                case 4:
                  return StepFive(
                    provider: provider.stepFiveProvider,
                  );

                case 5:
                  return StepSix(
                    provider: provider.stepSixProvider,
                  );

                case 6:
                  return StepSeven(
                    provider: provider.stepSevenProvider,
                  );

                case 7:
                  return StepFinish(
                    provider: provider.stepFinishProvider,
                    key: stepFinishKey,
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
          padding: const EdgeInsets.only(top: 6.0, bottom: 6, left: 0, right: 0),
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
  CV? cv;
  ProviderExamplePageProvider()
      : stepOneProvider = StepOneProvider(),
        stepTwoProvider = StepTwoProvider(),
        stepThreeProvider = StepThreeProvider(),
        stepFourProvider = StepFourProvider(),
        stepFiveProvider = StepFiveProvider(),
        stepSixProvider = StepSixProvider(),
        stepSevenProvider = StepSevenProvider(),
        stepFinishProvider = StepFinishProvider();

  final StepOneProvider stepOneProvider;
  final StepTwoProvider stepTwoProvider;
  final StepThreeProvider stepThreeProvider;
  final StepFourProvider stepFourProvider;
  final StepFiveProvider stepFiveProvider;
  final StepSixProvider stepSixProvider;
  final StepSevenProvider stepSevenProvider;
  final StepFinishProvider stepFinishProvider;

  Future<void> reportIssue() async {
    debugPrint('Finished!');
  }

  MyWizardStep getStepProvider(int step) {
    print('|||||||$step||||||||');
    switch (step) {
      case 0:
        return stepOneProvider;
      case 1:
        return stepTwoProvider;
      case 2:
        return stepThreeProvider;
      case 3:
        return stepFourProvider;
      case 4:
        return stepFiveProvider;
      case 5:
        return stepSixProvider;
      case 6:
        return stepSevenProvider;
      default:
        return stepFinishProvider;
    }
  }

  Future<void> dispose() async {
    stepOneProvider.dispose();
    stepTwoProvider.dispose();
    stepThreeProvider.dispose();
    stepFourProvider.dispose();
    stepFiveProvider.dispose();
    stepSixProvider.dispose();
    stepSevenProvider.dispose();
    stepFinishProvider.dispose();
  }

  void reloadDataFromCV(CV cv) {
    getStepProvider(0).reloadDataFromCV(cv);
    getStepProvider(1).reloadDataFromCV(cv);
    getStepProvider(2).reloadDataFromCV(cv);
    getStepProvider(3).reloadDataFromCV(cv);
    getStepProvider(4).reloadDataFromCV(cv);
    getStepProvider(5).reloadDataFromCV(cv);
    getStepProvider(6).reloadDataFromCV(cv);
    getStepProvider(7).reloadDataFromCV(cv);
  }
}
