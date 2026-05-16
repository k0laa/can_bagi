import requests
import random

BASE_URL = "http://127.0.0.1:8000"

def rand_lat(): return round(random.uniform(39.60, 39.70), 4)
def rand_lon(): return round(random.uniform(27.85, 27.95), 4)

categories = ["MEDICAL", "RESCUE", "FOOD", "SHELTER", "CLOTHES", "VULNERABLE"]
skills = ["MEDICAL", "RESCUE", "LOGISTICS", "GENERAL"]
need_details = [
    "Yaralı var, ilk yardım gerekli",
    "Enkaz altında kişi var",
    "Gıda ve su ihtiyacı acil",
    "Barınma yeri lazım",
    "Kıyafet ihtiyacı var",
    "Yaşlı bakımı gerekiyor",
    "Çocuk için süt lazım",
    "İlaç ihtiyacı var",
    "Tekerlekli sandalye lazım",
    "Ambulans çağrılması gerekiyor",
]

print("=== 40 Normal Kullanıcı ===")
user_ids = []
for i in range(0):
    r = requests.post(f"{BASE_URL}/auth/register", json={
        "name": f"Kullanıcı{i+1}",
        "surname": f"Soyad{i+1}",
        "phone": f"0555{str(i+1).zfill(7)}",
        "blood_type": random.choice(["A+", "A-", "B+", "B-", "AB+", "AB-", "0+", "0-"]),
        "skills": random.choice(skills),
        "password": "test1234",
        "lat": rand_lat(),
        "lon": rand_lon()
    })
    if r.status_code == 200:
        user_ids.append(r.json()["id"])
        print(f"  Kullanıcı {i+1} oluşturuldu")
    else:
        print(f"  Hata: {r.text}")

print("\n=== 10 Admin (Koordinatör) ===")
admin_ids = []
for i in range(1):
    r = requests.post(f"{BASE_URL}/auth/register", json={
        "name": f"Admin{i+1}",
        "surname": f"Koordinatör{i+1}",
        "phone": f"0544{str(i+1).zfill(7)}",
        "blood_type": random.choice(["A+", "B+", "0+"]),
        "skills": "GENERAL",
        "password": "admin1234"
    })
    if r.status_code == 200:
        admin_ids.append(r.json()["id"])
        print(f"  Admin {i+1} oluşturuldu")

print("\n=== 1 Super Kullanıcı ===")
super_ids = []
r = requests.post(f"{BASE_URL}/auth/register", json={
    "name": "Super1",
    "surname": "Yönetici1",
    "phone": "05330000001",
    "blood_type": "A+",
    "skills": "GENERAL",
    "password": "super1234"
})
if r.status_code == 200:
    super_ids.append(r.json()["id"])
    print(f"  Super 1 oluşturuldu")

print("\n=== Rolleri Güncelle ===")
import subprocess
subprocess.run([
    "python", "-c",
    f"from database import SessionLocal; from models import User; db = SessionLocal(); "
    f"u = db.query(User).filter(User.id == {super_ids[0]}).first(); u.role = 'SUPER'; db.commit(); print('SUPER yapıldı')"
])

r = requests.post(f"{BASE_URL}/auth/coordinator/login", json={
    "phone": "05330000001",
    "password": "super1234"
})
super_token = r.json()["access_token"]
headers = {"Authorization": f"Bearer {super_token}"}

for aid in admin_ids:
    r = requests.post(f"{BASE_URL}/auth/make-coordinator/{aid}", headers=headers)
    print(f"  Admin {aid} COORDINATOR yapıldı")

print("\n=== Kullanıcı Konumları Güncelle ===")
for i, user_id in enumerate(user_ids):
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "phone": f"0555{str(i+1).zfill(7)}",
        "password": "test1234"
    })
    if r.status_code != 200:
        continue
    token = r.json()["access_token"]
    r = requests.put(f"{BASE_URL}/user/profile",
        json={"lat": rand_lat(), "lon": rand_lon()},
        headers={"Authorization": f"Bearer {token}"}
    )
    print(f"  Kullanıcı {user_id} konum güncellendi: {r.status_code}")

print("\n=== 60 SOS ===")
for i in range(2):
    r = requests.post(f"{BASE_URL}/sos/", json={
        "node_id": f"NODE_0{random.randint(1,5)}",
        "lat": rand_lat(),
        "lon": rand_lon(),
        "details": random.choice([
            "Enkaz altındayım, yardım edin",
            "Yaralıyım hareket edemiyorum",
            "3. katta mahsur kaldım",
            "Duvar çöktü üzerime",
            None
        ])
    })
    print(f"  SOS {i+1}: {r.status_code}")

print("\n=== 60 Need Request ===")
for i in range(3):
    r = requests.post(f"{BASE_URL}/nodes/data", json={
        "type": "NEEDS",
        "node_id": f"NODE_0{random.randint(1,5)}",
        "category": random.choice(categories),
        "lat": rand_lat(),
        "lon": rand_lon(),
        "people_count": random.randint(1, 10),
        "details": random.choice(need_details)
    })
    print(f"  Need {i+1}: {r.status_code}")

print("\n=== Tamamlandı ===")