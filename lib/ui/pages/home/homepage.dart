import 'package:app/logic/progression_provider.dart';
import 'package:app/logic/quiz_provider.dart';
import 'package:app/logic/themes_provider.dart';
import 'package:app/models/models.dart';
import 'package:app/models/progression.dart';
import 'package:app/ui/pages/home/menu.dart';
import 'package:app/ui/pages/quiz/quiz.dart';
import 'package:app/ui/shared/assets.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/widgets/button.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/geoquiz_layout.dart';
import 'package:app/ui/widgets/progress_bar.dart';
import 'package:app/ui/widgets/scroll_view_no_effect.dart';
import 'package:app/ui/widgets/surface_card.dart';
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
                Consumer<ThemesProvider>(
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
          Consumer<LocalProgressionProvider>(
            builder: (_, localProgression, __) => SelectableThemesForm(
              themes: widget.themes,
              progressions: localProgression.progressions,
              validator: (themes) => themes.isEmpty ? "" : null,
              onSaved: (themes) => selectedThemes = themes,
              padding: Dimens.screenMargin,
              spacing: Dimens.normalSpacing,
              label: Text(Strings.selectThemes),
              size: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
            ),
          ),
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
      )
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
class LaunchQuizButton extends StatefulWidget {

  final GlobalKey<QuizConfigurationState> quizForm;

  LaunchQuizButton({@required this.quizForm});

  @override
  _LaunchQuizButtonState createState() => _LaunchQuizButtonState();
}

class _LaunchQuizButtonState extends State<LaunchQuizButton> {

  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        return Button(
          label: inProgress ? Strings.loadingThemes : Strings.launchQuiz,
          icon: Icon(Icons.chevron_right),
          onPressed: inProgress ? null : _onSubmit,
        );
      }
    );
  }

  _onSubmit() async {
    var config = widget.quizForm.currentState.buildQuiConfiguration();
    if (config != null) {
      setState(() => inProgress = true);
      try {
        var quizProvider = Provider.of<QuizProvider>(context, listen: false);
        await quizProvider.prepareGame(config);
        _launchQuiz();
      } catch (_) {
        _handlePreparationError(_);
      }
      setState(() => inProgress = false);
    }
  }

  _launchQuiz() {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => QuizPage()
      ));
    }
  }

  _handlePreparationError(_) {
    showSnackbar(
      context: context,
      critical: true,
      content: Text(Strings.quizPreparationError)
    );
  }
}



/// [FormField] to let user select themes
///
/// The built widget is a [GridView] that containes the [themes]. Each theme 
/// item is a [ThemeCard].
/// 
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
/// 
/// So to retrieve the selected themes, the recommended way is to have a [Form]
/// and when you saved the form, the selected themes can be retreived through
/// the [onSaved] function.
class SelectableThemesForm extends FormField<Set<QuizTheme>> {
  
  SelectableThemesForm({
    Key key,
    @required List<QuizTheme> themes,
    Map<QuizTheme, QuizThemeProgression> progressions,
    FormFieldSetter<Set<QuizTheme>> onSaved,
    FormFieldValidator<Set<QuizTheme>> validator,
    Set<QuizTheme> initialValue,
    bool autovalidate = false,
    EdgeInsets padding,
    double spacing = 0,
    Widget label,
    int size = 2
  }) : super(
    key: key,
    onSaved: onSaved,
    validator: validator,
    initialValue: initialValue??{},
    autovalidate: autovalidate,
    builder: (state) => 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label != null)
            Padding(
              padding: padding.copyWith(top: 0, bottom: 0),
              child: label,
            ),
          GridView.count(
            shrinkWrap: true,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            crossAxisCount: size,
            padding: padding,
            primary: false,
            children: themes.map((t) => 
              ThemeCard(
                theme: t, 
                progression: progressions == null || !progressions.containsKey(t) ? null : progressions[t],
                selected: state.value.contains(t),
                onSelect: () {
                  if (!state.value.remove(t))
                    state.value.add(t); 
                  state.didChange(state.value);
                }
              )
            ).toList(),
          ),
        ],
      )
  );
}



/// Use to represents a [QuizTheme] element.
/// 
/// It displays the [QuizTheme.title] and the [QuizTheme.icon] in a 
/// [Container].
/// 
/// Colors depends on the [selected] flag value. If it set to true the colors
/// will be :
/// - the backgrund color : [QuizTheme.color]
/// - the text color : white
/// - the icon color : white
/// Else, 
/// - the backgrund color : [Theme.of(context).colorScheme.surface]
/// - the text color : [Theme.of(context).colorScheme.onSurface]
/// - the icon color : [QuizTheme.color]
class ThemeCard extends StatelessWidget {

  final QuizTheme theme;
  final bool selected;
  final Function onSelect;
  final QuizThemeProgression progression;

  ThemeCard({
    Key key,
    @required this.theme, 
    this.progression,
    this.onSelect,
    this.selected = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = selected ? Colors.white : colorScheme.onSurface;
    final backColor = selected ? Color(theme.color) : colorScheme.surface;
    final iconColor = selected ? Colors.white : Color(theme.color);
    return SurfaceCard(
      color: backColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ProgressBar(
            percentage: progression?.percentage??0,
            color: iconColor
          ),
          FlexSpacer.small(),
          Text(
            theme.title, 
            overflow: TextOverflow.fade,
            softWrap: false, // to not wrapped line and so apply the TextOverflow.fade
            style: Theme.of(context).textTheme.subtitle2.apply(color: textColor)
          ),
          Expanded(child: Container()),
          SvgPicture.string(
            theme.icon, 
            height: 40, 
            color: iconColor
          )
        ],
      ),
      onPressed: onSelect,
    );
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