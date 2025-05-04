import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

# Sample data pools
drug_names = ['Paracetamol', 'Amoxicillin', 'Ibuprofen', 'Fluoxetine', 'Oseltamivir', 'Ciprofloxacin', 'Risperidone', 'Sertraline']
drug_brands = ['Emzor', 'GSK', 'Pfizer', 'May & Baker', 'Fidson', 'Swiss Pharma', 'Evans', 'Orange Drugs']
drug_categories = ['Antibiotic', 'Antiviral', 'Antipsychotic', 'Antidepressant', 'Analgesic']
store_names = [f"Lekwot Pharmacy {i+1}" for i in range(15)]

locations = [
    ('Lagos', 'Lagos'), ('Ibadan', 'Oyo'), ('Enugu', 'Enugu'), ('Kano', 'Kano'),
    ('Port Harcourt', 'Rivers'), ('Abuja', 'FCT'), ('Kaduna', 'Kaduna'),
    ('Benin City', 'Edo'), ('Aba', 'Abia'), ('Jos', 'Plateau')
]

customer_locations = [
    ('Badagry', 'Lagos'), ('Egbeda', 'Lagos'), ('Ikoyi', 'Lagos'), ('Oshodi', 'Lagos'), ('Ajegunle', 'Lagos'),
    ('Ibadan', 'Oyo'), ('Lafenwa', 'Ogun'), ('Agodi', 'Oyo'), ('Ile-Ife', 'Osun'),
    ('Enugu', 'Enugu'), ('Nsukka', 'Enugu'), ('Owerri', 'Imo'), ('Aba', 'Abia'), ('Umuahia', 'Abia'), ('Ohafia', 'Abia'),
    ('Kano', 'Kano'), ('Abuja', 'FCT'), ('Kaduna', 'Kaduna'), ('Jos', 'Plateau'),
    ('Port Harcourt', 'Rivers'), ('Benin City', 'Edo'), ('Asaba', 'Delta'), ('Calabar', 'Cross River')
]

# Generate 400 unique products
products = []
for _ in range(400):
    drug = random.choice(drug_names)
    brand = random.choice(drug_brands)
    category = random.choice(drug_categories)
    price = round(random.uniform(500, 10000), 2)
    stock = random.randint(20, 500)
    last_updated = datetime.today() - timedelta(days=random.randint(0, 30))
    products.append({
        "product_name": drug,
        "drug_brand": brand,
        "drug_category": category,
        "price": price,
        "quantity_in_stock": stock,
        "last_updated_date": last_updated.date()
    })

# Create 200 Nigerian customers
customers = []
for _ in range(200):
    customers.append({
        "name": fake.name(),
        "email": fake.email(),
        "mobile": fake.phone_number(),
        "city_state": random.choice(customer_locations)
    })

# Salary by role
salary_by_role = {
    "Manager": random.randint(300000, 400000),
    "Pharmacist": random.randint(200000, 250000),
    "Cashier": random.randint(100000, 150000),
    "Janitor": random.randint(50000, 80000)
}

# Generate store employees
store_employees = {}
roles = ["Manager", "Pharmacist", "Pharmacist", "Cashier", "Janitor"]
for store in store_names:
    store_city, store_state = random.choice(locations)
    emp_list = []
    for role in roles:
        emp_list.append({
            "employee_name": fake.name(),
            "role": role,
            "store_name": store,
            "store_city": store_city,
            "store_state": store_state,
            "salary": salary_by_role[role]
        })
    store_employees[store] = emp_list

# Generate 10,000 sales records
sales_data = []
start_date = datetime.today() - timedelta(days=5*365)
for i in range(1, 10001):
    product = random.choice(products)
    customer = random.choice(customers)
    sale_date = start_date + timedelta(days=random.randint(0, (datetime.today() - start_date).days))
    store = random.choice(store_names)
    employee = random.choice(store_employees[store])
    
    sales_data.append([
        i,
        product["product_name"], product["drug_brand"], product["drug_category"], product["price"],
        random.randint(1, 10),
        product["quantity_in_stock"], product["last_updated_date"],
        sale_date.date(),
        customer["name"], customer["email"], customer["mobile"],
        customer["city_state"][0], customer["city_state"][1],
        employee["employee_name"], employee["role"], employee["salary"],
        store, employee["store_city"], employee["store_state"]
    ])

# Create DataFrame
columns = [
    "id_of_sale", "product_name", "drug_brand", "drug_category", "price", "quantity_purchased",
    "quantity_in_stock", "last_updated_date", "sale_date",
    "customer", "customer_email", "customer_mobile_number", "customer_city", "customer_state",
    "employee", "employee_role", "employee_salary",
    "store_name", "store_city", "store_state"
]

df = pd.DataFrame(sales_data, columns=columns)

# Save to CSV
df.to_csv("lekwo_pharmacy_sales_inventory.csv", index=False)

print("Dataset: 'lekwo_pharmacy_sales_inventory.csv' created")
