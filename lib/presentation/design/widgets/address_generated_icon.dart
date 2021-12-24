import 'package:flutter/material.dart';

class AddressGeneratedIcon extends StatelessWidget {
  final String address;

  const AddressGeneratedIcon({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox.square(
          dimension: 36,
          child: CustomPaint(
            painter: _AvatarPainter(
              address,
            ),
          ),
        ),
      );
}

class _AvatarPainter extends CustomPainter {
  final String address;

  _AvatarPainter(this.address);

  @override
  void paint(Canvas canvas, Size size) {
    final hash = address.split(':').last;

    final colors = List.generate(
      16,
      (index) =>
          '#${hash[0]}${hash[index * 4]}${hash[index * 4 + 1]}${hash[index * 4 + 2]}${hash[63]}${hash[index * 4 + 3]}',
    );

    canvas.drawCircle(
      const Offset(3, 3),
      7,
      Paint()..color = colors[0].toColor(),
    );
    canvas.drawCircle(
      const Offset(3, 13),
      7,
      Paint()..color = colors[4].toColor(),
    );
    canvas.drawCircle(
      const Offset(3, 23),
      7,
      Paint()..color = colors[8].toColor(),
    );
    canvas.drawCircle(
      const Offset(3, 33),
      7,
      Paint()..color = colors[12].toColor(),
    );
    canvas.drawCircle(
      const Offset(13, 3),
      7,
      Paint()..color = colors[1].toColor(),
    );
    canvas.drawCircle(
      const Offset(13, 13),
      7,
      Paint()..color = colors[5].toColor(),
    );
    canvas.drawCircle(
      const Offset(13, 23),
      7,
      Paint()..color = colors[9].toColor(),
    );
    canvas.drawCircle(
      const Offset(13, 33),
      7,
      Paint()..color = colors[13].toColor(),
    );
    canvas.drawCircle(
      const Offset(23, 3),
      7,
      Paint()..color = colors[2].toColor(),
    );
    canvas.drawCircle(
      const Offset(23, 13),
      7,
      Paint()..color = colors[6].toColor(),
    );
    canvas.drawCircle(
      const Offset(23, 23),
      7,
      Paint()..color = colors[10].toColor(),
    );
    canvas.drawCircle(
      const Offset(23, 33),
      7,
      Paint()..color = colors[14].toColor(),
    );
    canvas.drawCircle(
      const Offset(33, 3),
      7,
      Paint()..color = colors[3].toColor(),
    );
    canvas.drawCircle(
      const Offset(33, 13),
      7,
      Paint()..color = colors[7].toColor(),
    );
    canvas.drawCircle(
      const Offset(33, 23),
      7,
      Paint()..color = colors[11].toColor(),
    );
    canvas.drawCircle(
      const Offset(33, 33),
      7,
      Paint()..color = colors[15].toColor(),
    );
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) => false;
}

extension on String {
  Color toColor() {
    var hexColor = replaceAll('#', '');

    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    }

    throw Exception();
  }
}
