import 'package:ZY_Player_flutter/Collect/page/collect_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class CollectRouter implements IRouterProvider {
  static String collectPage = '/collect';

  @override
  void initRouter(Router router) {
    router.define(collectPage, handler: Handler(handlerFunc: (_, __) => CollectPage()));
  }
}
