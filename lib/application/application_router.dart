import 'package:beamer/beamer.dart';
import 'package:ever_wallet/application/main/main_screen.dart';
import 'package:ever_wallet/application/onboarding/start_screen/start_screen.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationRouter extends StatefulWidget {
  final Widget Function(BeamerDelegate beamerDelegate) builder;

  const ApplicationRouter({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<ApplicationRouter> createState() => _ApplicationRouterState();
}

class _ApplicationRouterState extends State<ApplicationRouter> {
  final beamerDelegate = BeamerDelegate(
    initialPath: '/main',
    guards: [
      BeamGuard(
        pathPatterns: ['/main'],
        check: (context, state) => context.read<KeysRepository>().keys.isNotEmpty,
        beamToNamed: (origin, target) => '/onboarding',
      ),
    ],
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        MainLocation(),
        WizardLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => widget.builder(beamerDelegate);
}

class MainLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/main/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('main'),
          title: 'Main',
          child: MainScreen(),
        ),
      ];
}

class WizardLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/onboarding'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('onboarding'),
          title: 'Onboarding',
          child: StartScreen(),
        ),
      ];
}
