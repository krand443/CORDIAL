import 'package:flutter/material.dart';
import 'package:cordial/widgets/post_card.dart';
import 'package:cordial/function/database_read.dart';
import 'package:cordial/models/timeline.dart';

//タイムラインを表示するクラス
class TimelineWidget extends StatefulWidget {
  //任意でポストidを受け取る(受け取ったらそのリプライを返す)
  final String? postId;

  //任意でユーザーidを受け取る
  final String? userId;

  //任意でスクロールコントローラーを受け取る
  final ScrollController parentScrollController;

  const TimelineWidget({super.key, this.userId, this.postId , required this.parentScrollController,});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

// 上記のStatefulWidgetに対応する状態クラス
class _TimelineWidgetState extends State<TimelineWidget> {
  //最後までスクロールをしたときに投稿を追加するためのコントローラー
  late ScrollController _scrollController;

  //投稿を取得しているかどうか
  bool isLoading = false;

  //投稿をすべて取得したかどうか
  bool isShowAll = false;

  //タイムライン生成で使用するポストId
  String? _postId;

  //タイムライン生成で使用するユーザーId
  String? _userId;

  @override
  void initState() {
    super.initState();

    //ウィジェットから値を受け取る
    _userId = widget.userId;
    _postId = widget.postId;

    //コントローラーを親ウィジットから受け取る。
    _scrollController = widget.parentScrollController;

    timelineAdd(); // 初回表示時に実行される

    //下の方までまでスクロールをしたとき更新
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent -
                  500 //画面の縦の高さは: 783.2727272727273
          &&
          !isLoading &&
          !isShowAll) {
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

    //タイムラインを取得
    Timeline? _timeline = _postId != null
        //ポストidが渡されているなら返信を取得する
        ? await DatabaseRead.replyTimeline(_postId!,timeline?.lastVisible)
        //渡されてないなら通常のタイムラインを取得する
        : await DatabaseRead.timeline(_userId,timeline?.lastVisible);

    //タイムラインを更新
    if (_timeline != null) {
      //もともとのタイムラインが空だったらそのまま挿入、でなければ更新
      setState(() {
        if (timeline == null) {
          timeline = _timeline;

        } else {
          timeline!.posts.addAll(_timeline.posts);
          timeline!.lastVisible = _timeline.lastVisible;
        }
      });

      //要素は収まっているので追加の要素は存在しない。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent <=
                _scrollController.position.viewportDimension) {
          if (!mounted) return;//メモリリーク予防
          setState(() {
            isShowAll = true;
          });
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


  @override
  Widget build(BuildContext context) {
    //タイムラインなし&すべてみせきってないなら読み込み
    if(timeline == null && !isShowAll) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }
    else {
      return
        timeline == null
        ? SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(16),
          ),
        )
      :SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: timeline!.posts.length + 2,
          // 最後にローディング用ウィジェットを1つ追加
              (BuildContext context, int index) {
            if (index < timeline!.posts.length) {
              // 各投稿をカード形式で表示
              return PostCard(post: timeline!.posts[index],
                transition: _postId!=null ? false:true,//返信用なら遷移させない
              );
            }

            if (index == timeline!.posts.length) {
              //最後に読み込みを追加する
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: !isShowAll
                      ? const CircularProgressIndicator(
                    color: Colors.blue,
                    backgroundColor: Colors.transparent,
                  )
                      : SizedBox.shrink(), // ← falseのときは何も表示しない
                ),
              );
            }

            //最後に余白を追加する
            if (index == timeline!.posts.length + 1) {
              return const SizedBox(height: 90,);
            }
          },
        ),
      );
    }
  }
}
