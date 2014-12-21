 local t = Def.ActorFrame{};
 local show = false;
 
 -- iForgot where I stole it from
 -- splits a string into a table
function split(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end

local bpmtime = GAMESTATE:GetCurrentSong():GetTimingData():GetBPMsAndTimes();
local framex = SCREEN_CENTER_X+(64*6)/2;
local framey = 5;
local temp = {'0','0'};
local curbeat = 0;
local bpmdiff;

t[#t+1] = LoadFont("Common normal")..{
	Name="Test";
	InitCommand=cmd(xy,framex,framey;zoom,1;halign,1;zoom,0.4);
	BeginCommand=function(self)
		self:settext(temp[2].."BPM in "..temp[1]-curbeat.."beats")
	end;

};

--[[
t[#t+1] = LoadFont("Common normal")..{
	Name="Test2";
	InitCommand=cmd(xy,framex,framey;zoom,1;halign,0);
	BeginCommand=function(self)
		self:settext(curbeat)
	end;
};
--]]

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
 	curbeat = GAMESTATE:GetSongPosition():GetSongBeat();
 	if  #bpmtime >=1 then
		temp = split("=",bpmtime[1])
		if(curbeat > tonumber(temp[1])) then
			table.remove(bpmtime,1)
		end;
		bpmdiff = tonumber(temp[2])-GAMESTATE:GetSongPosition():GetCurBPS()*60;
		if bpmdiff >= 0 then
			bpmdiff = string.format("+%.2f",bpmdiff);
		else
			bpmdiff = string.format("%.2f",bpmdiff);
		end;

		if tonumber(temp[1]-curbeat)/GAMESTATE:GetSongPosition():GetCurBPS() < 5 then
			self:GetChild("Test"):settextf("%.2f BPM(%s) in %.2f Seconds",tonumber(temp[2]),bpmdiff,tonumber(temp[1]-curbeat)/GAMESTATE:GetSongPosition():GetCurBPS()); 
		else
			self:GetChild("Test"):settext("")
		end;
	else -- no more speedchanges left
		self:GetChild("Test"):settext("")
	end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);

if show then
	return t;
else
	return Def.ActorFrame{};
end;