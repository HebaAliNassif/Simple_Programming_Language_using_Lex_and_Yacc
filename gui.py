from tkinter import *
from PIL import ImageTk, Image
from tkinter import filedialog
from subprocess import Popen,PIPE


root = Tk()
root.title('Home')
root.iconbitmap('coding.ico')
root.configure(bg='#c0c2c0')



#Defining action functions
def execute():
  #code_textbox.delete(0, END)    #To Clear the textbox
  myLabel = Label(root, text='Type your code here..', fg= 'grey')
  myLabel.pack()

code_label = Label(root, text='Code',font= "bold", fg= '#28275C', bg='#c0c2c0')
error_label = Label(root, text='Errors',font= "bold", fg= '#28275C', bg='#c0c2c0')
code_label.grid(row =0, column= 0)
error_label.grid(row =0, column= 5)
def quit():
  p.terminate()
  root.quit()

def browse():
  root.filename = filedialog.askopenfilename(initialdir = 'Desktop', title = 'Select a File', filetypes = (("text files", "*.txt"),('cpp files', '*.cpp')))
  f = open(root.filename, "r")
  code_textbox.insert(END, f.read())

def run():
  errors_textbox.delete("1.0", END)
  strInput=code_textbox.get("1.0",'end-1c')
  byteInput = bytes(strInput, 'utf-8')
  global p 
  p = Popen("compiler.exe",stdin=PIPE,stdout=PIPE)
  out,err=p.communicate(byteInput)
  if (out.decode("utf-8")) == '' :
    out = 'No errors found..'
  errors_textbox.insert(END, out)
#Defining Frames
code_frame = LabelFrame(root, padx=10, pady=10 )
code_frame.grid(row=1, column=0)
code_frame.configure(bg='#c0c2c0')

errors_frame = LabelFrame(root, padx=10, pady=10 )
errors_frame.grid(row=1, column=5)
errors_frame.configure(bg='#c0c2c0')

#table_frame = LabelFrame(root, padx=10, pady=10 )
#table_frame.grid(row=1, column=10)
#table_frame.configure(bg='#c0c2c0')



#Defining Text
code_textbox = Text(code_frame, width=50, bg = '#28275C', fg = '#3badff', insertbackground='white')
code_textbox.grid(row=0, column=0)
#textbox.insert(0, '...')

errors_textbox = Text(errors_frame, width=50, bg = '#28275C', fg = '#3badff')
errors_textbox.grid(row=0, column=0)

#table_textbox = Text(table_frame, width=50, bg = '#28275C', fg = '#3badff')
#table_textbox.grid(row=0, column=0)

#Defining Buttons
#run_img = ImageTk.PhotoImage(Image.open('run.png'))
img2 = Image.open('run2.png')
img2 = img2.resize((50,50), Image.ANTIALIAS)
run_img = ImageTk.PhotoImage(img2)
run_button = Button(code_frame, text = 'RUN',bg= '#28275C',fg = '#FFFFFF', command= run, image = run_img,width= 75, height=50)
run_button.grid(row=5, column=0)

img3 = Image.open('exit1.png')
img3 = img3.resize((70,70), Image.ANTIALIAS)
exit_img = ImageTk.PhotoImage(img3)
exit_button = Button(errors_frame, text = 'EXIT',bg= '#28275C',fg = '#FFFFFF' ,command= root.quit,image=exit_img ,width= 75, height=50)
exit_button.grid(row=5, column=0)

img = Image.open('folder2.png')
img = img.resize((50,50), Image.ANTIALIAS)
browse_img = ImageTk.PhotoImage(img)
browse_button = Button(root, text= 'Browse Files', image= browse_img, bg= '#28275C',fg = '#FFFFFF', command = browse, width= 75, height=50)
browse_button.grid(row = 7, column= 3,)

root.mainloop()