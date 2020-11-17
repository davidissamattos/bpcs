# -*- coding: utf-8 -*-
"""
Created on Fri Nov 06 17:27:19 2015

@author: Hanshu Zhang zhanmg.180@wright.edu
"""

##get the number of image that satisfy the size in pixel

from PIL import Image 
import os
from __future__ import division


# get all the names of image from directroy 

#images download from https://groups.csail.mit.edu/vision/SUN/ 
mypath = "C:\Users\w039hxz\Downloads\SUNAttributeDB_Images.tar\SUNAttributeDB_Images"


# new file root
mynewpath="C:\Users\w039hxz\Documents\ScenePerception\SUN397.tar\satisfy43ratio"


f = []
names =[]
roots = []

for root,dirs,files in os.walk(mypath):
    for name in files:
        names.append(name)
        f.append(os.path.join(root,name))
        roots.append(root)

size=[]        

# get the image size
for i in range(len(f)):
   im=Image.open(f[i])
   size.append(im.size)



## get the satfisfied                               
   
count = 0 
for width,height in size:
    if width>=1024 and height>=768 and width/height == 4.0/3.0:
        count += 1
print count 


imindex=[index for index,(width,height) in enumerate (size) if width>=1024 and height >=768 and width/height == 4.0/3.0]



for nu in range(0,len(imindex)):
    image=Image.open(f[imindex[nu]])
    image=image.resize((1024,768))
    if image.mode !="RGB":
        image=image.convert("RGB")
    roots_title=roots[imindex[nu]][61:] 
    if "\\" in roots_title:
        roots_title=roots_title.replace("\\","_")

    image.save(mynewpath+"\\"+roots_title+"_"+names[imindex[nu]],"jpeg")



