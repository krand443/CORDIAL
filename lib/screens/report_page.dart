import 'package:flutter/material.dart';
import 'package:cordial/services/database_write.dart';

class ReportPage extends StatefulWidget {

  final String postId;

  const ReportPage({super.key, required this.postId});

  @override
  State<ReportPage> createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  // 未入力を確認するためのコントローラー
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // 通報内容を選択するためのラジオボタン用変数
  String? _selectedOption; // 初期値はnullで、何も選択されていない状態
  final List<String> _options = ['宣伝、スパム目的', '不快な表現', '迷惑行為', 'その他'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _appbar(),
      body: SingleChildScrollView(
        //キーボード表示で画面が崩れないようスクロールにする
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // 通報内容選択用のラジオボタン
            ..._options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(fontSize: 14),
                ),
                // オプションのテキスト
                value: option,
                groupValue: _selectedOption,
                // 現在選択されているグループの値
                onChanged: (String? value) {
                  setState(() {
                    _selectedOption = value; // 選択された値を更新
                  });
                },
                activeColor: Theme.of(context).colorScheme.tertiary,
              );
            }),

            const SizedBox(
              height: 10,
            ),

            _buildTextField(
              controller: _textController,
              label: '入力欄',
              textColor: Theme.of(context).colorScheme.onPrimary,
              labelColor: Colors.grey,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 項目が選ばれてれば実行
                  if (_selectedOption != null) {
                    // データベースに内容を保存
                    DatabaseWrite.report(postId: widget.postId, category: _selectedOption!, text: _textController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ご報告ありがとうございます!')),
                    );
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('通報項目を選択してください'),
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.fixed, // bottomに固定（デフォルト）
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: _selectedOption != null
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Colors.grey,
                  foregroundColor: _selectedOption != null
                      ? Colors.white
                      : Colors.grey[50],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Text('送信')
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: Colors.transparent,
        // アプリバーの色
        automaticallyImplyLeading: false,
        // 戻るアイコンを非表示にする
        leading: IconButton(
          padding: const EdgeInsets.only(top: 0),
          icon: const Icon(
            Icons.close,
            size: 30,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 現在の画面を閉じる
          },
        ),
        title: const Text(
          '通報',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      );

  // 汎用テキストフィールド
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    required Color textColor,
    required Color labelColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      maxLength: 400,
      style: TextStyle(fontSize: 16, color: textColor),
      // 文字色を指定
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        // ラベルの色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 角を丸く
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.white), // フォーカス時のボーダー色を白に変更
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        // 内側に余白を追加

        floatingLabelBehavior: FloatingLabelBehavior.always, // ラベルを常に上に表示
      ),
    );
  }
}
