local Box = require('box')

local DialogueBox = {}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function DialogueBox:new(boxSettings, message, charactersPerSecond)
   local dialogueBox = {}
   setmetatable(dialogueBox,self)
   self.__index = self

   dialogueBox.box = Box:new(boxSettings)
   
   dialogueBox.message = message
   dialogueBox.lines = dialogueBox.box:getWrappingLines(message,0,0)
   dialogueBox.charactersPerSecond = charactersPerSecond

   dialogueBox.currentTime = 0
   dialogueBox.endTime = message:len() / charactersPerSecond

   dialogueBox.state = 'writing'
   
   return dialogueBox
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function DialogueBox:update(dt)
   if (self.state == 'writing') then
      self.currentTime = self.currentTime + dt
   end
   if (self.currentTime >= self.endTime) then
      self.state = 'done'
   end
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function DialogueBox:render(xPos,yPos)
   if (self.state == 'writing') then
      self.box:start()
      
      love.graphics.clear()
      love.graphics.setColor(self.box.settings.textColor)
      
      charactersToShow = math.floor( self.lines:len() * self.currentTime/self.endTime ) + 1
      love.graphics.print(self.lines:sub(1,charactersToShow),0,0)
      
      self.box:finish()
   end
   self.box:render(xPos,yPos)
end
   
return DialogueBox
