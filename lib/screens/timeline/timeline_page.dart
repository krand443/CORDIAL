import 'package:flutter/material.dart';
import 'package:cordial/widgets/timeline_widget.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/timeline/timeline_menu.dart';
import 'package:cordial/navigation/page_transitions.dart';

// 投稿のタイムラインを表示する画面
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  TimelinePageState createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 画面をリロード
  Future _reload() async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 投稿一覧
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: _reload,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomAppbar(
              onTap: () {
                _scrollController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              titleText: "タイムライン",
              leading: IconButton(
                icon: Icon(Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  PageTransitions.fromLeft(
                      onUnderBar: true,targetWidget: const TimelineMenu(), context: context);
                },
              ),
            ),

            // タイムラインをリストで取得する
            TimelineWidget(parentScrollController: _scrollController),

            const SliverToBoxAdapter(
              child: SafeArea(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }
}
