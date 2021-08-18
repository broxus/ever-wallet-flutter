import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/misc/notifications_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';
import '../modals/notification_list.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({Key? key}) : super(key: key);

  @override
  _NotificationButtonState createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  late final NotificationsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt.get<NotificationsBloc>();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<NotificationsBloc, NotificationsState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (notifications) => Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: CrystalColor.primary.withOpacity(0.16),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: CrystalInkWell(
                    onTap: () {
                      CrystalBottomSheet.show(
                        context,
                        expand: true,
                        padding: EdgeInsets.zero,
                        title: LocaleKeys.notifications_modal_title.tr(),
                        body: NotificationList(bloc: bloc),
                      );
                    },
                    highlightColor: CrystalColor.primary.withOpacity(0.05),
                    splashColor: CrystalColor.primary.withOpacity(0.3),
                    child: Center(
                      child: Image.asset(
                        Assets.images.iconNotification.path,
                        width: 16,
                        height: 20,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Badge(counter: notifications.length),
                ),
            ],
          ),
          orElse: () => const SizedBox(),
        ),
      );
}
