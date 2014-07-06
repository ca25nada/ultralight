-- find a different way of changing difficulty names. this breaks custom edit names.
local difftype = {
	Difficulty_Beginner 		= 'Novice',
	Difficulty_Easy 			= 'Easy',
	Difficulty_Medium			= 'Medium',
	Difficulty_Hard				= 'Hard',
	Difficulty_Challenge		= 'Expert',
	Difficulty_Edit				= 'Edit'
}

return Def.ActorFrame{
	LoadFont("Common normal") .. {
		InitCommand=cmd(x,30;y,20;shadowlength,0;zoom,0.35;maxwidth,60/0.35);
		BeginCommand=function(self)
			local pn = GAMESTATE:GetMasterPlayerNumber();
			
			-- lazy
			--local text = GAMESTATE:GetCurrentSteps(pn):GetStepsType();
			--text = stepstype[text] or '???'
			--text = GAMESTATE:GetCurrentGame():GetName().."-"..text
			text = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetStepsType())
			text = text:gsub("%_"," ")
			--GAMESTATE:GetCurrentSteps(pn):GetMeter();
			--local text = GAMESTATE:GetCurrentGame():GetName().." "..GAMESTATE:GetCurrentSteps(pn):GetStepsType().." "..GAMESTATE:GetCurrentSteps(pn):GetMeter();
			self:settext(text);
		end;
	};

	LoadFont("Common normal") .. {
		InitCommand=cmd(halign,1;x,103;y,19;shadowlength,0;zoom,0.45;maxwidth,50/0.45);
		BeginCommand=function(self)
			local pn = GAMESTATE:GetMasterPlayerNumber();
			
			local difftext = difftype[GAMESTATE:GetCurrentSteps(pn):GetDifficulty()]
			--ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
			local text = difftext.." "..GAMESTATE:GetCurrentSteps(pn):GetMeter()
			self:settext(text);
		end;
	};	
};

--[[return LoadFont("Common normal") .. {
	InitCommand=cmd(halign,0;x,100;y,100;shadowlength,0);
	BeginCommand=function(self)
		local pn = GAMESTATE:GetMasterPlayerNumber();
		hacking =  string.match(GAMESTATE:GetCurrentGame():GetName(), ".+_(.+)");
		local text = hacking.." "..GAMESTATE:GetCurrentSteps(pn):GetStepsType().." "..GAMESTATE:GetCurrentSteps(pn):GetMeter();
		self:settext(text);
	end;
};--]]
