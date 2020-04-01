import 'package:app/themes/themes_provider.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/progress_bar.dart';
import 'package:app/ui/widgets/provider_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class ThemesProgressList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderNotifier<ThemesProvider>(
      builder: (_, themesProvider, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Dimens.borderRadius
        ),
        padding: EdgeInsets.all(Dimens.surfacePadding),
        child: LayoutBuilder(
          builder: (_, constraints) => Wrap(
              spacing: Dimens.normalSpacing,
              direction: Axis.vertical,
              children: themesProvider.themes.map((theme) => 
                SizedBox(
                  width: constraints.maxWidth,
                  child: Row(
                    children: <Widget>[
                      SvgPicture.string(
                        theme.icon, 
                        height: 35, 
                        color: Color(theme.color)
                      ),
                      FlexSpacer.small(),
                      Expanded(
                        child: ProgressBar(
                          percentage: theme.progression.percentage,
                          color: Color(theme.color),
                        ),
                      ),
                    ],
                  )
                )
              ).toList(),
            ),
          ),
      ),
    );
  }
}

