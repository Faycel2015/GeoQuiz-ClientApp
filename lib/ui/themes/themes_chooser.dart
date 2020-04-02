import 'package:app/models/models.dart';
import 'package:app/ui/shared/res/dimens.dart';
import 'package:app/ui/shared/res/strings.dart';
import 'package:app/ui/shared/widgets/flex_spacer.dart';
import 'package:app/ui/shared/widgets/progress_bar.dart';
import 'package:app/ui/shared/widgets/provider_notifier.dart';
import 'package:app/ui/shared/widgets/surface_card.dart';
import 'package:app/ui/themes/themes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

/// sample : Form
///
///
class ThemesChooser extends StatelessWidget {
  ///
  ThemesChooser({
    Key key,
    this.onChanged
  }) : super(key: key);

  ///
  final void Function(Set<QuizTheme>) onChanged;

  @override
  Widget build(BuildContext context) {
    return ProviderNotifier<ThemesProvider>(
      builder: (_, themesProvider, __) => SelectableThemesForm(
        themes: themesProvider.themes,
        validator: (themes) => themes.isEmpty ? "" : null,
        onSaved: (themes) {
          if (onChanged != null)
            onChanged(themes);
        },
        padding: Dimens.screenMargin,
        spacing: Dimens.normalSpacing,
        label: Text(Strings.selectThemes),
        size: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
      ),
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
    FormFieldSetter<Set<QuizTheme>> onSaved,
    FormFieldValidator<Set<QuizTheme>> validator,
    Set<QuizTheme> initialValue,
    bool autovalidate = true,
    EdgeInsets padding,
    double spacing = 0,
    Widget label,
    int size = 2,
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

  ThemeCard({
    Key key,
    @required this.theme, 
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
            percentage: theme.progression?.percentage??0,
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