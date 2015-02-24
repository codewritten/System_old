#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		ttf2png.py 
# 		Purpose:	Convert a TTF to a bitmap font and associate lua file.
# 		Author:		Paul Robson
# 		Created:	30-Dec-14
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

from PIL import Image,ImageFont, ImageDraw,ImageOps
import math

#
#	Class representing a font ; can get information on and render characters onto a Pillow Draw Surface
# 	Also provides mapping facility so chr(1)-chr(31) can be used for accented or other characters.
#	
class FontSource:
	def __init__(self,font,mapping = None,workingSize=48):
		self.font = None
		self.fontName = font 														# the font being used
		self.extendedMapping = mapping or {}										# mapping non ASCII -> other fonts.
		self.workingSize = workingSize 												# base size being generated (scaled obviously)
		self.font = ImageFont.truetype(font+".ttf",workingSize)						# create an instance of the font.
		self.setFontColour((255,255,255,255)) 										# white, no border, no drop shadow.
		self.border = 0
		self.dropShadow = 0

	def __del__(self):
		if self.font != None:														# if font is not None, delete it
			del self.font

	def map(self,character):														# map character to other characters.
		return self.extendedMapping[character] if character in self.extendedMapping else character

	def getMaxHeight(self,startChar,endChar):
		maxHeight = 0 																# figure out the tallest character
		for i in range(startChar,endChar+1): 										# for AGK all characters will be the same
			maxHeight = max(maxHeight,self.size(self.map(chr(i)))[1])				# height in rendering
		return maxHeight

	def setFontColour(self,colour):
		self.fontColour = colour

	def setBorder(self,colour,size):
		self.border = max(1,size*self.workingSize / 100)							# border size
		self.borderColour = colour

	def setDropShadow(self,colour,size):
		self.dropShadow = max(1,size * self.workingSize / 100) 						# drop shadow offset.
		self.dropColour = colour

	def size(self,character):	
		size = self.font.getsize(self.map(character))								# get the character size
		width = size[0] + self.dropShadow + self.border * 2 						# allow for border and drop shadow. 			
		height = size[1] + self.dropShadow + self.border * 2
		return (int(width+0.7),int(height+0.7))

	def render(self,draw,position,character):
		size = self.size(character)													# get the character
		character = self.map(character)												# map character
		if self.dropShadow > 0:														# Draw drop shadow
			draw.text((position[0]+self.border*2+self.dropShadow,position[1]+self.border*2+self.dropShadow), character,font = self.font, fill = self.dropColour)
		if self.border > 0:															# Cheat to draw border
			for i in range(0,46):
				angle = math.radians(i*360/45)
				draw.text((position[0]+self.border+self.border*math.cos(angle),position[1]+self.border+self.border*math.sin(angle)),character,font = self.font, fill = self.borderColour)
																					# The character
		draw.text((position[0]+self.border,position[1]+self.border),character,font = self.font, fill = self.fontColour)
																					# Debugging rectangle
		if True:
			draw.rectangle((position[0],position[1],position[0]+size[0]-1,position[1]+size[1]-1),outline = (255,0,0,255))

fs = FontSource("BroadW",{ "A":"*","*":"A",chr(23):"X" },64)
fs.setFontColour((255,255,0,255))
fs.setBorder((0,0,0,255),6)
fs.setDropShadow((128,128,128,255),6)

image = Image.new("RGBA",(512,800),(255,255,255,0))
draw = ImageDraw.Draw(image)
h = fs.getMaxHeight(32,127)
x = 0
y = 0
for i in range(0,255):
	size = fs.size(chr(i))
	if x + size[0] >= 510:
		x = 0
		y = y + h
	fs.render(draw,(x,y),chr(i))
	x = x + size[0]+2
image.show()
#del image


#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		23 Nov 14 	First working version.
# 
#  ****************************************************************************************************************