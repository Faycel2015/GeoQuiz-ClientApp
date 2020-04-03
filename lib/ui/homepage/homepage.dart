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

/// Page that displays the homepage which contains widgets to launch a game.
/// 
/// It displays two important widgets :
///   * [QuizConfiguration], which is a widget to select the game configuration.
///   * [LaunchQuizButton], which is a widget to launch the [QuizPage] with
///     a [QuizConfig] object retrieved from the [QuizConfiguration] widget.
/// 
/// It is a StatefulWidget to keep the [quizConfigurationKey] even after rebuild,
/// this is the key of the [QuizConfiguration]. Thanks to this key the 
/// [LaunchQuizButton] widget will be able to retrieve the quiz configuration
/// when the user will tap on the button to launch the game.
/// 
/// The navigation to the homepage can be achieved by using the routing named
/// navigation :
/// 
/// ```dart
/// Navigator.of(context).pushNamed(HomePage.routeName);
/// ```
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  /// Name of the root used to navigate to the [HomePage].
  static const routeName = "/homepage";
}

class _HomePageState extends State<HomePage> {
  /// Key for the [QuizConfiguration] to retrieve the quiz configation.
  /// 
  /// {@tool sample}
  /// Retrieve the [QuizConfig].
  /// 
  /// ```dart
  /// QuizConfig config = quizConfigurationKey.currentState.buildQuizConfig();
  /// bool isValidConfig = (config != null);
  /// ```
  /// {@end-tool}
  final quizConfigurationKey = GlobalKey<QuizConfigurationState>();

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
                          key: quizConfigurationKey,
                          themes: themesProvider.themes
                        )
                ),
              ],
            ),
          ),
          Positioned(
            bottom: Dimens.screenMarginY,
            right: Dimens.screenMarginX,
            child: LaunchQuizButton(quizFormKey: quizConfigurationKey)
          )
        ]
      )
    );
  }
}

/// Header for the [HomePage] with the title and an icon to open the menu.
///
/// It's a [Row] with the homepage title on the left and the icon on the right.
/// The title take the maximum size available (so all width minus the icon
/// size). 
/// 
/// The menu app open the [AppMenu] in a modal bottom sheet.
/// 
/// See also :
/// 
///  * [AppMenu], which is the menu of the application.
///  * [HomePage], which is the widget that uses this widget.
///  * [showModalBottomSheet()], function to display a widget in a modal bottom
///    sheet.
class HomepageHeader extends StatelessWidget {
  _openMenu(context) {
    showModalBottomSheet(context: context, builder: (context) => AppMenu());
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline1;
    final subtitleSize = textStyle.fontSize * 0.5;
    return  Row(
      children: <Widget>[
        Expanded(
          child: DefaultTextStyle(
            style: textStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(Strings.homepageTitle),
                Text(Strings.homepageSubtitle, style: TextStyle(fontSize: subtitleSize)),
              ]
            ),
          )
        ),
        Material( // to provide a surface to trigger the ripple animation
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(),
          color: Colors.transparent,
          child: IconButton(
            onPressed: () => _openMenu(context),
            icon: SvgPicture.asset(
              Assets.menu,
              height: Dimens.menuIconSize,
              color: textStyle.color,
            ),
          ),
        )
      ],
    );
  }
}

/// Widget to build a [QuizConfig].
/// 
/// The [QuizConfig] is generated based on two widgets :
///  * [ThemesChooser], which is a widget to select a subset of [themes].
///  * [DifficultyChooser], which is a widget to generate a [DifficultyConfig].
/// 
/// The generated [QuizConfig] can be retrieved thanks to the
/// [QuizConfigurationState.buildQuizConfig] method. To use this method
/// it is necessary to give a Key to construct this widget. The key will 
/// provide access to the associated [QuizConfigurationState].
/// 
/// {@tool sample}
/// Example to retrieve the configuration outside this widget.
/// 
/// ```dart
/// final quizConfigurationKey = GlobalKey<QuizConfigurationState>();
/// ...
/// QuizConfiguration(
///   key: quizConfigurationKey,
///   ...
/// )
/// ...
/// QuizConfig config = quizConfigurationKey.currentState.buildQuizConfig();
/// bool isValid = (config != null);
/// ```
/// {@end-tool}
class QuizConfiguration extends StatefulWidget {
  /// Create the widget with the [themes] list to let the user choose which ones
  /// he wants.
  QuizConfiguration({
    Key key, 
    @required this.themes
  }) : super(key: key);

  /// The list of [QuizThemes] from which the user can choose.
  final List<QuizTheme> themes;

  @override
  QuizConfigurationState createState() => QuizConfigurationState();
}

class QuizConfigurationState extends State<QuizConfiguration> {
  /// Key used to provide access to the [FormState] of the [Form] widget that
  /// wraps our two fields :
  ///  * [ThemesChooser] to select themes.
  ///  * [DifficultyChooser] to select a diffculty.
  /// Used to save, reset or validate [FormField] contained in these widgets.
  final _formKey = GlobalKey<FormState>();
  
  /// The current selected themes.
  /// Call [_formKey.currentState.save()] to get a version updated.
  var _selectedThemes = Set<QuizTheme>();

  /// The current selected difficulty.
  /// Call [_formKey.currentState.save()] to get a version updated.
  var _difficulty = DifficultyConfig(automatic: true);

  /// Return the [QuizConfig] generated from the form used to select themes and
  /// difficulty.
  /// 
  /// If the form is not valid, null is returned.
  /// 
  /// See the code sample in the class-level documentation.
  QuizConfig buildQuizConfig() {
    QuizConfig quizConfig;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      quizConfig = QuizConfig(
        themes: _selectedThemes,
        difficultyData: _difficulty,
      );
    }
    return quizConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          ThemesChooser(
            onChanged: (themes) => _selectedThemes = themes,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX),
            child: DifficultyChooser(
              initial: _difficulty,
              onSaved: (newDifficulty) => _difficulty = newDifficulty,
            )
          )
        ],
      )
    );
  }
}

/// Button to launch the [QuizPage] widget with a [QuizConfig].
///
/// On the user click, the widget will retrieve the [QuizConfig] generated
/// by the [QuizConfiguration] thaaks to the [quizFormKey] that provides an
/// access to the [QuizConfigurationState], and so to the 
/// [QuizConfigurationState.buildQuizConfig()] method.
/// 
/// If the generated [QuizConfig] is valid (i.e. not null), the [QuizPage] screen
/// will be launched. Else, a snackbar will be displayed with the error
/// indication.
class LaunchQuizButton extends StatelessWidget {
  /// Create the widget with the [quizFormKey] used to retrieve the [QuizConifg]
  LaunchQuizButton({
    Key key,
    @required this.quizFormKey
  }) : super(key: key);

  /// Key used to get the generated [QuizConfig] built by the [QuizConfiguration]
  /// widget
  final GlobalKey<QuizConfigurationState> quizFormKey;

  /// Retrieve the [QuizConfig], if it is valid (i.e. not null), it launches the
  /// [QuizPage] screen with this quiz config.
  void _onSubmit(BuildContext context) async {
    final config = quizFormKey.currentState.buildQuizConfig();
    if (config != null) {
      Navigator.pushNamed(context, QuizPage.routeName, arguments: config);
    } else {
      showSnackbar(context: context, content: Text(Strings.quizConfigurationInvalid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      label: Strings.launchQuiz,
      icon: Icon(Icons.chevron_right),
      onPressed: () => _onSubmit(context),
    );
  }
}

/// [FormField] widget used to generate a [DiffcultyConfig] object
///
/// {@tool sample}
/// Usage to generate a [DifficultyConfig] object
/// 
/// ```dart
/// DifficultyChooser(
///   onSaved: (DifficultyConfig difficulty) => print(difficulty.difficultyChose),
/// )
/// ```
/// {@end-tool}
class DifficultyChooser extends FormField<DifficultyConfig> {
  ///
  DifficultyChooser({
    Key key,
    DifficultyConfig initial,
    void Function(DifficultyConfig) onSaved
  }) : super(
    key: key,
    onSaved: onSaved,
    initialValue: initial,
    builder: (state) {
      final value = state.value;
      final beginnerEmoji = "👶";
      final expertEmoji = "🦸‍♂️";
      final emojiStyle = TextStyle(fontSize: 25);
      return Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            borderRadius: Dimens.borderRadius,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                final newValue = DifficultyConfig(
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
          ),
          if (!value.automatic)
            Row(
              children: <Widget>[
                Text(beginnerEmoji, style: emojiStyle),
                Expanded(
                  child: Slider(
                    min: DifficultyConfig.min.toDouble(),
                    max: DifficultyConfig.max.toDouble(),
                    value: value.difficultyChose.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.2),
                    onChanged: (a) {
                      final newValue = DifficultyConfig(
                        automatic: value.automatic,
                        difficultyChose: a.round()
                      );
                      state.didChange(newValue);
                    },
                  ),
                ),
                Text(expertEmoji, style: emojiStyle),
              ],
            ),
        ],
      );
    }
  );
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