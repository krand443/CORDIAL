import 'package:flutter/material.dart';
import '../widgets/timeline_widget.dart';

// アプリのホーム画面を表すStatefulWidget（状態を持つウィジェット）
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  TimelinePageState createState() => TimelinePageState();
}

// 上記のStatefulWidgetに対応する状態クラス
class TimelinePageState extends State<TimelinePage> {
  //最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  //画面をリロード
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
        color: Colors.grey.shade50,
        child: RefreshIndicator(
          onRefresh: reload,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.85),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                title: const Text(
                  "タイムライン",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {},
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              TimelineWidget(parentScrollController: _scrollController),
            ],
          ),
        ),
      ),
    );
  }
}
