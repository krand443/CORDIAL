// ✅ 正しいv2の書き方（ESM or TypeScriptと同じように）
const { onTaskDispatched } = require("firebase-functions/v2/tasks");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

exports.deleteInvitation = onTaskDispatched({
    region: "asia-northeast1"  // リージョンを指定！
  },async (task) => {
  try {
    const { invitationId } = task.data;

    if (!invitationId) {
      throw new Error("Missing invitationId in task payload");
    }

    const invitationRef = db.collection("invitations").doc(invitationId);
    await invitationRef.delete();

    console.log(`Invitation document ${invitationId} deleted successfully.`);
  } catch (error) {
    console.error("Error deleting invitation:", error);
    throw error; // DLQ対応
  }
});
