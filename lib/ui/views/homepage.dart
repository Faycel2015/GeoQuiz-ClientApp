import 'package:app/ui/widgets/global_user_progress.dart';
import 'package:flutter/material.dart';

class HomepageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Let's go"),
        icon: Icon(Icons.chevron_right),
        onPressed: () {},
      ),

      body: ListView(
        children: <Widget>[
          GlobalUserProgressionWidget(),
          SelectableThemes(),
          DifficultyChooser(),
        ],
      ),
    );
  }
}


class SelectableThemes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("seletable themes");
  }
}

class DifficultyChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("difficulty chooser");
  }
}