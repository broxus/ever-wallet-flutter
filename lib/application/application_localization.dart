import 'package:ever_wallet/application/bloc/common/locale_cubit.dart';
import 'package:ever_wallet/data/repositories/locale_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationLocalization extends StatelessWidget {
  final Widget Function(String? locale) builder;

  const ApplicationLocalization({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<LocaleCubit>(
        create: (context) => LocaleCubit(context.read<LocaleRepository>()),
        child: BlocBuilder<LocaleCubit, String?>(
          builder: (context, state) => builder(state),
        ),
      );
}
