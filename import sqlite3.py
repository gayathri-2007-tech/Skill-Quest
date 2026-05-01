import sqlite3
import tkinter as tk
from tkinter import messagebox

# DATABASE
conn = sqlite3.connect("emall.db")
cursor = conn.cursor()

cursor.execute("CREATE TABLE IF NOT EXISTS Owner(owner_id INTEGER PRIMARY KEY, owner_name TEXT, phone TEXT, address TEXT)")
cursor.execute("CREATE TABLE IF NOT EXISTS Property(property_id INTEGER PRIMARY KEY, property_name TEXT, location TEXT, price INTEGER, owner_id INTEGER)")
cursor.execute("CREATE TABLE IF NOT EXISTS Customer(customer_id INTEGER PRIMARY KEY, customer_name TEXT, phone TEXT, email TEXT)")
cursor.execute("CREATE TABLE IF NOT EXISTS Booking(booking_id INTEGER PRIMARY KEY, customer_id INTEGER, property_id INTEGER, booking_date TEXT, status TEXT)")

conn.commit()

# MAIN WINDOW
root = tk.Tk()
root.title("Property Management - eMall")
root.geometry("500x500")

# LOGIN FUNCTION
def login():
    if username.get()=="admin" and password.get()=="admin":
        login_frame.pack_forget()
        dashboard()
    else:
        messagebox.showerror("Error","Invalid Login")

# DASHBOARD
def dashboard():
    dash = tk.Frame(root)
    dash.pack()

    tk.Label(dash,text="eMall Property Management",font=("Arial",18)).pack(pady=20)

    tk.Button(dash,text="Add Owner",width=20,command=owner_form).pack(pady=5)
    tk.Button(dash,text="Add Property",width=20,command=property_form).pack(pady=5)
    tk.Button(dash,text="Add Customer",width=20,command=customer_form).pack(pady=5)
    tk.Button(dash,text="Book Property",width=20,command=booking_form).pack(pady=5)

# OWNER FORM
def owner_form():
    win=tk.Toplevel(root)
    win.title("Add Owner")

    tk.Label(win,text="Owner ID").pack()
    oid=tk.Entry(win)
    oid.pack()

    tk.Label(win,text="Owner Name").pack()
    oname=tk.Entry(win)
    oname.pack()

    tk.Label(win,text="Phone").pack()
    phone=tk.Entry(win)
    phone.pack()

    tk.Label(win,text="Address").pack()
    addr=tk.Entry(win)
    addr.pack()

    def save():
        cursor.execute("INSERT INTO Owner VALUES(?,?,?,?)",(oid.get(),oname.get(),phone.get(),addr.get()))
        conn.commit()
        messagebox.showinfo("Success","Owner Added")

    tk.Button(win,text="Save",command=save).pack()

# PROPERTY FORM
def property_form():
    win=tk.Toplevel(root)
    win.title("Add Property")

    tk.Label(win,text="Property ID").pack()
    pid=tk.Entry(win)
    pid.pack()

    tk.Label(win,text="Property Name").pack()
    pname=tk.Entry(win)
    pname.pack()

    tk.Label(win,text="Location").pack()
    loc=tk.Entry(win)
    loc.pack()

    tk.Label(win,text="Price").pack()
    price=tk.Entry(win)
    price.pack()

    tk.Label(win,text="Owner ID").pack()
    owner=tk.Entry(win)
    owner.pack()

    def save():
        cursor.execute("INSERT INTO Property VALUES(?,?,?,?,?)",(pid.get(),pname.get(),loc.get(),price.get(),owner.get()))
        conn.commit()
        messagebox.showinfo("Success","Property Added")

    tk.Button(win,text="Save",command=save).pack()

# CUSTOMER FORM
def customer_form():
    win=tk.Toplevel(root)
    win.title("Add Customer")

    tk.Label(win,text="Customer ID").pack()
    cid=tk.Entry(win)
    cid.pack()

    tk.Label(win,text="Customer Name").pack()
    cname=tk.Entry(win)
    cname.pack()

    tk.Label(win,text="Phone").pack()
    phone=tk.Entry(win)
    phone.pack()

    tk.Label(win,text="Email").pack()
    email=tk.Entry(win)
    email.pack()

    def save():
        cursor.execute("INSERT INTO Customer VALUES(?,?,?,?)",(cid.get(),cname.get(),phone.get(),email.get()))
        conn.commit()
        messagebox.showinfo("Success","Customer Added")

    tk.Button(win,text="Save",command=save).pack()

# BOOKING FORM
def booking_form():
    win=tk.Toplevel(root)
    win.title("Book Property")

    tk.Label(win,text="Booking ID").pack()
    bid=tk.Entry(win)
    bid.pack()

    tk.Label(win,text="Customer ID").pack()
    cid=tk.Entry(win)
    cid.pack()

    tk.Label(win,text="Property ID").pack()
    pid=tk.Entry(win)
    pid.pack()

    tk.Label(win,text="Booking Date").pack()
    date=tk.Entry(win)
    date.pack()

    tk.Label(win,text="Status").pack()
    status=tk.Entry(win)
    status.pack()

    def save():
        cursor.execute("INSERT INTO Booking VALUES(?,?,?,?,?)",(bid.get(),cid.get(),pid.get(),date.get(),status.get()))
        conn.commit()
        messagebox.showinfo("Success","Booking Successful")

    tk.Button(win,text="Book",command=save).pack()

# LOGIN PAGE
login_frame=tk.Frame(root)
login_frame.pack(pady=100)

tk.Label(login_frame,text="Admin Login",font=("Arial",18)).pack()

tk.Label(login_frame,text="Username").pack()
username=tk.Entry(login_frame)
username.pack()

tk.Label(login_frame,text="Password").pack()
password=tk.Entry(login_frame,show="*")
password.pack()

tk.Button(login_frame,text="Login",command=login).pack(pady=10)

root.mainloop()