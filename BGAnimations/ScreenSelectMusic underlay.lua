local bottomBoxSizeX = SCREEN_CENTER_X*0.625;
local bottomBoxSizeY = SCREEN_CENTER_Y*0.2;


		




local t = Def.ActorFrame{
	--V3
	--No Background Image
	--Source https://github.com/Jousway/Stepmania-Zpawn/blob/master/SM5/Themes/default_JousEdit_ScreenSelectMusic/BGAnimations/ScreenSelectMusic%20background.lua
	Def.ActorFrame {
		LoadActor(THEME:GetPathB("ScreenWithMenuElements","background/Default"));
		--[[LoadFont("Common Normal") .. {
			OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,4;diffuse,1,1,1,1;strokecolor,Color("Black"));
			CurrentSongChangedMessageCommand=function(self)
				if GAMESTATE:GetCurrentSong() then
					if GAMESTATE:GetCurrentSong():GetBackgroundPath() then
						self:settext("");
					else
						self:settext("No Background");
					end;
				else
					self:settext("");
				end;
			end;
		};--]]
	};
	
	--Load Song Background
	Def.Sprite {
		OnCommand=cmd(linear,0.3;diffusealpha,0);
		OffCommand=cmd(linear,0.3;diffusealpha,0);
		CurrentSongChangedMessageCommand=function(self)
			self:halign(0);
			self:x(0);
			self:y(SCREEN_CENTER_Y);
			self:finishtweening();
			self:sleep(0.5);

			self:queuecommand("ModifySongBackground");
			self:diffusealpha(0)
			self:linear(0.5)

			end;
		ModifySongBackgroundCommand=function(self)
			if GAMESTATE:GetCurrentSong() then
				if GAMESTATE:GetCurrentSong():GetBackgroundPath() then
					self:finishtweening()
					self:LoadBackground(GAMESTATE:GetCurrentSong():GetBackgroundPath());
					self:scaletofit(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
					self:linear(0.5)
					self:diffusealpha(0.6)
					self:visible(true);
				else
					self:visible(true);
					--self:visible(false);
				end;
			else
				self:visible(true);
				--self:visible(false);
			end;
		end;	
	};
	-- End



	--[[LoadSongBackground()..{
		Condition=not GAMESTATE:IsCourseMode();
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffusealpha,0.4);
	};
	Def.Quad{
		InitCommand=cmd(draworder,-150;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,color("#ffffff"));
	};]]--
	
	--[[
	Def.Quad{
		InitCommand=cmd(x,20;y,30;zoomto,265,370;diffuse,color("#FFFFFF");diffusealpha,(0.70);halign,0;valign,0;);
	};
	--]]
	

--	Def.Quad{
--		InitCommand=cmd(zoomto,SCREEN_HEIGHT,SCREEN_WIDTH-100;y,220;x,551;diffusetopedge,HSV(0,0,1));
--	};
	-- top section (below the banner); if anything

	-- vertical seperator
	Def.Quad{
		InitCommand=cmd(halign,1;x,SCREEN_WIDTH-330;y,SCREEN_CENTER_Y;zoomto,2,SCREEN_HEIGHT;diffuserightedge,HSV(0,0.2,1););
		OnCommand=cmd(cropbottom,1;sleep,0.2;bouncebegin,0.2;cropbottom,0);
		OffCommand=cmd(visible,false);
		--OffCommand=cmd(linear,0.5;croptop,1);
	};

	-- bottom section
	-- was xy,(SCREEN_CENTER_X*0.475),SCREEN_CENTER_Y*1.85
	Def.Quad{
		InitCommand=cmd(xy,(SCREEN_CENTER_X*0.475)-(bottomBoxSizeX/4),SCREEN_CENTER_Y*1.85;
			zoomto,(bottomBoxSizeX/2),bottomBoxSizeY;shadowlengthx,2;shadowlengthy,3;
		);
		BeginCommand=cmd(playcommand,"UpdatePlayer");
		OffCommand=cmd(bouncebegin,0.25;addy,SCREEN_CENTER_Y*0.45);
		UpdatePlayerCommand=function(self)
			if GAMESTATE:IsHumanPlayer(PLAYER_1) then
				self:diffuse( PlayerColor(PLAYER_1) );
				self:shadowcolor( Brightness(PlayerColor(PLAYER_1),0.75) );
			else
				self:diffuse( HSV(0,0,0.4) );
				self:shadowcolor( HSV(0,0,0.25) );
			end;
		end;
		PlayerJoinedMessageCommand=function(self,param)
			if param.Player == PLAYER_1 then
				self:playcommand("UpdatePlayer");
			end;
		end;
		PlayerUnjoinedMessageCommand=function(self,param)
			if param.Player == PLAYER_1 then
				self:playcommand("UpdatePlayer");
			end;
		end;
	};
	Def.Quad{
		InitCommand=cmd(xy,(SCREEN_CENTER_X*0.475)+(bottomBoxSizeX/4),SCREEN_CENTER_Y*1.85;
			zoomto,(bottomBoxSizeX/2),bottomBoxSizeY;shadowlengthx,2;shadowlengthy,3;
		);
		BeginCommand=cmd(playcommand,"UpdatePlayer");
		OffCommand=cmd(bouncebegin,0.25;addy,SCREEN_CENTER_Y*0.45);
		UpdatePlayerCommand=function(self)
			if GAMESTATE:IsHumanPlayer(PLAYER_2) then
				self:diffuse( PlayerColor(PLAYER_2) );
				self:shadowcolor( Brightness(PlayerColor(PLAYER_2),0.75) );
			else
				self:diffuse( HSV(0,0,0.4) );
				self:shadowcolor( HSV(0,0,0.25) );
			end;
		end;
		PlayerJoinedMessageCommand=function(self,param)
			if param.Player == PLAYER_2 then
				self:playcommand("UpdatePlayer");
			end;
		end;
		PlayerUnjoinedMessageCommand=function(self,param)
			if param.Player == PLAYER_2 then
				self:playcommand("UpdatePlayer");
			end;
		end;
	};

	Def.Quad{
		InitCommand=cmd(xy,(SCREEN_CENTER_X*0.475),(SCREEN_CENTER_Y*1.85)-(bottomBoxSizeY/3);zoomto,bottomBoxSizeX,bottomBoxSizeY*0.35;fadetop,0.25;fadebottom,1;blend,Blend.Add;diffusealpha,0.25);
		OffCommand=cmd(bouncebegin,0.25;addy,SCREEN_CENTER_Y*0.45);
	};
};

return t;

--[[local t = Def.ActorFrame {};

local function Update(self)
					
	if GAMESTATE:IsHumanPlayer(PLAYER_1) then
	
		local displayp1 = GetUserPref("SpeedDisplayP1");
		
		local speedp1;
		if GetUserPrefN("SpeedModP1") ~= nil then
			speedp1 = (GetUserPrefN("SpeedModP1")+1)*50;
		else
			speedp1 = 100;
		end;
		
		local optionsp1 = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString("ModsLevel_Preferred");
		if displayp1 == "3" then
			GAMESTATE:GetPlayerState(PLAYER_1):SetPlayerOptions('ModsLevel_Preferred', optionsp1 .. "," .. speedp1/AverageBPM() .."x");
		end;
	end;
	if GAMESTATE:IsHumanPlayer(PLAYER_2) then
	
		local displayp2 = GetUserPref("SpeedDisplayP2");
		
		local speedp2;
		if GetUserPrefN("SpeedModP2") ~= nil then
			speedp2 = (GetUserPrefN("SpeedModP2")+1)*50;
		else
			speedp2 = 100;
		end;
		
		local optionsp2 = GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptionsString("ModsLevel_Preferred");
		if displayp2 == "3" then
			GAMESTATE:GetPlayerState(PLAYER_2):SetPlayerOptions('ModsLevel_Preferred', optionsp2 .. "," .. speedp2/AverageBPM() .."x");
		end;
	end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);

return t;
]]--
