local t = Def.ActorFrame {

        LoadFont("Common Normal") .. {
                Name="CurrentTime";
				InitCommand=cmd(x,SCREEN_CENTER_X-205;y,SCREEN_CENTER_Y+1;zoom,0.4);
        };
};

local function Update(self)
t.InitCommand=cmd(SetUpdateFunction,Update);
		if GAMESTATE:IsHumanPlayer(PLAYER_1) then
			self:GetChild("CurrentTime"):settext(GAMESTATE:GetPlayerDisplayName(PLAYER_1));
			--self:GetChild("CurrentTime"):settext(round(GAMESTATE:GetCurMusicSeconds(),2)..'Seconds');
		else
			self:GetChild("CurrentTime"):settext("0");
		end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);

return t;

