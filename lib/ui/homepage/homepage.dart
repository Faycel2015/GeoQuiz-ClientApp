import 'package:app/models/models.dart';
import 'package:app/ui/homepage/menu.dart';
import 'package:app/ui/quiz/quiz.dart';
import 'package:app/ui/quiz/quiz_provider.dart';
import 'package:app/ui/shared/res/assets.dart';
import 'package:app/ui/shared/res/dimens.dart';
import 'package:app/ui/shared/res/strings.dart';
import 'package:app/ui/shared/widgets/button.dart';
import 'package:app/ui/shared/widgets/flex_spacer.dart';
import 'package:app/ui/shared/widgets/geoquiz_layout.dart';
import 'package:app/ui/shared/widgets/provider_notifier.dart';
import 'package:app/ui/shared/widgets/scroll_view_no_effect.dart';
import 'package:app/ui/themes/themes_chooser.dart';
import 'package:app/ui/themes/themes_provider.dart';
import 'package:app/utils/snackbar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


/// Main widget for the homepage screen that contains the quiz configuration to
/// launch a game
/// 
/// It's a [Scaffold] with ony a body. The body has 2 elements in a [Column] :
/// - The [HomepageHeader] (the header)
/// - The [QuizConfiguration] to launch a game (with custom settings)
/// 
/// Note: is the [ThemesProvider] is not yet initialized, the [_LoadingData] 
/// widget will be displayed.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  ///
  static const routeName = "/homepage";
}

class _HomePageState extends State<HomePage> {

  var quizForm = GlobalKey<QuizConfigurationState>();

  @override
  Widget build(BuildContext context) {
    return AppLayout( 
      body: Stack(
        children: <Widget>[
          ScrollViewNoEffect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: Dimens.screenMargin,
                  child:  HomepageHeader(),
                ),
                ProviderNotifier<ThemesProvider>(
                  builder: (context, themesProvider, _) =>
                    themesProvider.state == ThemeProviderState.not_init
                      ? _LoadingData()
                      : QuizConfiguration(
                          key: quizForm,
                          themes: themesProvider.themes
                        )
                ),
              ],
            ),
          ),
          Positioned(
            bottom: Dimens.screenMarginY,
            right: Dimens.screenMarginX,
            child: LaunchQuizButton(quizForm: quizForm)
          )
        ]
      )
    );
  }
}



/// Simple widget to indicate loading status
class _LoadingData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(Strings.loadingThemes)
    );
  }
}



/// Header of the homepage with a title and an icon to open the menu
///
/// It's a [Row] with the homepage title on the right and the icon on the left.
/// The title take the maximum size available (so all width minus the icon
/// size). 
/// The icon trigger the menu on the user click.
class HomepageHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline1;
    final subtitleSize = textStyle.fontSize * 0.5;
    return  Row(
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              text: Strings.homepageTitle,
              style: textStyle,
              children: [TextSpan(
                text: "\n" + Strings.homepageSubtitle,
                style: TextStyle(fontSize: subtitleSize),
              )]
            ),
          )
        ),
        
        InkWell(
          onTap: () => _openMenu(context),
          child: SvgPicture.asset(
            Assets.menu,
            height: 34,
            color: textStyle.color,
          ),
        )
      ],
    );
  }

  _openMenu(context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) => AppMenu()
    );
  }
}



/// Widget to cconfigure and launch a quiz game
/// 
/// This widgets display the [themes] in a [SelectableThemesForm] to let the
/// user choose his themes.
/// 
/// There is also a button to launch the game when the user wants to.
/// When the user clicks on this button, the game is prepared and then launch.
/// 
/// Is an unexcepted scenario occured the user is notified with a snackbar.
/// There are 2 possible scenarios :
/// - if the try to launch a game without selected themes (non critical)
/// - if an error occured while the game preparation (critical)
class QuizConfiguration extends StatefulWidget {

  final List<QuizTheme> themes;

  QuizConfiguration({Key key, @required this.themes}) : super(key: key);

  @override
  QuizConfigurationState createState() => QuizConfigurationState();
}

class QuizConfigurationState extends State<QuizConfiguration> {

  final _formKey = GlobalKey<FormState>();
  var selectedThemes = Set<QuizTheme>();
  var difficulty = DifficultyData(automatic: true);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          ThemesChooser(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX),
            child: DifficultyChooser(
              initial: difficulty,
              onSaved: (newDifficulty) => difficulty = newDifficulty,
            )
          )
        ],
      )
    );
  }

  QuizConfig buildQuiConfiguration() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return QuizConfig(
        themes: selectedThemes,
        difficultyData: difficulty,
      );
    } else {
      _handleInvalidForm();
      return null;
    }
  }

  _handleInvalidForm() {
    showSnackbar(
      context: context,
      content: Text(Strings.quizConfigurationInvalid),
    );
  }
}



/// Button to launch a game
///
/// Depending on the state of the [QuizProvider] this button will be enable
/// or not :
/// - if the state is [QuizProviderState.IN_PROGRESS] the button will be
///   diasble and a loading message will be dispalyed
/// - else the button will be enable.
class LaunchQuizButton extends StatelessWidget {

  final GlobalKey<QuizConfigurationState> quizForm;

  LaunchQuizButton({@required this.quizForm});

  @override
  Widget build(BuildContext context) {
    return ProviderNotifier<QuizProvider>(
      builder: (context, quizProvider, _) {
        return Button(
          label: Strings.launchQuiz,
          icon: Icon(Icons.chevron_right),
          onPressed: () => onSubmit(context),
        );
      }
    );
  }

  void onSubmit(BuildContext context) async {
    var config = quizForm.currentState.buildQuiConfiguration();
    if (config != null) {
      Navigator.pushNamed(context, QuizPage.routeName);
    }
  }
}











///
///
class DifficultyChooser extends FormField<DifficultyData> {

  final void Function(DifficultyData) onSaved;
  final DifficultyData initial;

  DifficultyChooser({
    Key key,
    @required this.initial,
    @required this.onSaved
  }) : super(
    key: key,
    onSaved: onSaved,
    initialValue: initial,
    builder: (state) {
      var value = state.value;
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              var newValue = DifficultyData(
                automatic: !value.automatic,
                difficultyChose: value.difficultyChose
              );
              state.didChange(newValue);
            },
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: Dimens.borderRadius
                  ),
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: value.automatic ? Icon(Icons.check) : Container()
                  ),
                ),
                FlexSpacer.small(),
                Text(Strings.difficultyAutomaticLabel)
              ]
            ),
          ),
          if (!value.automatic)
            Row(
              children: <Widget>[
                Text("👶", style: TextStyle(fontSize: 25)),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: value.difficultyChose.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.2),
                    onChanged: (a) {
                      var newValue = DifficultyData(
                        automatic: value.automatic,
                        difficultyChose: a.round()
                      );
                      state.didChange(newValue);
                    },
                  ),
                ),
                Text("🦸‍♂️", style: TextStyle(fontSize: 25)), 
              ],
            ),
        ],
      );
    }
  );
}


class DifficultyData {
  bool _automatic = true;
  bool get automatic => _automatic??true;
  set automatic(b) => _automatic = b;
  int _difficultyChose;
  int get difficultyChose => _difficultyChose??0;
  set difficultyChose(v) => _difficultyChose = v;
  DifficultyData({
    bool automatic, 
    int difficultyChose
  }) : _automatic = automatic,
       _difficultyChose = difficultyChose;
}