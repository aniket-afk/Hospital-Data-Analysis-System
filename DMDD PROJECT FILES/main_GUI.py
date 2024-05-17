
import tkinter as tk
from tkinter import messagebox
import pyodbc

# Connect to the SQL Server database
def db_connect():
    try:
        conn = pyodbc.connect(
           'DRIVER={ODBC Driver 17 for SQL Server};'
              'SERVER=Aditi\SQLEXPRESS;'
              'DATABASE=DAMG6210_Group8_Hospital;'
              'Trusted_Connection=yes;'
        )
        return conn
    except Exception as e:
        print(e)

# Function to add a new record
def create_record():
    conn = db_connect()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO Patient (patient_ID, first_name, last_name, street, city, state, zip_code, date_of_birth, phone_number, emergency_contact_name, emergency_contact_number, admit_date, patient_type)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (patient_id.get(), first_name.get(), last_name.get(), street.get(), city.get(), state.get(), zip_code.get(), date_of_birth.get(), phone_number.get(), emergency_contact_name.get(), emergency_contact_number.get(), admit_date.get(), patient_type.get()))
            conn.commit()
            messagebox.showinfo("Success", "Record created successfully")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

# Function to read and display a record
def read_record():
    conn = db_connect()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute('SELECT * FROM Patient WHERE patient_ID = ?', (patient_id.get(),))
            record = cursor.fetchone()
            if record:
                first_name.set(record[1])
                last_name.set(record[2])
                street.set(record[3])
                city.set(record[4])
                state.set(record[5])
                zip_code.set(record[6])
                date_of_birth.set(record[7])
                phone_number.set(record[8])
                emergency_contact_name.set(record[9])
                emergency_contact_number.set(record[10])
                admit_date.set(record[11])
                patient_type.set(record[12])
            else:
                messagebox.showinfo("Not Found", "No record found")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

# Function to update a record
def update_record():
    conn = db_connect()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute('''
                UPDATE Patient
                SET first_name = ?, last_name = ?, street = ?, city = ?, state = ?, zip_code = ?, date_of_birth = ?, phone_number = ?, emergency_contact_name = ?, emergency_contact_number = ?, admit_date = ?, patient_type = ?
                WHERE patient_ID = ?
            ''', (first_name.get(), last_name.get(), street.get(), city.get(), state.get(), zip_code.get(), date_of_birth.get(), phone_number.get(), emergency_contact_name.get(), emergency_contact_number.get(), admit_date.get(), patient_type.get(), patient_id.get()))
            conn.commit()
            if cursor.rowcount > 0:
                messagebox.showinfo("Success", "Record updated successfully")
            else:
                messagebox.showinfo("Not Found", "No record found to update")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

# Function to delete a record
def delete_record():
    conn = db_connect()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute('DELETE FROM Patient WHERE patient_ID = ?', (patient_id.get(),))
            conn.commit()
            if cursor.rowcount > 0:
                messagebox.showinfo("Success", "Record deleted successfully")
            else:
                messagebox.showinfo("Not Found", "No record found to delete")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

def create_label(text, row, column):
    label = tk.Label(root, text=text, bg='skyblue', fg='white')
    label.grid(row=row, column=column, sticky="e")


# Create the main window
root = tk.Tk()
root.title("Hospital Management System")
root.configure(bg='skyblue')  # Set background color of the root window to blue

# Create a title label
title_label = tk.Label(root, text="Hospital Management System", font=("Arial", 20), bg='skyblue', fg='white')
title_label.grid(row=0, column=0, columnspan=4, pady=10, sticky="n")



# Create labels with skyblue background color
create_label("Patient ID", 1, 0)
create_label("First Name", 2, 0)
create_label("Last Name", 3, 0)
create_label("Street", 4, 0)
create_label("City", 5, 0)
create_label("State", 6, 0)
create_label("Zip Code", 7, 0)
create_label("Date of Birth", 8, 0)
create_label("Phone Number", 9, 0)
create_label("Emergency Contact Name", 10, 0)
create_label("Emergency Contact Number", 11, 0)
create_label("Admit Date", 12, 0)
create_label("Patient Type", 13, 0)

patient_id = tk.StringVar()
first_name = tk.StringVar()
last_name = tk.StringVar()
street = tk.StringVar()
city = tk.StringVar()
state = tk.StringVar()
zip_code = tk.StringVar()
date_of_birth = tk.StringVar()
phone_number = tk.StringVar()
emergency_contact_name = tk.StringVar()
emergency_contact_number = tk.StringVar()
admit_date = tk.StringVar()
patient_type = tk.StringVar()

tk.Entry(root, textvariable=patient_id).grid(row=1, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=first_name).grid(row=2, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=last_name).grid(row=3, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=street).grid(row=4, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=city).grid(row=5, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=state).grid(row=6, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=zip_code).grid(row=7, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=date_of_birth).grid(row=8, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=phone_number).grid(row=9, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=emergency_contact_name).grid(row=10, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=emergency_contact_number).grid(row=11, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=admit_date).grid(row=12, column=1, padx=10, pady=2, sticky="w")
tk.Entry(root, textvariable=patient_type).grid(row=13, column=1, padx=10, pady=2, sticky="w")

create_button = tk.Button(root, text="Create Record", command=create_record, bg='skyblue')
read_button = tk.Button(root, text="Read Records", command=read_record, bg='skyblue')
update_button = tk.Button(root, text="Update Record", command=update_record, bg='skyblue')
delete_button = tk.Button(root, text="Delete Record", command=delete_record, bg='skyblue')


# Create buttons for CRUD operations
create_button.grid(row=14, column=0, padx=10, pady=10, sticky="ew")
read_button.grid(row=14, column=1, padx=10, pady=10, sticky="ew")
update_button.grid(row=14, column=2, padx=10, pady=10, sticky="ew")
delete_button.grid(row=14, column=3, padx=10, pady=10, sticky="ew")

# Start the GUI event loop
root.mainloop()
