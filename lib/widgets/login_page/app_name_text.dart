import 'package:flutter/material.dart';

class AppNameText extends StatelessWidget {
  const AppNameText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('TYT AYT Cep Notları',
        style: Theme.of(context)
            .textTheme
            .headline4
            ?.copyWith(color: Colors.black));
  }
}
