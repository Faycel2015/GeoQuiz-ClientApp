import 'package:app/env.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';


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
          leading: Icon(Icons.bug_report), 
          title: Text(Strings.menuBugReport), 
          onTap: () => handleBugReport(context),
        ),
      ],
    );
  }

  handleDonation(context) {
    showModalBottomSheet(
      context: context, 
      builder: (_) => DonationMenu()
    );
  }

  handleBugReport(context) async {
    final url = "mailto:$bugReportEmail.com?subject=$bugReportSubject&body=$bugReportBody";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class DonationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Good to see you here!",
          style: Theme.of(context).textTheme.headline2,
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            ListTile(
              leading: Text("🍵", style: TextStyle(fontSize: 30),),  
              title: Text("2\$"), 
              onTap: () => null
            ),
            ListTile(
              leading: Text("🍺", style: TextStyle(fontSize: 30),), 
              title: Text("5\$"), 
              onTap: () => null
            ),
            ListTile(
              leading: Text("🍕", style: TextStyle(fontSize: 30),), 
              title: Text("10\$"), 
              onTap: () => null
            ),
            ListTile(
              leading: Text("🥂", style: TextStyle(fontSize: 30),), 
              title: Text("50\$"), 
              onTap: () => null
            ),
            ListTile(
              leading: Text("⛷️", style: TextStyle(fontSize: 30),), 
              title: Text("100\$"), 
              onTap: () => null
            ),
            ListTile(
              leading: Text("🏝️", style: TextStyle(fontSize: 30),), 
              title: Text("1000\$"), 
              onTap: () => null
            ),
          ],
        ),
      ],
    );
  }
}