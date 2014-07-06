local t = Def.ActorFrame {
        LoadFont("Common Normal") .. {
                Name="Player1LifeText";
                --InitCommand=cmd(halign,0;x,SCREEN_CENTER_X-200;y,SCREEN_CENTER_Y-211;zoom,0.4;shadowlength,1);
				InitCommand=cmd(halign,0;x,5;y,SCREEN_TOP+5;zoom,0.45;shadowlength,0);
				BeginCommand=function(self)
					self:settext('Life:')
				end;
        };
        LoadFont("Common Normal") .. {
                Name="Player2LifeText";
                InitCommand=cmd(x,SCREEN_CENTER_X-205;y,SCREEN_CENTER_Y-211;zoom,0.4);
        };
        LoadFont("Common Normal") .. {
                Name="Player1Life";
                --InitCommand=cmd(halign,0;x,SCREEN_CENTER_X-200;y,SCREEN_CENTER_Y-211;zoom,0.4;shadowlength,1);
				InitCommand=cmd(halign,0;x,28;y,SCREEN_TOP+5;zoom,0.45;shadowlength,0);
        };
        LoadFont("Common Normal") .. {
                Name="Player2Life";
                InitCommand=cmd(x,SCREEN_CENTER_X-205;y,SCREEN_CENTER_Y-211;zoom,0.4);
        };
};
 
function PLife(pn)
	return SCREENMAN:GetTopScreen():GetLifeMeter(pn):GetLife();
end;
 
local function Update(self)
 
t.InitCommand=cmd(SetUpdateFunction,Update);
 
        if GAMESTATE:IsHumanPlayer(PLAYER_1) then
			self:GetChild("Player1Life"):settextf("%.0f%%", PLife(PLAYER_1)*100);
			if PLife(PLAYER_1)*100 < 30 and PLife(PLAYER_1)*100 ~= 0 then -- replace with lifemeter danger later
				self:GetChild("Player1LifeText"):diffuse(color("1,1,1,1"))
				self:GetChild("Player1Life"):diffuseshift()
				self:GetChild("Player1Life"):effectcolor1(1,1,1,1)
				self:GetChild("Player1Life"):effectcolor2(1,0.9,0.9,0.5)
				self:GetChild("Player1Life"):effectperiod(0.9*PLife(PLAYER_1)+0.15)
			elseif PLife(PLAYER_1)*100 == 100 then -- replace with lifemeter hot later
				self:GetChild("Player1Life"):glowshift()
				self:GetChild("Player1Life"):effectcolor2(1,1,1,0.0)
				self:GetChild("Player1Life"):effectcolor1(1,1,1,0.3)
				self:GetChild("Player1Life"):effectperiod(0.1)
			elseif PLife(PLAYER_1)*100 <= 0 then
				self:GetChild("Player1Life"):stopeffect()
				self:GetChild("Player1LifeText"):diffuse(color("0,0,0,1"))
				self:GetChild("Player1Life"):diffuse(color("0,0,0,1"))
			else
				self:GetChild("Player1LifeText"):stopeffect()
				self:GetChild("Player1Life"):stopeffect()
				self:GetChild("Player1LifeText"):diffuse(color("1,1,1,1"))
				self:GetChild("Player1Life"):diffuse(color("1,1,1,1"))
			end;
        else
                self:GetChild("Player1Life"):settext("");
        end;
 
        if GAMESTATE:IsHumanPlayer(PLAYER_2) then
            self:GetChild("Player2Life"):settextf("Life: %.0f%%", PLife(PLAYER_2)*100);
			if PLife(PLAYER_2)*100 <= 30 and PLife(PLAYER_2)*100 ~= 0 then
				self:GetChild("Player2LifeText"):diffuse(color("1,1,1,1"))
				self:GetChild("Player2Life"):diffuseshift()
				self:GetChild("Player2Life"):effectcolor1(1,1,1,1)
				self:GetChild("Player2Life"):effectcolor2(1,0.9,0.9,0.5)
				self:GetChild("Player2Life"):effectperiod(0.9*PLife(PLAYER_2)+0.15)
			elseif PLife(PLAYER_2)*100 == 100 then
				self:GetChild("Player2Life"):glowshift()
				self:GetChild("Player2Life"):effectcolor2(1,1,1,0.0)
				self:GetChild("Player2Life"):effectcolor1(1,1,1,0.3)
				self:GetChild("Player2Life"):effectperiod(0.1)
			elseif PLife(PLAYER_2)*100 <= 0 then
				self:GetChild("Player2Life"):stopeffect()
				self:GetChild("Player2LifeText"):diffuse(color("0,0,0,1"))
				self:GetChild("Player2Life"):diffuse(color("0,0,0,1"))
			else
				self:GetChild("Player2LifeText"):stopeffect()
				self:GetChild("Player2Life"):stopeffect()
				self:GetChild("Player2LifeText"):diffuse(color("1,1,1,1"))
				self:GetChild("Player2Life"):diffuse(color("1,1,1,1"))


				
			end;
        else
                self:GetChild("Player2Life"):settext("");
        end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);
 
return t;