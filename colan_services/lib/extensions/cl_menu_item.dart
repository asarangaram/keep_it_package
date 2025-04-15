import 'package:colan_widgets/colan_widgets.dart';

import 'package:pull_down_button/pull_down_button.dart';

extension MenuItemToUI on CLMenuItem {
  PullDownMenuItem get pullDownMenuItem {
    return PullDownMenuItem(
      onTap: onTap,
      enabled: onTap != null,
      title: title,
      icon: icon,
      //iconColor: Colors.red,
      //isDestructive: true,
    );
  }
}
