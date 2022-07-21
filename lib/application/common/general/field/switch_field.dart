import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class EWSwitchField extends StatefulWidget {
  const EWSwitchField({
    required this.value,
    required this.onChanged,
    this.validator,
    Key? key,
  }) : super(key: key);

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
                    ? ColorsRes.lightBlue
                    : ColorsRes.blackBlueLight,
            thumbColor:
                widget.value ? ColorsRes.blackBlue : const Color.fromRGBO(197, 228, 243, 0.64),
            thumbSize: widget.value ? 24 : 16,
            borderColor: widget.value ? null : const Color.fromRGBO(197, 228, 243, 0.64),
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
    Key? key,
    this.width = 52,
    this.height = 32,
    this.borderColor,
  }) : super(key: key);

  final bool value;
  final Color thumbColor;
  final Color backgroundColor;
  final Color? borderColor;

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
        border: borderColor == null ? null : Border.all(color: borderColor!),
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
