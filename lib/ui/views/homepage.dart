import 'package:app/logic/themes_provider.dart';
import 'package:app/ui/widgets/global_user_progress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return LimitedBox(
      maxHeight: 500,
          child: Consumer<ThemesProvider>(
        builder: (context, provider, _) {
          if (provider.themes != null)
            return GridView.count(
              crossAxisCount: 2,
              children: provider.themes.map((t) => Text(t.title)).toList()
            );
          if (provider.error)
            return Text("error");
          return Text("Loading");
        }
      ),
    );
  }
}

class DifficultyChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("difficulty chooser");
  }
}