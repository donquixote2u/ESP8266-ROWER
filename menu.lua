function MenuNext()
   -- print("skip to next menu item)
   Selected=Selected+2
   if (Selected>#CurrentMenu) then
      Selected=2
   end   
   MenuDisplay(CurrentMenu)       -- menu  
end 
 
function MenuDisplay(Menu)
 menuActive=true
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 dprintl(2,Menu[1])
 local x
 for x=2,#Menu,2 do 
       if(x==Selected) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
   dprintl(1,Menu[x])
  end                   -- end ipairs loop  
end

function MenuSelect()  
    print("item selected")
    Option=Selected+1   -- get option part of menu entry
    if(type(CurrentMenu[Option])=="table") then-- entry is a submenu table so display it
	CurrentMenu=CurrentMenu[Option]
   else					-- entry is an option/command, so action it
     print("action="..CurrentMenu[Option])
	 local f=loadstring(CurrentMenu[Option])
	 f()
     SaveSettings() 
	 CurrentMenu=menu
   end		-- Selected
   Selected=2
   MenuDisplay(CurrentMenu)
end

function CheckButton() -- print("button pressed") 
 Time=tmr.now()
 if(gpio.read(BUTTON1)==0) then
    PressStart=Time
 else   -- button press has ended, test for spurious/short/long
    pulse=Time-PressStart
    print("pulse="..pulse)
    if (pulse<ShortPress) then  -- press < 1/10 sec = noise?
        PressStart=Time            -- reset time check 
        return
    end
    if (pulse>LongPress) then -- long press = Set
        MenuSelect()
    else
        MenuNext()
    end        
 end
end  

 function tdump(t)
  local k,v
  for k,v in pairs(t) do
    if(type(v)=="table") then
        print(k.."=")
        tdump(v)
    else  
        print(k.."="..v)
    end
  end
 end
  
 function SaveSettings() 
  if(file.open("settings.lua","w")) then
     file.writeline("Duration="..Duration)
     file.writeline("Rate="..Rate)
     file.close()
  end   
 end
 
  
-- menu array structure: n*{menu title, [key]=menu entry description, value=menu entry action } (recurse for levels)
menu={"Main","Duration",{"Distance(m)","500m","Duration=500","1000m","Duration=1000","1500m","Duration=1500"},"Pace",{"Strokes/Min","10","Rate=10","20","Rate=20","30","Rate=30"}}
BUTTON1=2   -- // link button 1 to gpio pin D3
ShortPress=100000     -- // timer in us for button short press
LongPress=700000     -- // timer in us for button long press
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'both',CheckButton)
CurrentMenu=menu
-- DEBUG tdump(CurrentMenu) 
-- DEBUG MenuDisplay(CurrentMenu)
Selected=next(CurrentMenu,1)  
menuActive=false

