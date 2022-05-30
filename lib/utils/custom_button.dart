import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color color;
  final textColor;
  final BorderRadius borderRadius;
  final IconData icon;
  final double size;

  CustomButton({
    this.onTap,
    this.text,
    this.color,
    this.textColor,
    this.borderRadius,
    this.icon,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return icon != null
        ? TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              ),
              backgroundColor: color ?? theme.primaryColor,
            ),
            onPressed: onTap as void Function() ?? () {},
            icon: Icon(
              icon,
              color: textColor ?? theme.scaffoldBackgroundColor,
              size: size,
            ),
            label: Text(
              text != null
                  ? text.toUpperCase()
                  : Strings.CONTINUE.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.button
                  .copyWith(color: textColor ?? theme.scaffoldBackgroundColor),
            ),
          )
        : TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              ),
              backgroundColor: color ?? theme.primaryColor,
            ),
            onPressed: onTap as void Function() ?? () {},
            child: Text(
              text != null
                  ? text.toUpperCase()
                  : Strings.CONTINUE.toUpperCase(),
              style: theme.textTheme.button
                  .copyWith(color: textColor ?? theme.scaffoldBackgroundColor),
            ),
          );
  }
}
