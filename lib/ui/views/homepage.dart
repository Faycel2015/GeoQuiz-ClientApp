import 'package:app/logic/quiz_provider.dart';
import 'package:app/logic/themes_provider.dart';
import 'package:app/models/models.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/global_user_progress.dart';
import 'package:app/ui/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
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

      body: GradientBackground(
        color: Color(0xFF6127E8),
        child: ListView(
          children: <Widget>[
            GlobalUserProgressionWidget(),
            SelectableThemes(),
            DifficultyChooser(),
          ],
        ),
      ),
    );
  }
}


class SelectableThemes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemesProvider>(
      builder: (context, themeProvider, _) {
        if (themeProvider.themes != null)
          return Consumer<QuizProvider>(
            builder: (context, quizProvider, _) => GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX, vertical: Dimens.screenMarginY),
              children: themeProvider.themes.map((t) {
                bool isSelected = quizProvider.selectedThemes.contains(t);
                return ThemeCard(
                  theme: t,
                  color: isSelected ? Color(t.color) : Theme.of(context).colorScheme.surface,
                  onPressed: () => isSelected ? onDeselectTheme(context, t) : onSelectTheme(context, t),
                );
              }).toList()
            ),
          );
        if (themeProvider.error)
          return Text("error");
        return Text("Loading");
      }
    );
  }

  onSelectTheme(context, theme) {
    Provider.of<QuizProvider>(context, listen: false).addSelectedTheme(theme);
  }

  onDeselectTheme(context, theme) {
    Provider.of<QuizProvider>(context, listen: false).removeSelectedTheme(theme);
  }
}


class ThemeCard extends StatelessWidget {

  final QuizTheme theme;
  final Color color;
  final Function onPressed;

  ThemeCard({Key key, @required this.theme, @required this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimens.radius),
          boxShadow: [Dimens.shadow]
        ),
        child: Column(
          children: <Widget>[
            Text(theme.title),
            SvgPicture.string(theme.icon, height: 50,)
          ],
        ),
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