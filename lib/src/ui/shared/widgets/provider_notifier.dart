import 'package:app/src/locator.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ProviderNotifier<T extends ChangeNotifier> extends StatefulWidget {
  ///
  ProviderNotifier({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final Function(BuildContext, T, Widget) builder;

  @override
  _ProviderNotifierState<T> createState() => _ProviderNotifierState<T>();
}

class _ProviderNotifierState<T extends ChangeNotifier> extends State<ProviderNotifier<T>> {
  T provider = Locator.of<T>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: provider,
      child: Consumer<T>(
        builder: widget.builder,
      ),
    );
  }
}