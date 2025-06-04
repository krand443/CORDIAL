import 'package:flutter/material.dart';
import 'package:cordial/widgets/timeline/timeline_widget.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/widgets/timeline/timeline_menu.dart';
import 'package:cordial/navigation/page_transitions.dart';

// 投稿のタイムラインを表示するウィジェット
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  TimelinePageState createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 画面をリロード
  Future reload() async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget, // super.widget ではなく widget
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // 画面を描画するbuildメソッド（Flutterフレームワークが呼び出す）
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 投稿一覧（縦スクロール可能なListViewで構成）
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
          onRefresh: reload,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              CustomAppbar(
                titleText: "タイムライン",
                onTap: (){
                  PageTransitions.fromLeft(const TimelineMenu(), context);
              },),

              // タイムラインをリストで取得する
              TimelineWidget(parentScrollController: _scrollController),
            ],
          ),
        ),
      ),
    );
  }
}
