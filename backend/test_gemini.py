from groq import Groq

client = Groq(api_key="REPLACED_SECRET")

try:
    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": "Merhaba, kisa cevap ver"}],
        temperature=0.3,
    )
    print("BASARILI:", response.choices[0].message.content)
except Exception as e:
    print("HATA:", e)
