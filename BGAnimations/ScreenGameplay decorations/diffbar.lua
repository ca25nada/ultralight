t =  Def.ActorFrame{
	LoadActor("diffimg")..{
		Name="diffcolorp1";
		InitCommand=cmd(valign,0;halign,0;x,-15;y,14;)
	};
	
	LoadActor("diffimg")..{
		Name="diffcolorp2";
		InitCommand=cmd(zoom,-1;valign,1;halign,1;x,-15;y,14;diffusealpha,0;)
	};
	
};


function sdiff(pn)
	return GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
end;
 
local function Update(self)
 
t.InitCommand=cmd(SetUpdateFunction,Update);
 
        if GAMESTATE:IsHumanPlayer(PLAYER_1) then
			local p1diff = sdiff(PLAYER_1)
			self:GetChild("diffcolorp1"):diffuse(CustomDifficultyToColor(p1diff))

        else
                self:GetChild("diffcolorp1"):diffusealpha(0);
        end;
 
        if GAMESTATE:IsHumanPlayer(PLAYER_2) then
			local p2diff = sdiff(PLAYER_2)
			self:GetChild("diffcolorp2"):diffuse(CustomDifficultyToColor(p2diff))
        else
                self:GetChild("diffcolorp2"):diffusealpha(0);
        end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);

return t;