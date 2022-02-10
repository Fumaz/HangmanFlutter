import 'package:flutter/cupertino.dart';

import 'HangmanPage.dart';

class HangmanApp extends StatelessWidget {

  const HangmanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Hangman',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink,
      ),
      home: HangmanPage(),
    );
  }

}