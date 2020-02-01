import 'package:app/ui/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// The menu of the app (contains clickable elements)
///
/// It is a shrink [ListView] with menu items :
/// - Donation (in-app purchase)
/// - Reset data (clear local storage)
/// - Report a bug (open the email app of the user)
/// 
/// Each of this item have a corresponding handler method to handle what to do 
/// when the user click on an item.
class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.local_drink), 
          title: Text(Strings.menuDonation), 
          onTap: () => handleDonation(context)
        ),
        ListTile(
          leading: Icon(Icons.delete_forever), 
          title: Text(Strings.menuResetData), 
          onTap: () => handleResetData(context),
        ),
        ListTile(
          leading: Icon(Icons.bug_report), 
          title: Text(Strings.menuBugReport), 
          onTap: () => handleBugReport(context),
        ),
      ],
    );
  }

  handleDonation(context) {

  }

  handleResetData(context) {

  }

  handleBugReport(context) {

  }
}