import pandas as pd
from sqlalchemy import create_engine, text
import os

# 1. الاتصال بالقاعدة الأساسية (postgres) لإنشاء القاعدة الجديدة
# تأكدي أن الباسورد هو postgres والمنفذ 5432
base_url = "postgresql://postgres:postgres@localhost:5432/postgres"
engine_base = create_engine(base_url)

# الاسم الصحيح لقاعدة البيانات المطلوبة
db_name = "ecommerce_analytics"

def setup_all():
    # إنشاء قاعدة البيانات إذا لم تكن موجودة
    print(f"🚀 Checking database: {db_name}...")
    try:
        with engine_base.connect() as conn:
            conn.execute(text("COMMIT"))
            result = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname='{db_name}'"))
            if not result.fetchone():
                conn.execute(text(f"CREATE DATABASE {db_name}"))
                print(f"✅ Database {db_name} created!")
            else:
                print(f"ℹ️ Database {db_name} already exists.")
    except Exception as e:
        print(f"⚠️ Note: Could not create database (it might already exist): {e}")

    # 2. الاتصال بالقاعدة الجديدة لإنشاء الجداول
    engine_new = create_engine(f"postgresql://postgres:postgres@localhost:5432/{db_name}")
    
    print("🏗️ Creating tables from schema.sql...")
    try:
        with open('data/schema.sql', 'r') as f:
            # تنظيف ملف الـ SQL من أوامر الـ COPY اليدوية التي تسبب أخطاء
            lines = f.readlines()
            clean_sql = "".join([line for line in lines if "COPY" not in line and "FROM '" not in line])
            
            with engine_new.connect() as conn:
                conn.execute(text(clean_sql))
                conn.commit()
        print("✅ Tables created successfully.")
    except Exception as e:
        print(f"❌ Error creating tables: {e}")

    # 3. رفع ملفات الـ CSV باستخدام بايثون (أضمن طريقة)
    files = {
        'customers': 'data/customers.csv',
        'products': 'data/products.csv',
        'orders': 'data/orders.csv',
        'order_items': 'data/order_items.csv'
    }

    for table, path in files.items():
        if os.path.exists(path):
            print(f"📥 Loading {table}...")
            try:
                df = pd.read_csv(path)
                # رفع البيانات للجداول
                df.to_sql(table, engine_new, if_exists='append', index=False)
                print(f"✅ {table} loaded ({len(df)} rows).")
            except Exception as e:
                print(f"❌ Error loading {table}: {e}")
        else:
            print(f"⚠️ File not found: {path}")

if __name__ == "__main__":
    setup_all()
    print("\n✨ EVERYTHING IS READY! You can now start your SQL analysis.")