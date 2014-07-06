local posx = SCREEN_WIDTH-5
local posy = 35
--[[
local judgecolor = {
	'#eebb00',
	'#eebb00',
	'#eebb00',
	'#66ccff',
	"#e61e25",
	"#e61e25",
	"#c97bff",
	"#c97bff",
	"#ed0972"
}

local lifecolor = {
	'#eebb00',
	'#66ccff',
	"#e61e25",
	"#e61e25",
	"#c97bff",
	"#c97bff",
	"#ed0972"
}
--]]
local t = Def.ActorFrame {
	LoadFont("Common Normal") .. {
		InitCommand=cmd(x,posx-8;y,posy;zoom,0.4;halign,1);
		BeginCommand=function(self)
			text=GetLifeDifficulty();
			self:settextf("Life Difficulty ");
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(x,posx-8;y,posy+10;zoom,0.4;halign,1);
		BeginCommand=function(self)
			text=GetTimingDifficulty();
			self:settextf("Timing Difficulty ");
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(x,posx;y,posy;zoom,0.4;halign,1);
		BeginCommand=function(self)
			text=tonumber(GetLifeDifficulty());
			self:settextf(text);
			self:diffuse(LifeColor(text))
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(x,posx;y,posy+10;zoom,0.4;halign,1);
		BeginCommand=function(self)
			text=tonumber(GetTimingDifficulty());
			self:settextf(text);
			self:diffuse(JudgeColor(text))
			
		end;
	};
};

return t;