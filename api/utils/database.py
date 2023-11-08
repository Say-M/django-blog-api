import psycopg2

HOST = "localhost"
DB_NAME = "BlogLagbeV2"
USER = "postgres"
PASSWORD = "543496"
PORT = 5433

conn = psycopg2.connect(
    host=HOST,
    database=DB_NAME,
    user=USER,
    password=PASSWORD,
    port=PORT
)

cur = conn.cursor()

Error = psycopg2.Error