import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/home/rcmd/result.dart';
import 'package:pilipala/models/model_rec_video_item.dart';
import 'package:pilipala/utils/storage.dart';

class RcmdController extends GetxController {
  final ScrollController scrollController = ScrollController();
  int _currentPage = 0;
  bool isLoadingMore = true;
  OverlayEntry? popupDialog;
  Box recVideo = GStrorage.recVideo;
  Box setting = GStrorage.setting;
  RxInt crossAxisCount = 2.obs;
  late bool enableSaveLastData;
  late String defaultRcmdType;
  late RxList<dynamic> videoList;

  @override
  void onInit() {
    super.onInit();
    crossAxisCount.value =
        setting.get(SettingBoxKey.customRows, defaultValue: 2);
    // 读取app端缓存内容
    // if (recVideo.get('cacheList') != null &&
    //     recVideo.get('cacheList').isNotEmpty) {
    //   List<RecVideoItemAppModel> list = [];
    //   for (var i in recVideo.get('cacheList')) {
    //     list.add(i);
    //   }
    //   videoList.value = list;
    // }
    enableSaveLastData =
        setting.get(SettingBoxKey.enableSaveLastData, defaultValue: false);
    defaultRcmdType =
        setting.get(SettingBoxKey.defaultRcmdType, defaultValue: 'web');
    if(defaultRcmdType == 'web') {
      videoList = <RecVideoItemModel>[].obs;
    } else {
      videoList = <RecVideoItemAppModel>[].obs;
    }
  }

  // 获取推荐
  Future queryRcmdFeed(type) async {
    if (isLoadingMore == false) {
      return;
    }
    if (type == 'onRefresh') {
      _currentPage = 0;
    }
    late final Map<String,dynamic> res;
    switch (defaultRcmdType) {
      case 'app':
        res = await VideoHttp.rcmdVideoListApp(
          freshIdx: _currentPage,
        );
        break;
      case 'notLogin':
        res = await VideoHttp.rcmdVideoListApp(
          loginState: false,
          freshIdx: _currentPage,
        );
        break;
      default: //'web'
        res = await VideoHttp.rcmdVideoList(
          ps: 20,
          freshIdx: _currentPage,
        );
    }

    if (res['status']) {
      if (type == 'init') {
        if (videoList.isNotEmpty) {
          videoList.addAll(res['data']);
        } else {
          videoList.value = res['data'];
        }
      } else if (type == 'onRefresh') {
        if (enableSaveLastData) {
          videoList.insertAll(0, res['data']);
        } else {
          videoList.value = res['data'];
        }
      } else if (type == 'onLoad') {
        videoList.addAll(res['data']);
      }
      recVideo.put('cacheList', res['data']);
      _currentPage += 1;
    } else {
      Get.snackbar('提示', res['msg']);
    }

    isLoadingMore = false;
    return res;
  }

  // 下拉刷新
  Future onRefresh() async {
    isLoadingMore = true;
    queryRcmdFeed('onRefresh');
  }

  // 上拉加载
  Future onLoad() async {
    queryRcmdFeed('onLoad');
  }

  // 返回顶部
  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
