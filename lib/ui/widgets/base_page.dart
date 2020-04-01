import 'package:app/locator.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BasePage<T extends ChangeNotifier> extends StatefulWidget {
  ///
  BasePage({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final Function(BuildContext, T, Widget) builder;

  @override
  _BasePageState<T> createState() => _BasePageState<T>();
}

class _BasePageState<T extends ChangeNotifier> extends State<BasePage<T>> {
  T provider = Locator.of<T>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) => provider,
      child: Consumer<T>(
        builder: widget.builder,
      ),
    );
  }
}