local Box = require('box')

local Menu = {}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Menu:new(settings, lines)
   local menu = {}
   setmetatable(menu,self)
   self.__index = self

   menu.box = Box:new(settings)
   menu.lines = lines
   menu.selected = 1

   return menu
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Menu:renderLine(line,xPos,yPos,selected)
   -- a good default
   -- feel free to overwrite this for something better

   if selected == nil then selected = false end
   
   if selected then
      local font = love.graphics.getFont()
      local width = font:getWidth(line)
      local height = font:getHeight()

      love.graphics.setColor(self.box.settings.borderColor)

      love.graphics.points(xPos+width+2,yPos+height/2+1,
			   xPos+width+3,yPos+height/2,
			   xPos+width+3,yPos+height/2+1,
			   xPos+width+3,yPos+height/2+2)
      
      love.graphics.rectangle('fill',xPos,yPos,width,height)
   end

   love.graphics.setColor(self.box.settings.textColor)
   love.graphics.print(line,xPos,yPos)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Menu:renderCanvas()
   local height = love.graphics.getFont():getHeight() + self.box.settings.padding[1]

   self.box:start()

   love.graphics.clear()
   
   for i = 1,#(self.lines) do
      y = (i-1)*height
      self:renderLine(self.lines[i], 0, y, i == self.selected)
   end

   self.box:finish()
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Menu:prev()
   self.selected = self.selected - 1
   if self.selected == 0 then self.selected = #(self.lines) end

   self:renderCanvas()
end

function Menu:next()
   self.selected = self.selected + 1
   if self.selected > #(self.lines) then self.selected = 1 end

   self:renderCanvas()
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

return Menu
