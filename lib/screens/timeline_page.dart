import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';
import 'package:cordial/widgets/post_card.dart';
import 'package:cordial/function/database_read.dart';
import 'package:cordial/models/post.dart';
import 'package:cordial/models/timeline.dart';

// アプリのホーム画面を表すStatefulWidget（状態を持つウィジェット）
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

// 上記のStatefulWidgetに対応する状態クラス
class _TimelinePageState extends State<TimelinePage> {
  //最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  //投稿を取得しているかどうか
  bool isLoading = false;

  //投稿をすべて取得したかどうか
  bool isShowAll = false;

  @override
  void initState() {
    super.initState();
    timelineAdd(); // 初回表示時に実行される

    //下の方までまでスクロールをしたとき更新
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500 //画面の縦の高さは: 783.2727272727273
          && !isLoading
          && !isShowAll) {
        timelineAdd();
      }
    });
  }

  // 投稿データを格納するリスト
  Timeline? timeline;

  //タイムラインを追加する関数
  Future timelineAdd() async {
    //ロード中を示す。
    isLoading = true;

    //前回の最後のドキュメントがあれば渡す。
    Timeline? _timeline = timeline?.lastVisible != null
        ? await DatabaseRead.timeline(timeline!.lastVisible)
        : await DatabaseRead.timeline();

    //タイムラインを更新
    if (_timeline != null) {
      //タイムラインが空だったらそのまま挿入、でなければ更新

      setState(() {
        if (timeline == null){
          timeline = _timeline;
        }
        else{
          timeline!.posts.addAll(_timeline.posts);
          timeline!.lastVisible = _timeline.lastVisible;
        }
      });
    } else {
      //リストを取得し終えたならelseになる
      //取得し終えているならtrue
      isShowAll = true;
      setState(() {});
    }

    //ロード中を外す
    isLoading = false;
  }

  //投稿を更新する関数
  Future<void> refresh() {
    //現在のタイムラインを削除
    timeline = null;

    //投稿を読み込み
    return timelineAdd();
  }

  // 画面を描画するbuildメソッド（Flutterフレームワークが呼び出す）
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリ全体の構造を提供するウィジェット（AppBar・body・FABなど含む）
      appBar: AppBar(
        // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
        title: const Text("タイムライン"),
      ),

      // 投稿一覧（縦スクロール可能なListViewで構成）
      body: Container(
          color: Colors.grey.shade300,
          child: timeline == null
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.transparent,
                ))
              : RefreshIndicator(
                  //オーバースクロールで再読込
                  onRefresh: refresh,

                  child: ListView.builder(

                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    // 上下に余白を0
                    itemCount: timeline!.posts.length + 1,

                    // +1 で末尾にもう1個分確保 // 投稿の数を指定（動的に変わる）
                    itemBuilder: (context, index) {
                      if (index < timeline!.posts.length) {
                        // 各投稿をカード形式で表示
                        return PostCard(post: timeline!.posts[index]);
                      } else {
                        //最後に読み込みを追加する
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: !isShowAll
                              ? const CircularProgressIndicator(
                                  color: Colors.blue,
                                  backgroundColor: Colors.transparent,
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text("投稿は以上です")),
                        ));
                      }
                    },
                  ),
                )),
    );
  }
}
