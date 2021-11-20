import 'package:flutter/material.dart';

import '../routes/router.gr.dart';
import 'application_bloc_listener.dart';
import 'application_bloc_provider.dart';
import 'application_localization.dart';
import 'material_application.dart';

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) => ApplicationLocalization(
        child: ApplicationBlocProvider(
          child: ApplicationBlocListener(
            appRouter: appRouter,
            child: MaterialApplication(
              appRouter: appRouter,
            ),
          ),
        ),
      );
}
