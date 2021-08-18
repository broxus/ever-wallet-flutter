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
  const CrystalButtonConfiguration({
    double height = CrystalButton.kHeight,
    Color? highlightColor,
    Color? splashColor,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.textSize = 16.0,
    this.textWeight = FontWeight.w700,
    this.padding = const EdgeInsets.symmetric(horizontal: 18.0),
  })  : _highlightColor = highlightColor,
        _splashColor = splashColor,
        _height = height;

  double get height => math.max(_height - padding.vertical, 0);

  Color? get splashColor => Platform.isIOS ? Colors.transparent : _splashColor?.withOpacity(0.2);
  Color? get highlightColor => _highlightColor?.withOpacity(Platform.isIOS ? 0.1 : 0.05);

  final double _height;

  final Color? _highlightColor;
  final Color? _splashColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;

  final double textSize;
  final FontWeight textWeight;
  final EdgeInsets padding;
}

class CrystalButton extends StatelessWidget {
  static const kHeight = 44.0;

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

  @override
  Widget build(BuildContext context) => MaterialButton(
        onPressed: enabled ? onTap : null,
        elevation: 0.0,
        disabledElevation: 0.0,
        focusElevation: 0.0,
        highlightElevation: 0.0,
        hoverElevation: 0.0,
        mouseCursor: MouseCursor.defer,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: configuration.padding,
        height: configuration.height,
        shape: _shape,
        minWidth: configuration.padding.horizontal,
        color: configuration.backgroundColor ?? _backgroundColor,
        textColor: configuration.textColor ?? _textColor,
        disabledColor: configuration.disabledBackgroundColor ?? _disabledBackgroundColor,
        disabledTextColor: configuration.disabledTextColor ?? _disabledTextColor,
        splashColor: configuration.splashColor ?? _splashColor,
        highlightColor: configuration.highlightColor ?? _highlightColor,
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

  Color get _highlightColor {
    if (Platform.isIOS || type == CrystalButtonType.text) {
      return CrystalColor.secondary.withOpacity(0.2);
    } else {
      return CrystalColor.secondary.withOpacity(0.05);
    }
  }

  Color get _splashColor {
    if (Platform.isIOS || type == CrystalButtonType.text) {
      return Colors.transparent;
    } else {
      return CrystalColor.secondary.withOpacity(0.2);
    }
  }

  ShapeBorder? get _shape {
    if (type == CrystalButtonType.outline) {
      return Border.all(color: CrystalColor.secondary);
    } else {
      return Border.all(width: 0, color: Colors.transparent);
    }
  }

  Color get _backgroundColor {
    if (type == CrystalButtonType.filled) {
      return CrystalColor.accent;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get _textColor {
    if (type != CrystalButtonType.filled) {
      return CrystalColor.accent;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get _disabledBackgroundColor {
    if (type == CrystalButtonType.filled) {
      return CrystalColor.secondary;
    } else {
      return CrystalColor.primary;
    }
  }

  Color get _disabledTextColor {
    if (type != CrystalButtonType.filled) {
      return CrystalColor.secondary;
    } else {
      return CrystalColor.primary;
    }
  }
}
