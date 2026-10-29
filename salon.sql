SELECT 'CREATE DATABASE salon'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'salon')\gexec

\connect salon

CREATE TABLE IF NOT EXISTS customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  phone VARCHAR UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  service_id INT NOT NULL REFERENCES services(service_id),
  time VARCHAR NOT NULL
);

INSERT INTO services (name)
SELECT offering.name
FROM (VALUES ('cut'), ('color'), ('perm'), ('style'), ('trim')) AS offering(name)
WHERE NOT EXISTS (
  SELECT 1
  FROM services
  WHERE services.name = offering.name
);