import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme.dart';

enum CrystalButtonType {
  filled,
  outline,
  text,
}

class CrystalButtonConfiguration {
  final int _height;
  final Color? _highlightColor;
  final Color? _splashColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double textSize;
  final FontWeight textWeight;
  final EdgeInsets padding;

  const CrystalButtonConfiguration({
    int height = CrystalButton.kHeight,
    Color? highlightColor,
    Color? splashColor,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.textSize = 16,
    this.textWeight = FontWeight.w700,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  })  : _highlightColor = highlightColor,
        _splashColor = splashColor,
        _height = height;

  double get height => math.max(_height - padding.vertical, 0);

  Color? get splashColor => Platform.isIOS ? Colors.transparent : _splashColor?.withOpacity(0.2);

  Color? get highlightColor => _highlightColor?.withOpacity(Platform.isIOS ? 0.1 : 05);
}

class CrystalButton extends StatelessWidget {
  static const kHeight = 44;

  const CrystalButton({
    Key? key,
    required this.text,
    this.onTap,
    bool enabled = true,
    this.type = CrystalButtonType.filled,
    this.configuration = const CrystalButtonConfiguration(),
  })  : enabled = enabled && onTap != null,
        child = null,
        super(key: key);

  const CrystalButton.custom({
    Key? key,
    required this.child,
    this.onTap,
    bool enabled = true,
    this.type = CrystalButtonType.filled,
    this.configuration = const CrystalButtonConfiguration(),
  })  : enabled = enabled && onTap != null,
        text = null,
        super(key: key);

  final CrystalButtonType type;
  final CrystalButtonConfiguration configuration;
  final String? text;
  final Widget? child;
  final bool enabled;
  final VoidCallback? onTap;

  Color get highlightColor {
    if (Platform.isIOS || type == CrystalButtonType.text) {
      return CrystalColor.secondary.withOpacity(0.2);
    } else {
      return CrystalColor.secondary.withOpacity(0.05);
    }
  }

  Color get splashColor {
    if (Platform.isIOS || type == CrystalButtonType.text) {
      return Colors.transparent;
    } else {
      return CrystalColor.secondary.withOpacity(0.2);
    }
  }

  ShapeBorder? get shape {
    if (type == CrystalButtonType.outline) {
      return Border.all(color: CrystalColor.secondary);
    } else {
      return Border.all(width: 0, color: Colors.transparent);
    }
  }

  Color get backgroundColor {
    if (type == CrystalButtonType.filled) {
      return CrystalColor.accent;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get textColor {
    if (type != CrystalButtonType.filled) {
      return CrystalColor.accent;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get disabledBackgroundColor {
    if (type == CrystalButtonType.filled) {
      return CrystalColor.secondary;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get disabledTextColor {
    if (type != CrystalButtonType.filled) {
      return CrystalColor.secondary;
    } else {
      return CrystalColor.primary;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialButton(
        onPressed: enabled ? onTap : null,
        elevation: 0,
        disabledElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        mouseCursor: MouseCursor.defer,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: configuration.padding,
        height: configuration.height,
        shape: shape,
        minWidth: configuration.padding.horizontal,
        color: configuration.backgroundColor ?? backgroundColor,
        textColor: configuration.textColor ?? textColor,
        disabledColor: configuration.disabledBackgroundColor ?? disabledBackgroundColor,
        disabledTextColor: configuration.disabledTextColor ?? disabledTextColor,
        splashColor: configuration.splashColor ?? splashColor,
        highlightColor: configuration.highlightColor ?? highlightColor,
        hoverColor: CrystalColor.primary.withOpacity(0.05),
        focusColor: CrystalColor.primary.withOpacity(0.05),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: configuration.height,
          ),
          child: child ??
              Center(
                child: AutoSizeText(
                  text!,
                  maxLines: 1,
                  minFontSize: configuration.textSize - 4,
                  maxFontSize: configuration.textSize,
                  style: TextStyle(
                    fontSize: configuration.textSize,
                    fontWeight: configuration.textWeight,
                  ),
                ),
              ),
        ),
      );
}
