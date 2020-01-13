local Box = {}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- utility functions

local function parseSides(sides)
   -- parse CSS-style single-number, two-number, and four-number sides
   -- (border & padding)
   -- return all zeros as a default
   result = { 0,0,0,0 }
   sidesType = type(sides)
   if ( sidesType == 'number' ) then
      result = { sides, sides, sides, sides }
   elseif ( sidesType == 'table' ) then
      if ( #sides == 2 ) then
         topBottom = sides[1]
         leftRight = sides[2]
         result = { topBottom, leftRight, topBottom, leftRight }
      elseif ( #sides == 4 ) then
         top = sides[1]
         left = sides[2]
         bottom = sides[3]
         right = sides[4]
         result = { top, left, bottom, right }
      end
   end

   return result
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function parseSettings(settings)
   -- turn a table containing any of the following:
   --   * border (one, two, or four digits)
   --   * padding (one, two, or four digits)
   --   * borderColor
   --   * backgroundColor
   --   * textColor
   --   * canvasWidth (number)
   --   * canvasHeight (number)
   --   * width (number)(takes precedence over canvasWidth)
   --   * height (number)(takes precedence over canvasHeight)
   -- ...into a table containing _all_ of them, with four-digit
   -- versions of border & padding. Background and border colors
   -- default to black; text color defaults to white.
   
   if ( type(settings) ~= 'table' ) then
      return nil
   end

   local result = {}

   result.border = parseSides(settings.border)
   result.padding = parseSides(settings.padding)

   result.borderColor = { 0,0,0,1 }
   result.backgroundColor = { 0,0,0,1 }
   result.textColor = { 1,1,1,1 }
   
   if ( type(settings.borderColor) == 'table' and ( #(settings.borderColor) == 3 or #(settings.borderColor) == 4 ) ) then
      result.borderColor = settings.borderColor
   end

   if ( type(settings.backgroundColor) == 'table' and ( #(settings.backgroundColor) == 3 or #(settings.backgroundColor) == 4 ) ) then
      result.backgroundColor = settings.backgroundColor
   end

   if ( type(settings.textColor) == 'table' and ( #(settings.textColor) == 3 or #(settings.textColor) == 4 ) ) then
      result.textColor = settings.textColor
   end

   -- parse width
   if ( type(settings.width) == "number" ) then
      result.width = settings.width
      result.canvasWidth = result.width - (result.border[2] + result.border[4] + result.padding[2] + result.padding[4])
   else
      result.canvasWidth = settings.canvasWidth or 0
      result.width = result.canvasWidth + (result.border[2] + result.border[4] + result.padding[2] + result.padding[4])
   end

   -- parse height
   if ( type(settings.height) == "number" ) then
      result.height = settings.height
      result.canvasHeight = result.height - (result.border[1] + result.border[3] + result.padding[1] + result.padding[3])
   else
      result.canvasHeight = settings.canvasHeight or 0
      result.height = result.canvasHeight + (result.border[1] + result.border[3] + result.padding[1] + result.padding[3])
   end

   return result
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             
               
function Box:new(settings)
   local box = {}
   setmetatable(box,self)
   self.__index = self

   box.settings = parseSettings(settings)
   box.canvas = love.graphics.newCanvas(box.settings.canvasWidth, box.settings.canvasHeight)
   return box
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Box:render(xPos, yPos)
   love.graphics.setColor(self.settings.borderColor)
   love.graphics.rectangle('fill',xPos,yPos, self.settings.width, self.settings.height)

   local bgX = xPos + self.settings.border[2]
   local bgY = yPos + self.settings.border[1]
   local bgWidth = self.settings.canvasWidth + self.settings.padding[2] + self.settings.padding[4]
   local bgHeight = self.settings.canvasHeight + self.settings.padding[1] + self.settings.padding[3]

   love.graphics.setColor(self.settings.backgroundColor)
   love.graphics.rectangle('fill', bgX,bgY, bgWidth,bgHeight)

   local canvasX = xPos + self.settings.border[2] + self.settings.padding[2]
   local canvasY = yPos + self.settings.border[1] + self.settings.padding[1]


   love.graphics.setBlendMode("alpha","premultiplied")
   love.graphics.setColor(1,1,1,1)
   love.graphics.draw(self.canvas,canvasX,canvasY)
   love.graphics.setBlendMode("alpha")
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Box:getWrappingLines(printString,xPos,yPos)
   print(printString)
   local font = love.graphics.getFont()
   local height = font:getHeight() + self.settings.padding[1]

   local lines = ''
   local currentLine = ''
   
   
   for word in printString:gmatch('[^ ]+') do
      print(word)
      local line = currentLine..word
      if font:getWidth(line) <= (self.settings.canvasWidth-xPos) then
	 currentLine = line..' '
      else
	 lines = lines..currentLine..'\n'
	 currentLine=word..' '
      end
   end

   lines = lines..currentLine
   
   print(lines)
   return lines
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Box:start()
   local r, g, b, a = love.graphics.getColor()
   self.colorToRestore = { r,g,b,a }
   self.canvasToRestore = love.graphics.getCanvas()
   love.graphics.setCanvas(self.canvas)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Box:finish()
   love.graphics.setCanvas(self.canvasToRestore)
   love.graphics.setColor(self.colorToRestore)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

return Box
