local t = LoadFallbackB();

t[#t+1] = LoadActor("judgecount")..{
}

t[#t+1] = LoadActor("lifejudgedisplay")..{
}

t[#t+1] = LoadActor("diffbar")..{
}

t[#t+1] = LoadActor("concstepstype")..{
};

t[#t+1] = LoadActor("warning")..{
};

--t[#t+1] = StandardDecorationFromFile( "StageFrame", "StageFrame" );

t[#t+1] = LoadActor("_warning")..{
	InitCommand=cmd(Center);
	OnCommand=cmd(diffusealpha,0);
	ShowDangerAllMessageCommand=cmd(stoptweening;accelerate,0.3;diffusealpha,1);
	HideDangerAllMessageCommand=cmd(stoptweening;accelerate,0.3;diffusealpha,0);
};

t[#t+1] = StandardDecorationFromFile( "NowPlaying", "NowPlaying" );
t[#t+1] = StandardDecorationFromFile( "StageDisplay", "StageDisplay" );

----------------------------------------------------------------------
--------------------------------------------------------------------
-- music progress bar?
-- Song Meter Display
t[#t+1] = Def.ActorFrame{
	Name="SongMeterDisplayFrame";
	--InitCommand=cmd(xy,400,SCREEN_HEIGHT/2+15;shadowlength,1;);
	InitCommand=cmd(xy,SCREEN_WIDTH/2,SCREEN_HEIGHT-3;shadowlength,1;halign,0;valign,1);
	Def.Quad{
		Name="LineBG";
		--InitCommand=cmd(zoomto,6,(SCREEN_HEIGHT*0.6)-2;diffuse,color("0,0,0,0.375"););
		--InitCommand=cmd(zoomto,(SCREEN_WIDTH*0.6)-2,6;diffuse,color("0,0,0,0.375"););
		--InitCommand=cmd(zoomto,(SCREEN_WIDTH*0.35)-2,4;diffuse,color("1,1,1,0.5"););
		InitCommand=cmd(zoomto,SCREEN_WIDTH,4;diffuse,color("1,1,1,0.5"););
	};
	--[[Def.Quad{
		Name="LineMain";
		--InitCommand=cmd(zoomto,1,SCREEN_HEIGHT*0.6;diffusealpha,0.75;);
		InitCommand=cmd(zoomto,SCREEN_WIDTH*0.6,1;diffusealpha,0.75;);
	};]]--
	Def.Quad{
		Name="LineLeft";
		InitCommand=cmd(x,0-SCREEN_WIDTH;zoomto,1,6;diffusealpha,0.75;);
		--InitCommand=cmd(x,-(SCREEN_WIDTH*0.35)/2;zoomto,1,6;diffusealpha,0.75;);

	};
	Def.Quad{
		Name="LineRight";
		InitCommand=cmd(x,SCREEN_WIDTH;zoomto,1,6;diffusealpha,0.75;);
		--InitCommand=cmd(x,(SCREEN_WIDTH*0.35)/2;zoomto,1,6;diffusealpha,0.75;);
	};
	
	Def.SongMeterDisplay {
		InitCommand=cmd(SetStreamWidth,SCREEN_WIDTH);
		--InitCommand=cmd(SetStreamWidth,SCREEN_WIDTH*0.35);
		Stream=Def.Actor{};
		Tip=Def.ActorFrame{
			Def.Quad{
				InitCommand=cmd(zoomto,6,6;diffuse,CustomDifficultyToColor(GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty());rotationz,45;pulse;effectclock,'beatnooffset';effectmagnitude,1,0.75,1);
			};
			Def.Quad{
				InitCommand=cmd(zoomto,4,4;diffuse,HSV(0,0,1);rotationz,45;pulse;effectclock,'beatnooffset';effectmagnitude,1,0.75,1);
			};
		};
	};

};



--- blah
--t[#t+1] = StandardDecorationFromFile( "LifeFrame", "LifeFrame" );
--t[#t+1] = StandardDecorationFromFile( "ScoreFrame", "ScoreFrame" );

--[[
if ShowStandardDecoration("ModIconRows") then
	for pn in ivalues(PlayerNumber) do
		local t2 = Def.ModIconRow {
				InitCommand=cmd(Load,"ModIconRowGameplay"..ToEnumShortString(pn),pn);
			};	
		t[#t+1] = StandardDecorationFromTable( "ModIconRow" .. ToEnumShortString(pn), t2 );
	end
end
--]]

t[#t+1] = StandardDecorationFromFile( "BPMDisplay", "BPMDisplay" );

-- sigh. I personally don't like having to do this to get machine score working,
-- so imagine how all the people who DON'T know as much as I do about theming
-- who will run into this.
--[[
if not GAMESTATE:IsCourseMode() then
	t[#t+1] = Def.Actor{
		Name="JudgmentController";
		JudgmentMessageCommand = function(self, params)
			Scoring[GetUserPref("UserPrefScoringMode")](params, 
				STATSMAN:GetCurStageStats():GetPlayerStageStats(params.Player))
		end;
	};
end;
--]]


-- speedkills
-- proof of concept for in-gameplay speed change
-- [ja] �v���C���Ƀn�C�X�s��ύX����T�O���؃R�[�h
local speedkills_Initialized = false;
local speedMode = {
	PlayerNumber_P1 = 'x',
	PlayerNumber_P2 = 'x',
};
local maxBPM = 0;
local targetBPM = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0,
};
if not GAMESTATE:IsCourseMode() then
t[#t+1] = Def.ActorFrame {
	OnCommand = function(self)
		-- Get max BPM for M-Mod HACK
		-- [ja] ��q��HACK�̂��߂ɍő�BPM��擾
		-- TODO: Support for course mode
		local song = GAMESTATE:GetCurrentSong();

		local displayBPMs = {0, 0}; -- Min, Max
		if not song:IsDisplayBpmSecret() then
			displayBPMs = song:GetDisplayBpms();
			displayBPMs[1] = math.max(0, displayBPMs[1]);
			displayBPMs[2] = math.max(0, displayBPMs[2]);
		end;

		if displayBPMs[2] < 0.5 then
			displayBPMs = song:GetTimingData():GetActualBPM();
		end;

		maxBPM = displayBPMs[2];

		local MModHighCap = THEME:GetMetric("Player", "MModHighCap");
		if MModHighCap >= 0.5 then
			maxBPM = math.min(maxBPM, MModHighCap);
		end;

		local pns = {
			'PlayerNumber_P1',
			'PlayerNumber_P2',
		};

		-- Get speed mode (x/m/C) and target BPM
		-- [ja] �n�C�X�s�̃��[�h (x/m/C) �ƖڕWBPM��擾
		for _,v in pairs(pns) do
			if GAMESTATE:IsSideJoined(v) then
				local ps = GAMESTATE:GetPlayerState(v);
				local po = ps:GetPlayerOptions("ModsLevel_Preferred");
				local modstring = ps:GetPlayerOptionsString("ModsLevel_Preferred");

				local XMod = po:XMod() or 0;
				local MMod = po:MMod() or 0;
				--local MMod = tonumber(string.match(modstring, "[Mm](%d+)")) or 0;

				-- [ja] �R�[�h��������GetCMod()�͐��������삵�Ȃ��H
				-- local CMod = po:GetCMod();
				
				local CModString = string.match(modstring, "[Cc](%d+)") or "0";
				local CMod = tonumber(CModString);

				speedMode[v] = 'x';
				targetBPM[v] = XMod * maxBPM;

				if MMod >= 0.5 then
					speedMode[v] = 'm';
					targetBPM[v] = MMod;
				end;

				if CMod >= 0.5 then
					speedMode[v] = 'C';
					targetBPM[v] = CMod;
				end;

				SCREENMAN:SystemMessage(string.format("%s: Speed Mode: %s Target BPM: %.0f ", v, speedMode[v], XMod));
			end;
		end;

		speedkills_Initialized = true;
	end;
	CodeMessageCommand = function(self, params)
		local pn = params.PlayerNumber;
		local ps = GAMESTATE:GetPlayerState(pn);
		local po = ps:GetPlayerOptions("ModsLevel_Preferred");

		if not speedkills_Initialized then
			return;
		end;

		if speedMode[pn] == 'x' then
			-- X-Mod
			local speed = po:XMod() or 0;

			--local speed = 0;
			speed = math.floor(speed * 4 + 0.5) / 4;

			local speedDelta = 0;
			if params.Name == "SpeedUp" then
				speedDelta = 0.25;
			elseif params.Name == "SpeedDown" then
				speedDelta = -0.25;
			end;

			speed = math.max(0.5, math.min(speed + speedDelta, 10.0));
			targetBPM[pn] = speed * maxBPM;

			local modstring = ps:GetPlayerOptionsString("ModsLevel_Preferred");

			-- HACK: Add "default, " to prevent crash
			-- [ja] �N���b�V����h�����߂Ɂudefault, �v��t��������
			modstring = "default, " .. modstring;
			modstring = modstring .. ", " .. speed .. "x";

			ps:SetPlayerOptions("ModsLevel_Preferred", modstring);

			-- 1.00x
			local xString = string.format("%.2fx", speed);
			-- 1.00x -> 1.0x
			xString = string.gsub(xString, "(%d+%.%d)0x", "%1x");
			-- 1.0x -> 1x
			xString = string.gsub(xString, "(%d+)%.0x", "%1x");

			SCREENMAN:SystemMessage(string.format("%s: %s (m%.0f)", pn, xString, targetBPM[pn]));
		else
			-- C-Mod and M-Mod
			local speed = targetBPM[pn];
			speed = math.floor(speed / 10 + 0.5) * 10;

			local speedDelta = 0;
			if params.Name == "SpeedUp" then
				speedDelta = 10;
			elseif params.Name == "SpeedDown" then
				speedDelta = -10;
			end;

			speed = math.max(100, math.min(speed + speedDelta, 2000));
			targetBPM[pn] = speed;

			local modstring = ps:GetPlayerOptionsString("ModsLevel_Preferred");

			-- HACK: Add "default, " to prevent crash
			-- [ja] �N���b�V����h�����߂Ɂudefault, �v��t��������
			modstring = "default, " .. modstring;

			if speedMode[pn] == 'm' then
				-- HACK: Add X-Mod, because M-Mod cannot be applied in gameplay
				-- [ja] M-Mod�̓v���C���ɂ͂��̂܂ܓK�p����Ȃ��̂�X-Mod��t��������
				modstring = modstring .. ", " .. (targetBPM[pn] / maxBPM) .. 'x';
			end;

			modstring = modstring .. ", " .. speedMode[pn] .. targetBPM[pn];

			ps:SetPlayerOptions("ModsLevel_Preferred", modstring);

			-- 1.00x
			local xString = string.format("%.2fx", targetBPM[pn] / maxBPM);
			-- 1.00x -> 1.0x
			xString = string.gsub(xString, "(%d+%.%d)0x", "%1x");
			-- 1.0x -> 1x
			xString = string.gsub(xString, "(%d+)%.0x", "%1x");

			local format = "%s: %s%.0f";
			if speedMode[pn] == 'm' then
				format = "%s: %s%.0f (%s)";
			end;

			SCREENMAN:SystemMessage(string.format(format, pn, speedMode[pn], targetBPM[pn], xString));
		end;
	end;
};
end;

return t;