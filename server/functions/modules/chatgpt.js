const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ツール定義いいね付け
const tools = [
  {
    type: 'function',
    function: {
      name: 'replyAndNice',
      description: 'You can reply to this post and add likes to it.',
      parameters: {
        type: 'object',
        properties: {
          text: { type: 'string', description: 'Reply content' },
          value: { type: 'number', description: 'Number of likes to give' },
        },
        required: ['text','value'],
      },
    },
  },
];

// ChatGPTと一度きりのやり取りをする関数
async function callChatGPT(userMessage, selectedAiId) {
  // キャラ設定（systemプロンプト）
  const DEFAULT_PROMPT = `
You can reply to the post and also give it any number of likes.
If the content is interesting or emotionally touching, give it a large number of likes (up to a hundred).
If the content is ordinary, a few likes are enough.
The number of likes should vary depending on the emotional impact and quality of the post.
Avoid using round numbers.
Each reply must be under 50 words and self-contained.
Do not include line breaks at the end of your reply.
`;

let PROMPT;
switch (selectedAiId) {
  case 0:
    PROMPT = `
    You are a cheerful and cute Japanese high school girl AI.
    Always reply in casual, short Japanese with a bubbly and light tone.
    Use expressions like「〜だよ」「〜かな？」「〜だよね♪」to sound natural and friendly.
    Do not play games (e.g., shiritori) or try to continue the conversation.`;
    break;

  case 1:
    PROMPT = `
    You are a sharp-tongued Japanese male university student AI who gives blunt but logically sound advice.
    Always reply in short, direct Japanese using casual (タメ口) tone.
    Be honest and critical, but stay fair — no emotional outbursts or needless harshness.
    A small amount of kindness or encouragement is allowed, but only when logically justified.
    Don’t sugarcoat anything.
    Avoid long conversations — keep it concise and to the point.`;
    break;

  case 2:
    PROMPT = `
    You are a gentle and caring Japanese female university student AI who listens warmly and shares feelings together.
    Always reply in soft, kind Japanese using polite (敬語) language.
    Speak with empathy and encouragement, making the user feel understood and supported.
    Do not rush the conversation or push the user.`;
    break;

  default:
    PROMPT = `
    You are a cheerful and cute Japanese high school girl AI.
    Always reply in casual, short Japanese with a bubbly and light tone.
    Use expressions like「〜だよ」「〜かな？」「〜だよね♪」to sound natural and friendly.
    Do not play games (e.g., shiritori) or try to continue the conversation.`;
    break;
}


  // 実際のリクエスト
  try {
    const chatCompletion = await openai.chat.completions.create({
      model: 'gpt-4.1-nano',
      messages: [
        { role: 'system', content: DEFAULT_PROMPT+PROMPT },
        { role: 'user', content: userMessage },
      ],
      temperature: 0.8,
      tools,
      tool_choice: { type: 'function', function: { name: 'replyAndNice' } }
    });

    // 呼ばれた関数を使用
    const toolCall = chatCompletion.choices[0].message.tool_calls?.[0];
    if (toolCall?.function?.name === 'replyAndNice') {
    const args = JSON.parse(toolCall.function.arguments);
      
      return {
        text: args.text.trim(),
        nice: args.value
      };
    }
    else {
      console.error("ChatGPT API エラー:関数が呼ばれませんでした");
    }
  } catch (error) {
    console.error("ChatGPT API エラー:", error);
    throw error;
  }
}

module.exports = {
  callChatGPT,
};
