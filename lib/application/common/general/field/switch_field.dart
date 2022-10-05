import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class EWSwitchField extends StatefulWidget {
  const EWSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final FormFieldValidator<bool>? validator;

  @override
  State<EWSwitchField> createState() => _EWSwitchFieldState();
}

class _EWSwitchFieldState extends State<EWSwitchField> {
  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      validator: widget.validator,
      builder: (state) {
        return GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: EWSwitcher(
            value: widget.value,
            backgroundColor: state.hasError
                ? ColorsRes.redLight
                : widget.value
                    ? ColorsRes.green400
                    : ColorsRes.blackBlueLight,
            thumbColor: ColorsRes.white,
            thumbSize: widget.value ? 24 : 16,
          ),
        );
      },
    );
  }
}

class EWSwitcher extends StatelessWidget {
  const EWSwitcher({
    required this.value,
    required this.thumbColor,
    required this.backgroundColor,
    required this.thumbSize,
    super.key,
    this.width = 52,
    this.height = 32,
  });

  final bool value;
  final Color thumbColor;
  final Color backgroundColor;

  final double width;
  final double height;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: value ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: kThemeAnimationDuration,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          width: thumbSize,
          height: thumbSize,
          decoration: BoxDecoration(
            color: thumbColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
