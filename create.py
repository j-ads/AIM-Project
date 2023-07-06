import tkinter 
from tkinter import font
from tkinter import * 
import sys
import os
import email, smtplib, ssl, getpass, os
import subprocess
import json
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def create():
    global email_text

    subprocess.run("bash create.sh", shell=True)

    os.chdir("terraform")
    frontend = subprocess.run("echo frontend Public IP: >> output.txt && terraform output -raw frontend_ip >> output.txt && echo '' >> output.txt ", shell=True)
    backenda = subprocess.run("echo Backend-A Public IP: >> output.txt && terraform output -raw backenda_ip >> output.txt && echo '' >> output.txt ", shell=True)
    backendb = subprocess.run("echo Backend-B Public IP: >> output.txt && terraform output -raw backendb_ip >> output.txt && echo '' >> output.txt ", shell=True)
    bastion = subprocess.run("echo Bastion Public IP: >> output.txt && terraform output -raw bastion_public_address >> output.txt && echo '' >> output.txt ", shell=True)
    lb_dns = subprocess.run("echo Load Balancer Endpoint DNS: >> output.txt && terraform output -raw lb_dns >> output.txt && echo '' >> output.txt", shell=True)
    web_address = subprocess.run("echo Website Adress: >> output.txt && terraform output -raw website_address >> output.txt && echo '' >> output.txt", shell=True)
    dbpass = subprocess.run("echo Database Password: >> output.txt && terraform output -raw dbpass >> output.txt && echo '' >> output.txt",  shell=True)

    cfile = "output.txt"

    #Create and send Email
    subject = "AWS Credentials"
    body = "The creation of the AWS infrastructure has been completed! Important and crucial information is attached in this email. Please change usernames and passwords for your own security. The text file attached contains the Bastion public IP, your loadbalancer endpoint, website adress and the database password(crucial to change)."
    sender_email = "group11s2c1@gmail.com"
    receiver_email = f"{tb_email.get()}"
    password = 'Group-11'

    # Create a multipart message and set headers
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = subject

    # # Add body to email
    message.attach(MIMEText(body, "plain")) 

     # Open txt file in binary mode
    with open(cfile, "r") as attachment:

    # Email client can usually download this automatically as attachment
        part = MIMEBase("application", "octet-stream")
        part.set_payload(attachment.read())

    # Encode file in ASCII characters to send by email    
    encoders.encode_base64(part)

    # Add header to attachment part
    part.add_header(
        "Content-Disposition",
        f"attachment; filename= {cfile}",
    )

    # Add attachment to message and convert message to string
    message.attach(part)
    text = message.as_string()

    # Log in to server using secure context and send email
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, text)

    email_entry.delete(0, END)
    os.remove(cfile)
    os.chdir("..")

def destroy():
    os.chdir("/home/kali/Escritorio/casestudy-group6/ansible-terra/terraform")
    subprocess.run("terraform destroy -auto-approve", shell=True)
    subprocess.run("rm -rf keys", shell=True)
    os.chdir("..")


#Application and widgets

window=tkinter.Tk()
window.title("Create your own Infrastructure")
window.geometry("450x700")

#labels
tag_general=tkinter.Label(window, text="General", font = "Arial 13 bold")
tag_project_name=tkinter.Label(window, text="Project Name")
tag_email=tkinter.Label(window, text="E-mail")
tag_database=tkinter.Label(window, text="Database", font = "Arial 13 bold")
tag_database_name=tkinter.Label(window, text="Database Name")
tag_database_username=tkinter.Label(window, text="Databasse Username")
tag_application_type=tkinter.Label(window, text="Application Type", font = "Arial 13 bold")
tag_flask=tkinter.Label(window, text="Flask")
tag_java=tkinter.Label(window, text="Java")
tag_ec2=tkinter.Label(window, text="EC2", font = "Arial 13 bold")
tag_t2_micro=tkinter.Label(window, text="t2.micro")
tag_t2_small=tkinter.Label(window, text="t2.small")
tag_t2_medium=tkinter.Label(window, text="t2.medium")
tag_t2_large=tkinter.Label(window, text="t2.large")
tag_git=tkinter.Label(window, text="Git Repository URL")

#botons

boton_create = tkinter.Button(window, text="Create", padx=53, pady=2, command=create)
boton_destroy = tkinter.Button(window, text="Destroy", padx=50, pady=2, command=destroy)
boton_refresh = tkinter.Button(window, text="Refresh", padx=51, pady=2)

#Text_Boxes

tb_project_name=tkinter.Entry(window, text="Project Name", font = "Arial 12")
tb_email=tkinter.Entry(window, text="E-mail", font = "Arial 12")
tb_database_name=tkinter.Entry(window, text="Database Name", font = "Arial 12")
tb_database_username=tkinter.Entry(window, text="Databasse Username", font = "Arial 12")
tb_git=tkinter.Entry(window, text="Git Repository URL", font = "Arial 14")

#Checkboton
cb_flask = Checkbutton (window)
cb_java = Checkbutton (window)
cb_t2_micro = Checkbutton (window)
cb_t2_small = Checkbutton (window)
cb_t2_medium = Checkbutton (window)
cb_t2_large = Checkbutton (window)


#Placement
tag_general.place(x=100, y=5)
tag_project_name.place(x=10, y=50)
tag_email.place(x=10, y=80)
tag_database.place(x=100, y=125)
tag_database_name.place(x=10, y=170)
tag_database_username.place(x=10, y=200)
tag_application_type.place(x=80, y=260)
tag_flask.place(x=10, y=305)
tag_java.place(x=160, y=305)
tag_ec2.place(x=110, y=350)
tag_t2_micro.place(x=10, y=395)
tag_t2_small.place(x=10, y=420)
tag_t2_medium.place(x=10, y=445)
tag_t2_large.place(x=10, y=470)
tag_git.place(x=10, y=530)
#botonPlacement
boton_create.place(x=150, y=580)
boton_destroy.place(x=150, y=620)
boton_refresh.place(x=150, y=660)
#tb_Placement
tb_project_name.place(x=120, y=50)
tb_email.place(x=100, y=80)
tb_database_name.place(x=140, y=170)
tb_database_username.place(x=170, y=200)
tb_git.place(x=160, y=530)
#rb_Placement
cb_flask.place(x=50, y=305)
cb_java.place(x=190, y=305)
cb_t2_micro.place(x=80, y=395)
cb_t2_small.place(x=80, y=420)
cb_t2_medium.place(x=80, y=445)
cb_t2_large.place(x=80, y=470)

window.mainloop()

