import random
import string

def generate_cpf():
    return ''.join([str(random.randint(0, 9)) for _ in range(11)])

def generate_name():
    first_names = ['Maria', 'João', 'Carlos', 'Ana', 'Lucas']
    last_names = ['Silva', 'Souza', 'Lima', 'Oliveira', 'Pereira']
    return f"{random.choice(first_names)} {random.choice(last_names)}"

def generate_email(name):
    domain = "example.com"
    name_clean = name.lower().replace(" ", "")
    suffix = ''.join(random.choices(string.digits, k=3))
    return f"{name_clean}{suffix}@{domain}"
