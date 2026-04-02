import pandas as pd
from sqlalchemy import create_engine

# الاتصال بقاعدة البيانات في الدوكر
engine = create_engine("postgresql://postgres:postgres@localhost:5432/ecommerce_analytics")

# قائمة الملفات اللي بدنا نشوف نتائجها
queries = {
    "Cohort Analysis": "queries/cohort_analysis.sql",
    "Growth Analysis": "queries/growth_analysis.sql",
    "Trend Analysis": "queries/trend_analysis.sql",
    "Combined Analysis": "queries/combined_analysis.sql"
}

for title, path in queries.items():
    print(f"\n{'='*20} {title} {'='*20}")
    try:
        with open(path, 'r') as f:
            query_sql = f.read()
            # تشغيل الكود وعرض النتيجة كجدول
            df = pd.read_sql(query_sql, engine)
            print(df.head(15)) # بعرض لك أول 15 سطر من النتائج
    except Exception as e:
        print(f"Error running {title}: {e}")

print("\n✨ Done! Use these numbers to fill your report.md")