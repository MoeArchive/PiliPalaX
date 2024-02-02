import '../models/msg/account.dart';
import '../models/msg/session.dart';
import '../utils/wbi_sign.dart';
import 'api.dart';
import 'init.dart';

class MsgHttp {

  static Future msgFeedReplyMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedReply, data: {
      'id': cursor == -1 ? null : cursor,
      'reply_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  static Future msgFeedAtMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedAt,data: {
      'id': cursor == -1 ? null : cursor,
      'at_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  static Future msgFeedLikeMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedLike,data: {
      'id': cursor == -1 ? null : cursor,
      'like_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  static Future msgFeedSysUserNotify() async {
    String csrf = await Request.getCsrf();
    var res = await Request().get(Api.msgSysUserNotify, data: {
      'csrf': csrf,
      'csrf': csrf,
      'page_size': 20,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  static Future msgFeedSysUnifiedNotify() async {
    String csrf = await Request.getCsrf();
    var res = await Request().get(Api.msgSysUnifiedNotify, data: {
      'csrf': csrf,
      'csrf': csrf,
      'page_size': 10,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  static Future msgFeedUnread() async {
    var res = await Request().get(Api.msgFeedUnread);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
  // 会话列表
  static Future sessionList({int? endTs}) async {
    Map<String, dynamic> params = {
      'session_type': 1,
      'group_fold': 1,
      'unfollow_fold': 0,
      'sort_rule': 2,
      'build': 0,
      'mobi_app': 'web',
    };
    if (endTs != null) {
      params['end_ts'] = endTs;
    }

    Map signParams = await WbiSign().makSign(params);
    var res = await Request().get(Api.sessionList, data: signParams);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SessionDataModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future accountList(uids) async {
    var res = await Request().get(Api.sessionAccountList, data: {
      'uids': uids,
      'build': 0,
      'mobi_app': 'web',
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data']
            .map<AccountListModel>((e) => AccountListModel.fromJson(e))
            .toList(),
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future sessionMsg({
    int? talkerId,
  }) async {
    Map params = await WbiSign().makSign({
      'talker_id': talkerId,
      'session_type': 1,
      'size': 20,
      'sender_device_id': 1,
      'build': 0,
      'mobi_app': 'web',
    });
    var res = await Request().get(Api.sessionMsg, data: params);
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': SessionMsgDataModel.fromJson(res.data['data']),
        };
      } catch (err) {
        print(err);
      }
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
}
