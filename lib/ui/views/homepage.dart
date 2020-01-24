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
      body: GradientBackground(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HomepageHeader(),
              GlobalUserProgressionWidget(),
              Expanded(
                child: Consumer<ThemesProvider>(
                  builder: (context, themesProvider, _) =>
                    themesProvider.themes != null
                    ? QuizConfiguration(themes: themesProvider.themes)
                    : Text("Loading...")
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomepageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.title;
    final subtitleSize = textStyle.fontSize * 0.5;
    return Padding(
      padding: Dimens.screenMargin,
      child: Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "Hi Romain,",
                style: textStyle,
                children: [TextSpan(
                  text: "\nTime to play !",
                  style: TextStyle(fontSize: subtitleSize),
                )]
              ),
            )
          ),
          
          Icon(Icons.menu, size: 30,)
        ],
      ),
    );
  }
}


class QuizConfiguration extends StatefulWidget {
  final List<QuizTheme> themes;

  QuizConfiguration({Key key, this.themes}) : super(key: key);

  @override
  _QuizConfigurationState createState() => _QuizConfigurationState();
}


class _QuizConfigurationState extends State<QuizConfiguration> {

  final formKey = GlobalKey<FormState>();
  var _selectedThemes = Set<QuizTheme>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Form(
          key: formKey,
          child: ListView(
            
            children: <Widget>[
              SelectableThemesForm(
                themes: widget.themes,
                validator: (selectedThemes) => selectedThemes.isEmpty ? "Cannot" : null,
                onSaved: (selectedThemes) => _selectedThemes = selectedThemes,
              ),
              DifficultyChooser(

              ),
            ],
          ),
        ),
        Positioned(
          bottom: Dimens.screenMarginY,
          right: Dimens.screenMarginX,
          child: FloatingActionButton.extended(
            label: Text("Let's go"),
            icon: Icon(Icons.chevron_right),
            onPressed: onSubmit,
          ),
        )
      ],
    );
  }

  onSubmit() {
    if (formKey.currentState.validate()) {
      print("validate");
      formKey.currentState.save();
      print(_selectedThemes);
    }
  }
}


class SelectableThemesForm extends FormField<Set<QuizTheme>> {
  SelectableThemesForm({
    Key key,
    @required List<QuizTheme> themes,
    FormFieldSetter<Set<QuizTheme>> onSaved,
    FormFieldValidator<Set<QuizTheme>> validator,
    Set<QuizTheme> initialValue,
    bool autovalidate = false,
  }) : super(
    key: key,
    onSaved: onSaved,
    validator: validator,
    initialValue: initialValue??{},
    autovalidate: autovalidate,
    builder: (FormFieldState<Set<QuizTheme>> state) => 
      GridView.count(
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        padding: Dimens.screenMargin,
        children: themes.map((t) => 
          InkResponse(
            onTap: () {
              if (!state.value.remove(t))
                state.value.add(t); 
              state.didChange(state.value);
            },
            child: ThemeCard(theme: t, selected: state.value.contains(t),)
          )
        ).toList(),
      )
  );
}


class ThemeCard extends StatelessWidget {

  final QuizTheme theme;
  final bool selected;

  ThemeCard({Key key, @required this.theme, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Dimens.surfacePadding),
        decoration: BoxDecoration(
          color: selected ? Color(theme.color) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(Dimens.radius),
          boxShadow: [Dimens.shadow]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(theme.title, style: TextStyle(color: Colors.black)),
            SvgPicture.string(theme.icon, height: 50, color: selected ? Colors.white : Color(theme.color))
          ],
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