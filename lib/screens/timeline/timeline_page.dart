import 'package:flutter/material.dart';
import 'package:cordial/screens/timeline/timeline_widget.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/timeline/timeline_menu.dart';
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
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: reload,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomAppbar(
              titleText: "タイムライン",
              leading: IconButton(
                icon: Icon(Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  PageTransitions.fromLeft(
                      targetWidget: const TimelineMenu(), context: context);
                },
              ),
            ),

            // タイムラインをリストで取得する
            TimelineWidget(parentScrollController: _scrollController),
          ],
        ),
      ),
    );
  }
}
