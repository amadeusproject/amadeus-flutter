import 'package:flutter/material.dart';

import 'package:amadeus/cache/SubjectCacheController.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';

/// Created by Vitor Martins on 25/08/2018.

class CacheController {
  static void clearCache(BuildContext context) {
    SubjectCacheController.removeSubjectCache(context);
    TokenCacheController.removeTokenCache(context);
    UserCacheController.removeUserCache(context);
  }
}