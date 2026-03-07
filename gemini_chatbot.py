import google.generativeai as genai
import sys

import os

# Configure Gemini API key
GOOGLE_API_KEY = os.environ.get("GEMINI_API_KEY", "")
genai.configure(api_key=GOOGLE_API_KEY)

# Mock user data context (in real app, this comes from Firestore)
user_context = """
The user is currently taking the following medications:
- Paracetamol (500mg): 2 times a day at After meals
  Notes: Take with water
- Vitamin C (1000mg): 1 time a day at Morning
"""

system_instruction = f"""
You are Medicare+ AI Chatbot, a helpful and empathetic medical assistant.
You can answer questions about health, medications, and general wellness.
Here is the user's current medication profile to help you provide personalized answers and context:
{user_context}

Always provide safe, general advice and remind the user to consult a doctor for serious concerns. Keep your answers concise, friendly and in the language the user is speaking.
"""

# Initialize model
try:
    model = genai.GenerativeModel(
        model_name='gemini-2.5-flash',
        system_instruction=system_instruction
    )
    chat = model.start_chat(history=[])
except Exception as e:
    print(f"Failed to initialize Gemini model: {e}")
    sys.exit(1)

# Initial message of the chatbot
print("Bot: Hello, I'm Medicare+ AI Chatbot, how can I help you today?")
print("-" * 50)

# Start conversation loop
while True:
    try:
        user_input = input("You: ")
        
        # Add exit commands
        if user_input.strip().lower() in ['exit', 'quit']:
            print("Bot: Goodbye! Stay healthy.")
            break
            
        if not user_input.strip():
            continue
            
        # Send message to Gemini
        response = chat.send_message(user_input)
        print(f"Bot: {response.text}")
        print("-" * 50)
        
    except KeyboardInterrupt:
        print("\nBot: Goodbye!")
        break
    except Exception as e:
        print(f"Error occurred: {e}")
