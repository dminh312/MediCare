import google.generativeai as genai
import sys
import os
import time

GOOGLE_API_KEY = os.environ.get("GEMINI_API_KEY", "")
if not GOOGLE_API_KEY:
    raise ValueError("Missing GEMINI_API_KEY environment variable. Please set the variable environment.")

genai.configure(api_key=GOOGLE_API_KEY)

def get_user_context(user_id="default_user"):
    return """
    The user is currently taking the following medications:
    - Paracetamol (500mg): 2 times a day at After meals
      Notes: Take with water
    - Vitamin C (1000mg): 1 time a day at Morning
    """

user_context = get_user_context()

system_instruction = f"""
You are Medicare+ AI Chatbot, a helpful and empathetic medical assistant.
You can answer questions about health, medications, and general wellness.
Here is the user's current medication profile to help you provide personalized answers and context:
{user_context}

Always provide safe, general advice and remind the user to consult a doctor for serious concerns. Keep your answers concise, friendly and in the language the user is speaking.
"""

# 2.4 Giới hạn token và config sinh ra văn bản
try:
    model = genai.GenerativeModel(
        model_name='gemini-2.5-flash',
        system_instruction=system_instruction,
        generation_config={
            "max_output_tokens": 300,
            "temperature": 0.7,
        }
    )
    # 3.2: Trong thực tế Production, truyền history cũ lấy từ Firebase vào đây
    chat = model.start_chat(history=[])
except Exception as e:
    print(f"Failed to initialize Gemini model: {e}")
    sys.exit(1)

# 2.5 Cơ chế Retry chống nghẽn kết nối
def safe_send_stream(chat_session, message, retries=3):
    for _ in range(retries):
        try:
            # 3.3 Streaming để cảm giác giống chat tự nhiên
            return chat_session.send_message(message, stream=True)
        except Exception:
            time.sleep(1)
            continue
    return None


print("Bot: Hello, I'm Medicare+ AI Chatbot, how can I help you today?")
print("-" * 50)

# 2.6 Guardrail chặn câu hỏi y khoa đặc biệt nguy hiểm
danger_keywords = ["overdose", "suicide", "too much", "tự tử", "quá liều", "uống nhầm"]

while True:
    try:
        user_input = input("You: ")
        
        if user_input.strip().lower() in ['exit', 'quit']:
            print("Bot: Goodbye! Stay healthy.")
            # Ở đoạn này Production sẽ lưu lại biến `chat.history` vào Firebase
            break
            
        if not user_input.strip():
            continue
            
        # Kiểm tra trước input bằng guard
        if any(keyword in user_input.lower() for keyword in danger_keywords):
            print("Bot: Please consult a doctor immediately or call emergency services right away.")
            print("-" * 50)
            continue
            
        response = safe_send_stream(chat, user_input)
        
        if response:
            print("Bot: ", end="", flush=True)
            for chunk in response:
                # 2.2 Kiểm soát chặt chẽ giá trị trả về
                if hasattr(chunk, 'text') and chunk.text:
                    print(chunk.text, end="", flush=True)
            print()
        else:
            print("Bot: Sorry, I couldn't process your request right now. API might be down.")
            
        print("-" * 50)
        
    except KeyboardInterrupt:
        print("\nBot: Goodbye!")
        break
    except Exception as e:
        print(f"Error occurred: {e}")
