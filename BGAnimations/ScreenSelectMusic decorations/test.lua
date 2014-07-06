 
-- todo - again, clean up the huge "aaaa" actor or w/e it was.



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

--Given a difference in scores, concatenate "+" if number is 0 or positive, if not, just return the number.
function diffstring(scorediff)
	if scorediff >= 0 then
		return '+'..scorediff
	else
		return scorediff
	end;
end;

--Return letter grades based on tier, assumes the standard 8 tier grade used in SM.
function gradestring(tier)
	if tier == "Grade_Tier01" then
		return 'AAAA'
	elseif tier == "Grade_Tier02" then
		return 'AAA'
	elseif tier == "Grade_Tier03" then
		return 'AA'
	elseif tier == "Grade_Tier04" then
		return 'A'
	elseif tier == "Grade_Tier05" then
		return 'B'
	elseif tier == "Grade_Tier06" then
		return 'C'
	elseif tier == "Grade_Tier07" then
		return 'D'
	elseif tier == 'Grade_Failed' then
		return 'F'
	else
		return ''
	end;
end;

function getgrades(dppercent,gradetier)
	if dppercent > gradetier["Grade_Tier03"] then --AA
		return "Grade_Tier02"
	elseif dppercent > gradetier["Grade_Tier04"] then --A
		return "Grade_Tier03"
	elseif dppercent > gradetier["Grade_Tier05"] then -- B
		return "Grade_Tier04"
	elseif dppercent > gradetier["Grade_Tier06"] then --C
		return "Grade_Tier05"
	else --D
		return "Grade_Tier06"
	end;
end;

local scoreweight =  {
	TapNoteScore_W1				= 2,--PREFSMAN:GetPreference("GradeWeightW1"),					--  2
	TapNoteScore_W2				= 2,--PREFSMAN:GetPreference("GradeWeightW2"),					--  2
	TapNoteScore_W3				= 1,--PREFSMAN:GetPreference("GradeWeightW3"),					--  1
	TapNoteScore_W4				= 0,--PREFSMAN:GetPreference("GradeWeightW4"),					--  0
	TapNoteScore_W5				= -4,--PREFSMAN:GetPreference("GradeWeightW5"),					-- -4
	TapNoteScore_Miss			= -8,--PREFSMAN:GetPreference("GradeWeightMiss"),				-- -8
	HoldNoteScore_Held			= 6,--PREFSMAN:GetPreference("GradeWeightHeld"),				--  6
	TapNoteScore_HitMine		= -8,--PREFSMAN:GetPreference("GradeWeightHitMine"),				-- -8
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("GradeWeightLetGo"),				--  0
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit	= 0,--PREFSMAN:GetPreference("GradeWeightCheckpointHit"),		--  0
	TapNoteScore_CheckpointMiss = 0,--PREFSMAN:GetPreference("GradeWeightCheckpointMiss"),		--  0
};

local gradetier = {
	Grade_Tier01 = THEME:GetMetric("PlayerStageStats", "GradePercentTier01"), -- AAAA
	Grade_Tier02 = THEME:GetMetric("PlayerStageStats", "GradePercentTier02"), -- AAA
	Grade_Tier03 = THEME:GetMetric("PlayerStageStats", "GradePercentTier03"), -- AA
	Grade_Tier04 = THEME:GetMetric("PlayerStageStats", "GradePercentTier04"), -- A
	Grade_Tier05 = THEME:GetMetric("PlayerStageStats", "GradePercentTier05"), -- B
	Grade_Tier06 = THEME:GetMetric("PlayerStageStats", "GradePercentTier06"), -- C
	Grade_Tier07 = THEME:GetMetric("PlayerStageStats", "GradePercentTier07"), -- D
};

local stypetable = { -- Shorthand Versions of ClearType
	[1]="Marv F-Combo",
	[2]="Whiteflag",
	[3]="SDP",
	[4]="Perf F-Combo",
	[5]="Blackflag",
	[6]="SDG",
	[7]="F-Combo",
	[8]="Missflag",
	[9]="SDCB",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Rainbowflag",
	[15]="Ragequit"
};

local typetable = { -- ClearType texts
	[1]="Marvelous Full Combo",
	[2]="Whiteflag",
	[3]="Single Digit Perfects",
	[4]="Perfect Full Combo",
	[5]="Blackflag",
	[6]="Single Digit Greats",
	[7]="Full Combo",
	[8]="Missflag",
	[9]="Single Digit CBs",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Rainbowflag",
	[15]="Ragequit"
};


--
local typecolors = {
	[1]		= color("#66ccff"),
	[2]		= color("#dddddd"),
	[3] 	= color("#cc8800"),
	[4] 	= color("#eeaa00"),
	[5]		= color("#333333"),
	[6]		= color("#448844"),
	[7]		= color("#66cc66"),
	[8]		= color("#8c6239"),
	[9]		= color("#666666"),
	[10]	= color("#33aaff"),
	[11]	= color("#e61e25"),
	[12]	= color("#666666"),
	[13]	= color("#666666"),
	[14]	= color("#ffffff"),
	[15]	= color("#e61e25")
};
-- Clear Types based on stage awards
function title(sa,grade,playcount,misscount)
	if grade == 'nil' then -- If grade does not exist
		if playcount == 0 then
			return typetable[12],typecolors[12] -- no play
		end;
	else
		if grade == 'Grade_Failed' then -- failed
				return typetable[11],typecolors[11]
		elseif sa == 'StageAward_SingleDigitW2'then -- SDP
			return typetable[3],typecolors[3]
		elseif sa == 'StageAward_SingleDigitW3' then -- SDG
			return typetable[6],typecolors[6]
		elseif sa == 'StageAward_OneW2' then -- whiteflag
			return typetable[2],typecolors[2]
		elseif sa == 'StageAward_OneW3' then -- blackflag
			return typetable[5],typecolors[5]
		elseif sa == 'StageAward_FullComboW1' or grade == 'Grade_Tier01' then -- MFC
			return typetable[1],typecolors[1]
		elseif sa == 'StageAward_FullComboW2' or grade == 'Grade_Tier02'then -- PFC
			return typetable[4],typecolors[4]
		elseif sa == 'StageAward_FullComboW3' then -- FC
			return typetable[7],typecolors[7]
		else
			if misscount == 1 then 
				return typetable[8],typecolors[8] -- missflag
			else
				return typetable[10],typecolors[10] -- Clear
			end;
		end;
	end;
	return typetable[12],typecolors[12] -- noplay
end;

local profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
local playcount = 0
local misscount = 0
local totalplays = profileP1:GetNumTotalSongsPlayed()
local tablelength = 0
local cttext =''
local ctcolor =''
local topscore = nil
local playerdp = 0
local maxdp = 0
local nextdp = 0
local maxnotes = 0
local maxholds = 0
local date = ''
local grade = ''
local nexttier = ''
local cardpos0 = SCREEN_CENTER_X*0.475-((SCREEN_CENTER_X*0.625)/2)+2
local cardpos1 = SCREEN_CENTER_X*0.5-7
local hstable
local mods = ''
local ratemods = '1.0x Rate'


local t = Def.ActorFrame {
	Def.Actor{
		Name='aaaa';
		SetCommand=function(self)
			local rainbow = false
			local song = GAMESTATE:GetCurrentSong() -- grabs current song
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1) -- grabs current difficulty
			maxnotes =  steps:GetRadarValues(PLAYER_1):GetValue("RadarCategory_TapsAndHolds");
			maxholds = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls");
			maxdp = maxnotes*scoreweight["TapNoteScore_W1"]+maxholds*scoreweight["HoldNoteScore_Held"]
			if song ~= nil then -- when song is selected on musicwheel
				playcount = profileP1:GetSongNumTimesPlayed(GAMESTATE:GetCurrentSong()) -- grabs playcount for song
				hstable = profileP1:GetHighScoreList(song,steps):GetHighScores() -- grabs table of high scores (assumed to be sorted by score)
				topscore = hstable[1] -- returns first score
				--tablelength = #hstable

				if topscore ~= nil then -- when a score exists

					-- Date and Score
					date = topscore:GetDate()
					playerdp = topscore:GetTapNoteScore('TapNoteScore_W1')*scoreweight['TapNoteScore_W1']+topscore:GetTapNoteScore('TapNoteScore_W2')*scoreweight['TapNoteScore_W2']+topscore:GetTapNoteScore('TapNoteScore_W3')*scoreweight['TapNoteScore_W3']+topscore:GetTapNoteScore('TapNoteScore_W4')*scoreweight['TapNoteScore_W4']+topscore:GetTapNoteScore('TapNoteScore_W5')*scoreweight['TapNoteScore_W5']+topscore:GetTapNoteScore('TapNoteScore_Miss')*scoreweight['TapNoteScore_Miss']+topscore:GetTapNoteScore('TapNoteScore_HitMine')*scoreweight['TapNoteScore_HitMine']+topscore:GetHoldNoteScore('HoldNoteScore_LetGo')*scoreweight['HoldNoteScore_LetGo']+topscore:GetHoldNoteScore('HoldNoteScore_Held')*scoreweight['HoldNoteScore_Held']
					nexttier = getgrades(playerdp/maxdp,gradetier)
					nextdp = math.ceil(maxdp*gradetier[nexttier])
					misscount = topscore:GetTapNoteScore('TapNoteScore_Miss')+topscore:GetTapNoteScore('TapNoteScore_W5')+topscore:GetTapNoteScore('TapNoteScore_W4')
					

					-- gets the rate mod used in highscore. doesn't work if ratemod has a different name
					mods = topscore:GetModifiers()
					if string.find(mods,"xMusic") == nil then
						ratemods = '1.0x Rate'
					else
						ratemods = (string.match(mods,"%d+%.%d+xMusic")):sub(1,-6).." Rate"
						--ratemods = string.sub(mods,string.find(mods,"xMusic")-3,string.find(mods,"xMusic")).." Rate"
					end;

					-- Clear Types and its corresponding color
					if 1 == topscore:GetTapNoteScore('TapNoteScore_Miss') and 1 == topscore:GetTapNoteScore('TapNoteScore_W5') and 1 == topscore:GetTapNoteScore('TapNoteScore_W4') and 1 == topscore:GetTapNoteScore('TapNoteScore_W3') then
						rainbow = true
					end;
					local sa = topscore:GetStageAward()
					grade = topscore:GetGrade()
					if sa == nil then -- when no stageaward exists. aka: regular clears
						sa = 'nil'
					end;
					if grade == nil then
						grade = 'nil'
					end;
					cttext,ctcolor = title(sa,grade,playcount,misscount)
					if rainbow == true then
						cttext = typetable[14]
						ctcolor = "rainbow"
					end;
				else -- when song has been played but someone quits midway
					misscount = '-'
					playerdp = 0
					nexttier = "Grade_Tier07"
					nextdp = 0
					cttext,ctcolor = title('nil','nil',playcount,'-')
					date = ''
					mods = ''
					ratemods = ''
				end;
			else -- when something that isn't a song is selected on musicwheel
				cttext = '-'
				ctcolor = typecolors[13]
				playcount = '-'
				misscount = '-'
				playerdp = 0
				nexttier = "Grade_Tier07"
				nextdp = 0
				date = ''
				mods = ''
				ratemods = ''
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--[[
	LoadFont("Common Normal") .. { -- debug
        Name="test";
		InitCommand=cmd(x,10;y,285;zoom,1;horizalign,left;shadowlength,1;shadowcolor,color("#000000"));
		BeginCommand=function(self)
			self:settext(playerdp..' '..nexttier..' '..nextdp)
		end;
		SetCommand=function(self)
			self:settext(playerdp..' '..nexttier..' '..nextdp)
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
	};--]]
	LoadFont("Common Normal") .. { -- highscore rate mods
        Name="test";
		InitCommand=cmd(x,cardpos0;y,400;zoom,0.4;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext(ratemods)
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. { -- nextgrade/difference
        Name="P1DP";
		InitCommand=cmd(x,cardpos1;y,435;zoom,0.4;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext("DP: "..playerdp..'/'..maxdp)
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. { -- nextgrade/difference
        Name="NextGradeP1";
		InitCommand=cmd(x,cardpos1;y,445;zoom,0.4;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext(gradestring(nexttier)..' '..diffstring(playerdp-nextdp))
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

    LoadFont("Common Normal") .. { -- Total Playcount
        Name="TotPlaycountP1";
		InitCommand=cmd(x,20;y,20;zoom,0.4;horizalign,left);
		BeginCommand=function(self)
			self:settext(totalplays..' Total Plays')
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
	};
	LoadFont("Common Normal") .. { -- Song Playcount
        Name="SongPlaycount";
		InitCommand=cmd(x,cardpos1;y,425;zoom,0.4;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext('Play Count: '..playcount)
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set")
	};
	LoadFont("Common Normal") .. { -- Simfile Directory
        Name="FileDirectory";
		InitCommand=cmd(x,20;y,121;zoom,0.35;horizalign,left;shadowlength,1;shadowcolor,color("0,0,0,0.375");maxwidth,256*(1/0.35));
		BeginCommand=cmd(playcommand,"Set");
		CurrentSongChangedMessageCommand=function(self)
			local tempsong = GAMESTATE:GetCurrentSong()
			if tempsong ~= nil then
				local test = split('/',tempsong:GetSongDir())
				self:settext(test[2].."/"..test[3].."/"..test[4])
			else
				self:settext("")
			end;
		end;
		OffCommand=cmd(bouncebegin,0.375;addy,-192);
	};

	LoadFont("Common Normal") .. { -- Scoredate
        Name="ScoreDateP1";
		InitCommand=cmd(x,cardpos0;y,410;zoom,0.4;horizalign,left;shadowlength,1;shadowcolor,color("0,0,0,0.4"));
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext("Achieved on: "..date)
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal") .. { -- ClearType
        Name="ClearTypeP1";
		InitCommand=cmd(x,cardpos0;y,427;zoom,0.39;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:stopeffect()
			self:settext(cttext)
			if ctcolor == 'rainbow' then
				self:rainbow(true)
				self:effectperiod(1)
				self:diffuse(ctcolor)
			elseif cttext == "Marvelous Full Combo"then
				self:diffuseshift()
				self:effectcolor1(color("#ffcc00"))
				self:effectcolor2(color("#66cc66"))
				self:effectperiod(0.3)
			else
				self:diffuse(ctcolor)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
	LoadFont("Common Normal") .. { -- ClearType2
        Name="ClearTypeP1_AAAA";
		InitCommand=cmd(x,cardpos0;y,427;zoom,0.39;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:visible(false)
			self:stopeffect()
			self:settext(cttext)
			if cttext == "Marvelous Full Combo" then
				self:diffuseshift()
				self:visible(true)
				self:effectcolor1(color("1,1,1,0.2"))
				self:effectcolor2(ctcolor)
				self:effectperiod(0.4)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. { -- MissCount
        Name="MissCountP1";
		InitCommand=cmd(x,cardpos1;y,455;zoom,0.39;horizalign,left);
		BeginCommand=function(self)
			self:settext('CB: '..misscount)
		end;
		SetCommand=function(self)
			self:settext('CB: '..misscount)
		end;
		OffCommand=cmd(bouncebegin,0.35;zoomy,0);
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
};
--[[
local testtable = profileP1:GetHighScoreList(GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps(PLAYER_1)):GetHighScores()
for i, v in ipairs(testtable) do
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(x,305;y,50+i*10;zoom,0.5;horizalign,left);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local tabledp = v:GetTapNoteScore('TapNoteScore_W1')*scoreweight['TapNoteScore_W1']+v:GetTapNoteScore('TapNoteScore_W2')*scoreweight['TapNoteScore_W2']+v:GetTapNoteScore('TapNoteScore_W3')*scoreweight['TapNoteScore_W3']+v:GetTapNoteScore('TapNoteScore_W4')*scoreweight['TapNoteScore_W4']+v:GetTapNoteScore('TapNoteScore_W5')*scoreweight['TapNoteScore_W5']+v:GetTapNoteScore('TapNoteScore_Miss')*scoreweight['TapNoteScore_Miss']+v:GetTapNoteScore('TapNoteScore_HitMine')*scoreweight['TapNoteScore_HitMine']+v:GetHoldNoteScore('HoldNoteScore_LetGo')*scoreweight['HoldNoteScore_LetGo']+v:GetHoldNoteScore('HoldNoteScore_Held')*scoreweight['HoldNoteScore_Held']
			self:settext(i)
			self:settext(tabledp)
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
end;
--]]
return t;