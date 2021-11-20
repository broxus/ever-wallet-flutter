// import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:recase/recase.dart';
// import 'package:timeago/timeago.dart' as timeago;

// import '../../../../../../../../domain/blocs/misc/notifications_bloc.dart';
// import '../../../../../../../../domain/models/app_notification.dart';
// import '../../../../../../../../domain/models/app_notification_action.dart';
// import '../../../../design/design.dart';

// class NotificationList extends StatefulWidget {
//   final NotificationsBloc bloc;

//   const NotificationList({
//     Key? key,
//     required this.bloc,
//   }) : super(key: key);

//   @override
//   _NotificationListState createState() => _NotificationListState();
// }

// class _NotificationListState extends State<NotificationList> {
//   @override
//   Widget build(BuildContext context) => BlocBuilder<NotificationsBloc, NotificationsState>(
//         bloc: widget.bloc,
//         builder: (context, state) => state.maybeWhen(
//           ready: (notifications) =>
//               notifications.isNotEmpty ? _getNotificationLayout(notifications) : _getPlaceholder(),
//           orElse: () => const SizedBox(),
//         ),
//       );

//   Widget _getPlaceholder() => Center(
//         child: Text(
//           LocaleKeys.notifications_modal_placeholder_empty.tr(),
//           style: const TextStyle(
//             fontSize: 16,
//             color: CrystalColor.fontSecondaryDark,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       );

//   Widget _getNotificationLayout(Map<DateTime, List<AppNotification>> notifications) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: FadingEdgeScrollView.fromScrollView(
//           shouldDisposeScrollController: true,
//           child: ListView.separated(
//             controller: ScrollController(),
//             itemBuilder: (context, index) => _getNotificationsHeader(
//               timeago.format(notifications.keys.elementAt(index)),
//               notifications.values.elementAt(index),
//             ),
//             itemCount: notifications.entries.length,
//             separatorBuilder: (BuildContext context, int index) => const Divider(
//               height: 24,
//               thickness: 1,
//             ),
//           ),
//         ),
//       );

//   Widget _getNotificationsHeader(String date, List<AppNotification> notifications) => Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
//             child: Text(date, style: const TextStyle(color: CrystalColor.fontTitleSecondaryDark)),
//           ),
//           for (final notification in notifications) _getNotificationItem(notification),
//         ],
//       );

//   Widget _getNotificationItem(AppNotification notification) {
//     final lastTimeReading = DateTime.now().subtract(const Duration(hours: 2));
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 2),
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         color:
//             lastTimeReading.isAfter(notification.time) ? Colors.transparent : CrystalColor.secondary.withOpacity(0.3),
//         child: Row(
//           children: [
//             const CircleIcon(
//               size: 32,
//               color: CrystalColor.fontSecondaryDark,
//             ),
//             const CrystalDivider(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     notification.text,
//                     style: const TextStyle(
//                       color: CrystalColor.fontDark,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     _getTime(notification.time),
//                     style: const TextStyle(
//                       color: CrystalColor.fontTitleSecondaryDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (notification.action != AppNotificationAction.none) _getAction(notification.action),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getTime(DateTime date) {
//     final _date = DateTime(date.year, date.month, date.day);
//     final nowDateTime = DateTime.now();
//     final nowDate = DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day);

//     if (_date.isAtSameMomentAs(nowDate)) return timeago.format(date);

//     return DateFormat('HH:mm').format(date);
//   }

//   Widget _getAction(AppNotificationAction action) => CrystalButton(
//         configuration: const CrystalButtonConfiguration(
//           height: 32,
//           textSize: 14,
//           padding: EdgeInsets.symmetric(
//             horizontal: 16,
//           ),
//         ),
//         onTap: () {},
//         text: describeEnum(action).pascalCase,
//       );
// }
