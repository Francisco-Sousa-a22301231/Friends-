import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'permission_provider.dart';
import 'contact_provider.dart';

/// Central list of all app-wide providers.
class AppProviders {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ];
}
