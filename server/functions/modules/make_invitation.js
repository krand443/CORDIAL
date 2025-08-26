const { onRequest } = require("firebase-functions/v2/https");
const { certification } = require("./certification");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getFunctions } = require("firebase-admin/functions");

exports.makeInvitation = onRequest(
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

    const { groupId } = req.body;
    if (!groupId) {
      return res.status(400).send("Missing 'groupId'");
    }

    // =================ここから認証済み後実行可====================

    // 必要な情報を補完して投稿
    try {
      const db = getFirestore();
      const docRef = await db.collection("invitations").add({
        groupId:groupId,
        createdAt:FieldValue.serverTimestamp(),
      });

      const queue = getFunctions().taskQueue(
        "locations/asia-northeast1/functions/deleteInvitation"
      );
      await queue.enqueue(
        // キューに渡すペイロードデータ、フォーマットは任意
        {
          invitationId: docRef.id
        },
        // オプション指定
        {
          scheduleDelaySeconds: 3600 * 24, // 遅延送信(一日)
          dispatchDeadlineSeconds: 60 * 1, // タスクが完了するまでにCloud Tasksが待機する最長時間の指定
        }
      );

      console.log("✅ Invitation code created successfully!");
      res.status(200).send(docRef.id);// ドキュメントidが招待コードとして機能する
    } catch (error) {
      console.error("❌ Invitation code created failed:", error);
      res.status(500).send(error);
    }
  }
);
