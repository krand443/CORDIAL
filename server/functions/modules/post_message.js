const { onRequest } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { callChatGPT } = require('./chatgpt');
const { certification } = require('./certification');

const postMessage = onRequest(
  { region: "asia-northeast1" },
  async (req, res) => {

    // トークンでベアラー認証
    let decodedToken = await certification(req, res);
    // エラーならreturn
    if (decodedToken == null){
      return res.status(401).send("Unauthorized: Invalid token");
    }

    // ユーザーidを取得
    const uid = decodedToken.uid;

    // リクエストからデータを取得
    const { text } = req.body;
    if (!text) {
      return res.status(400).send("Missing 'text'");
    }

    // リクエストからデータを取得
    let { selectedAiId } = req.body;
    if (!selectedAiId) {
      selectedAiId = 0;
    }

    // =================ここから認証済み後実行可====================

    // AIの応答を待つ
    let response;
    try {
      response = await callChatGPT(text,selectedAiId);
    } catch (err) {
      console.error("❌ AI呼び出し失敗:", err.message);
      return res.status(500).send("AI Error");
    }

    let resultText = response.text;
    let resultNice = response.nice;

    // 必要な情報を補完して投稿
    try {
      const db = getFirestore();
      await db.collection("posts").add({
        postedAt: FieldValue.serverTimestamp(),
        userid: uid,
        text,
        selectedAiId,
        response:resultText,
        nice: resultNice,
      });

      console.log("✅ Post saved to Firestore by", uid);
      res.status(200).send("Post saved successfully");
    } catch (error) {
      console.error("❌ Firestore write failed:", error);
      res.status(500).send("Internal Server Error");
    }
  }
);

async function deletePostsByUserId(uid) {
  try {
    // useridがuidと一致する投稿を取得
    const querySnapshot = await db.collection("posts")
      .where("userid", "==", uid)
      .get();

    // 投稿がなければ何もしない
    if (querySnapshot.empty) {
      console.log("削除対象の投稿はありません");
      return;
    }

    // 各ドキュメントを削除
    const batch = db.batch(); // バッチ処理を使って一括削除（ただしバッチは最大500件）
    querySnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit(); // バッチ実行

    console.log(`${querySnapshot.size} 件の投稿を削除しました`);
  } catch (error) {
    console.error("投稿の削除に失敗しました:", error);
  }
}


const postGroupMessage = onRequest(
  { region: "asia-northeast1" },
  async (req, res) => {

    // トークンでベアラー認証
    let decodedToken = await certification(req, res);
    // エラーならreturn
    if (decodedToken == null){
      return res.status(401).send("Unauthorized: Invalid token");
    }

    // ユーザーidを取得
    const uid = decodedToken.uid;

    // リクエストからデータを取得
    const { text } = req.body;
    if (!text) {
      return res.status(400).send("Missing 'text'");
    }

    const { groupId } = req.body;
    if (!groupId) {
      return res.status(400).send("Missing 'groupId'");
    }

    // リクエストからデータを取得
    let { selectedAiId } = req.body;
    if (!selectedAiId) {
      selectedAiId = 0;
    }

    // =================ここから認証済み後実行可====================

    // AIの応答を待つ
    let response;
    try {
      response = await callChatGPT(text,selectedAiId);
    } catch (err) {
      console.error("❌ AI呼び出し失敗:", err.message);
      return res.status(500).send("AI Error");
    }

    let resultText = response.text;
    let resultNice = response.nice;

    // 必要な情報を補完して投稿
    try {
      const db = getFirestore();
      await db.collection("groups").doc(groupId).collection("posts").add({
        postedAt: FieldValue.serverTimestamp(),
        userid: uid,
        text,
        selectedAiId,
        response:resultText,
        nice: resultNice,
      });

      await db.collection("groups").doc(groupId).update({
        lastAction: FieldValue.serverTimestamp(),
      });

      console.log("✅ Post saved to Firestore by", uid);
      res.status(200).send("Post saved successfully");
    } catch (error) {
      console.error("❌ Firestore write failed:", error);
      res.status(500).send("Internal Server Error");
    }
  }
);

module.exports = {
  postMessage,
  postGroupMessage
};
