-- Dependencies: Scoretracking.lua

local t = Def.ActorFrame{}

local judges = { -- do not edit
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
	"TapNoteScore_Miss",			
	"HoldNoteScore_Held",
	"HoldNoteScore_LetGo",
}

local gradeString = { -- Grades
	Grade_Tier01 = 'AAAA',
	Grade_Tier02 = 'AAA',
	Grade_Tier03 = 'AA',
	Grade_Tier04 = 'A',
	Grade_Tier05 = 'B',
	Grade_Tier06 = 'C',
	Grade_Tier07 = 'D',
	Grade_Failed = 'F'
};

local judgeString = { -- Text strings for each Judgment types
	TapNoteScore_W1 = 'MA',
	TapNoteScore_W2	= 'PR',
	TapNoteScore_W3	 = 'GR',
	TapNoteScore_W4	= 'GD',
	TapNoteScore_W5	= 'BD',
	TapNoteScore_Miss = 'MS',			
	HoldNoteScore_Held = 'OK',	
	HoldNoteScore_LetGo = 'NG',	
}

local judgeColor = { -- Colors of each Judgment types
	TapNoteScore_W1 = color("#99ccff"),
	TapNoteScore_W2	= HSV(48,0.8,0.95),
	TapNoteScore_W3	 = HSV(160,0.9,0.8),
	TapNoteScore_W4	= HSV(200,0.9,1),
	TapNoteScore_W5	= HSV(320,0.9,1),
	TapNoteScore_Miss = HSV(0,0.8,0.8),			
	HoldNoteScore_Held = HSV(48,0.8,0.95),	
	HoldNoteScore_LetGo = HSV(0,0.8,0.8)
}

local highlightColor = { -- Colors of Judgment highlights
	TapNoteScore_W1 = color('0.2,0.773,0.953,0.5'),
	TapNoteScore_W2	= color("1,0.8,0,0.4"),
	TapNoteScore_W3	 = color("0.4,0.8,0.4,0.4"),
	TapNoteScore_W4	= color("0.35,0.46,0.73,0.5"),
	TapNoteScore_W5	= color("0.78,0.48,1,0.5"),
	TapNoteScore_Miss = color("0.85,0.33,0.33,0.5"),			
	HoldNoteScore_Held = color("1,0.8,0,0.4"),	
	HoldNoteScore_LetGo = color("0.85,0.33,0.33,0.5")
}

local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame
local center1P = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player")); -- For relocating graph/judgecount frame

local spacing = 10 -- Spacing between the judgetypes
local frameWidth = 55 -- Width of the Frame
local frameHeight = ((#judges+1)*spacing)+8 -- Height of the Frame
local judgeFontSize = 0.40 -- Font sizes for different text elements 
local countFontSize = 0.35
local gradeFontSize = 0.45

local frameX1P = 20 -- X position of the frame when center1player is on
local frameXR1P = 50 -- X offset from the very right of the lane when center1player is off
local frameY1P = (SCREEN_HEIGHT*0.62)-5 -- Y Position of the frame

local frameX2P = SCREEN_WIDTH-20-frameWidth -- X position of the frame when center1player is on
local frameXR2P = 50 -- X offset from the very right of the lane when center1player is off
local frameY2P = (SCREEN_HEIGHT*0.62)-5 -- Y Position of the frame


--=========================================================================--
--=========================================================================--
--=========================================================================--

if center1P == false then
	frameX1P = (SCREEN_CENTER_X/2)+(64*(cols/2))+frameXR1P
end

local judgeType = tonumber(GetUserPref("JudgeTypeP1"));

local function judgeText(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = LoadFont("Common normal")..{
		InitCommand=cmd(xy,frameX+5,frameY+5+(index*spacing);zoom,judgeFontSize;halign,0);
		BeginCommand=function(self)
			self:settext(judgeString[judge])
			self:diffuse(judgeColor[judge])
		end;
	}
	return t
end;


local function judgeCount(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,frameWidth+frameX-5,frameY+5+(index*spacing);zoom,countFontSize;horizalign,right);
		BeginCommand=function(self)
			self:settext(0)
		end;
		SetCommand=function(self)
			self:settext(getJudge(PLAYER_1,judge))
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set");
	};
	return t
end

local function judgeHighlight(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = Def.Quad{ --JudgeHighlight
		Name="JudgeHighlight/W1";
		InitCommand=cmd(xy,frameX,frameY+5+(index*spacing);zoomto,frameWidth,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
		JudgmentMessageCommand=function(self,params)
			if params.TapNoteScore == judge then
				self:stoptweening();
				self:visible(true);
				self:diffusealpha(0);
				--self:y(framey+0);
				self:linear(0.1);
				self:diffuse(highlightColor[judge]);
				self:linear(0.5)
				self:diffusealpha(0)
			end
		end;
	}
	return t
end

if judgeType ~= 1 then
	t[#t+1] = Def.Quad{ -- Judgecount Background
		InitCommand=cmd(xy,frameX1P,frameY1P;zoomto,frameWidth,frameHeight;diffuse,color("0,0,0,0.4");horizalign,left;vertalign,top);
	}

	local index = 0 --purely for positional purposes
	-- make judgecount thing
	for k,v in pairs(judges) do
		if judgeType == 3 then
			t[#t+1] = judgeHighlight(PLAYER_1,v,index)
		end
		t[#t+1] = judgeText(PLAYER_1,v,index)
		t[#t+1] = judgeCount(PLAYER_1,v,index)
		index = index +1 
	end

	t[#t+1] = LoadFont("Common Normal") .. { --grade
	        InitCommand=cmd(xy,frameX1P+5,frameY1P+6+(index*spacing);zoom,gradeFontSize;horizalign,left);
			BeginCommand=function(self)
				self:settext(gradeString[getGrade(PLAYER_1)])
			end;
			SetCommand=function(self)
				local temp = GetGradeFromPercent(0)
				if curmaxdp ~= 0 then -- bunch of error messages pop up when getgradefrompercent is called with a undefined value
					temp = getGrade(PLAYER_1)
				end
				self:settext(gradeString[temp])
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set")
	}
end

return t