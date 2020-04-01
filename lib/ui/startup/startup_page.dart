import 'package:app/ui/startup/startup_provider.dart';
import 'package:app/ui/widgets/geoquiz_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A page widget to dispaly information about the startup process
///
/// Depending on the [status] it will displayed either the [_StartUpLoadingWidget]
/// or the [_StartUpErrorWidget].
/// The [_StartUpLoadingWidget] will be displayed only is the status is equal
/// to [StartUpStatus.busy], all other status are considered like an error.
/// 
/// See also :
/// 
///  * [StartUpProvider], which handle the start up process and update the status
///  * [StartUpStatus], which is the enumeration of all possible status
class StartUpPage extends StatelessWidget {
  /// Create a widget that displays an indicator based on [status]
  StartUpPage({
    Key key, 
    @required this.status
  }) : super(key: key);
  
  /// Status used to display the correct widget
  final StartUpStatus status;

  Widget get _body { 
    switch (status) {
      case StartUpStatus.busy:
        return _StartUpLoadingWidget();
      case StartUpStatus.error:
      case StartUpStatus.idle:
      case StartUpStatus.loaded:
      default:
        return _StartUpErrorWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      color: Theme.of(context).primaryColor,
      body: _body
    );
  }
}

/// Widget that displays a loading indicator
class _StartUpLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading ..."),
    );
  }
}

/// Widget that dislays an error indicator
class _StartUpErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Error"),
    );
  }
}