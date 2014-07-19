 
-- this is a giant mess atm.


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

--Return letter grades based on tier, assumes the 8 tier grade used in SM.
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
		return tier
	end;
end;

-- Takes both DP and %Score and player number as input, returns grade.
-- GetGradeFromPercent() doesn't seem to be able to distinguish AAAA and AAA
function getgrade(DPScore,MaxDP,PScore,MaxPDP,pn)
	if SCREENMAN:GetTopScreen():GetLifeMeter(pn):IsFailing() then
		return 'Grade_Failed'
	elseif MaxDP == 0 and MaxPDP == 0 then
		return GetGradeFromPercent(0)
	elseif PScore == MaxPDP then
		return 'Grade_Tier01'
	elseif DPScore == MaxDP then
		return 'Grade_Tier02'
	else
		return GetGradeFromPercent(DPScore/MaxDP)
	end;
end;

-- Returns the string for the next grade given the current DP score percentage and a table containing the grade cutoffs.
function getnextgrade(dppercent,gradetier)
	if dppercent > gradetier["Grade_Tier03"] then --AA/AAA/AAAA
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

local pweight =  { -- Score Weights for percentage scores (EX oni)
	TapNoteScore_W1			= 3,--PREFSMAN:GetPreference("PercentScoreWeightW1"),
	TapNoteScore_W2			= 2,--PREFSMAN:GetPreference("PercentScoreWeightW2"),
	TapNoteScore_W3			= 1,--PREFSMAN:GetPreference("PercentScoreWeightW3"),
	TapNoteScore_W4			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW4"),
	TapNoteScore_W5			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW5"),
	TapNoteScore_Miss			= 0,--PREFSMAN:GetPreference("PercentScoreWeightMiss"),
	HoldNoteScore_Held			= 3,--PREFSMAN:GetPreference("PercentScoreWeightHeld"),
	TapNoteScore_HitMine			= -2,--(-2 or 0?)PREFSMAN:GetPreference("PercentScoreWeightHitMine"),
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("PercentScoreWeightLetGo"),
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointHit"),
	TapNoteScore_CheckpointMiss 	= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointMiss"),
};

local difftype = {
	Difficulty_Beginner 		= 'Novice',
	Difficulty_Easy 			= 'Easy',
	Difficulty_Medium			= 'Medium',
	Difficulty_Hard				= 'Hard',
	Difficulty_Challenge		= 'Expert',
	Difficulty_Edit				= 'Edit'
}

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

-- Clear Types based on stage awards and grades.
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
local scorestatX = 20
local scorestatY = 20
local scorestatWidth = SCREEN_WIDTH/8*3.5-10
local scorestatHeight = SCREEN_HEIGHT-200
local judgeX = 5
local judgeY = 115
local hstable
local mods = ''
local ratemods = '1.0x Rate'
local scorestatheld = false
local songtitle = ''
local subtitle = ''
local artist = ''
local stepstype = ''
local difficulty = ''
local meter = 0
local numscore = 1

local judgestats = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	TapNoteScore_HitMine = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0
};
local holdstats = {
	HoldNoteScore_Held = 0,
	HoldNoteScore_LetGo = 0
	-- HoldNoteScore_Missed = 0 --Placeholder for now
};

local t = Def.ActorFrame {
	Def.Actor{
		Name="scorestat";
		CodeMessageCommand=function(self,params)
			if params.Name == "ScoreStat" then
				scorestatheld = true
			end;
			if params.Name == "ScoreStatOff" then
				scorestatheld = false
			end;
		end;
	};

	Def.Actor{
		Name='aaaa';
		SetCommand=function(self)
			local rainbow = false
			local song = GAMESTATE:GetCurrentSong() -- grabs current song
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1) -- grabs current difficulty
			maxnotes =  steps:GetRadarValues(PLAYER_1):GetValue("RadarCategory_TapsAndHolds");
			maxholds = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls");
			maxdp = maxnotes*scoreweight["TapNoteScore_W1"]+maxholds*scoreweight["HoldNoteScore_Held"]
			maxps = maxnotes*pweight["TapNoteScore_W1"]+maxholds*pweight["HoldNoteScore_Held"]
			if song ~= nil then -- when song is selected on musicwheel
				--assuming steps also have to exist if the song exists in the music wheel.
				songtitle = song:GetDisplayMainTitle()
				subtitle = song:GetDisplaySubTitle()
				artist = song:GetDisplayArtist()
				playcount = profileP1:GetSongNumTimesPlayed(GAMESTATE:GetCurrentSong()) -- grabs playcount for song
				hstable = profileP1:GetHighScoreList(song,steps):GetHighScores() -- grabs table of high scores (assumed to be sorted by score)
				stepstype = string.gsub(ToEnumShortString(steps:GetStepsType()),"%_"," ")
				meter = steps:GetMeter()
				difficulty = difftype[steps:GetDifficulty()]
				topscore = hstable[1] -- returns first score
				--tablelength = #hstable

				if topscore ~= nil then -- when a score exists

					-- Date and Score
					numscore = #hstable
					date = topscore:GetDate()
					for k,v in pairs(judgestats) do
						judgestats[k] = topscore:GetTapNoteScore(k)
					end;
					for k,v in pairs(holdstats) do
						holdstats[k] = topscore:GetHoldNoteScore(k)
					end;
					playerdp = topscore:GetTapNoteScore('TapNoteScore_W1')*scoreweight['TapNoteScore_W1']+topscore:GetTapNoteScore('TapNoteScore_W2')*scoreweight['TapNoteScore_W2']+topscore:GetTapNoteScore('TapNoteScore_W3')*scoreweight['TapNoteScore_W3']+topscore:GetTapNoteScore('TapNoteScore_W4')*scoreweight['TapNoteScore_W4']+topscore:GetTapNoteScore('TapNoteScore_W5')*scoreweight['TapNoteScore_W5']+topscore:GetTapNoteScore('TapNoteScore_Miss')*scoreweight['TapNoteScore_Miss']+topscore:GetTapNoteScore('TapNoteScore_HitMine')*scoreweight['TapNoteScore_HitMine']+topscore:GetHoldNoteScore('HoldNoteScore_LetGo')*scoreweight['HoldNoteScore_LetGo']+topscore:GetHoldNoteScore('HoldNoteScore_Held')*scoreweight['HoldNoteScore_Held']
					percentscore = topscore:GetTapNoteScore('TapNoteScore_W1')*pweight['TapNoteScore_W1']+topscore:GetTapNoteScore('TapNoteScore_W2')*pweight['TapNoteScore_W2']+topscore:GetTapNoteScore('TapNoteScore_W3')*pweight['TapNoteScore_W3']+topscore:GetTapNoteScore('TapNoteScore_W4')*pweight['TapNoteScore_W4']+topscore:GetTapNoteScore('TapNoteScore_W5')*pweight['TapNoteScore_W5']+topscore:GetTapNoteScore('TapNoteScore_Miss')*pweight['TapNoteScore_Miss']+topscore:GetTapNoteScore('TapNoteScore_HitMine')*pweight['TapNoteScore_HitMine']+topscore:GetHoldNoteScore('HoldNoteScore_LetGo')*pweight['HoldNoteScore_LetGo']+topscore:GetHoldNoteScore('HoldNoteScore_Held')*pweight['HoldNoteScore_Held']
					nexttier = getnextgrade(playerdp/maxdp,gradetier)
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
					numscore = 1
					playerdp = 0
					nexttier = "Grade_Tier07"
					nextdp = 0
					percentscore = 0
					cttext,ctcolor = title('nil','nil',playcount,'-')
					date = ''
					mods = 'No Modifiers'
					ratemods = ''
					for k,v in pairs(judgestats) do
						judgestats[k] = 0
					end;
					for k,v in pairs(holdstats) do
						holdstats[k] = 0
					end;
					grade = 'n/a'
				end;
			else -- when something that isn't a song is selected on musicwheel
				cttext = '-'
				ctcolor = typecolors[13]
				playcount = '-'
				misscount = '-'
				numscore = 1
				playerdp = 0
				nexttier = "Grade_Tier07"
				nextdp = 0
				percentscore = 0
				date = ''
				mods = 'No Modifiers'
				ratemods = ''
				songtitle = ''
				subtitle = ''
				artist = ''
				grade = 'n/a'
				stepstype = ' '
				meter = ' '
				difficulty = ' '
				for k,v in pairs(judgestats) do
						judgestats[k] = 0
				end;
				for k,v in pairs(holdstats) do
						holdstats[k] = 0
				end;
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
		InitCommand=cmd(x,cardpos0;y,410;zoom,0.4;horizalign,left);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			self:settext(ratemods)
		end;
		OnCommand=cmd(bouncebegin,0.35;zoomy,0.4);
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
		CodeMessageCommand=function(self,params)
			self:finishtweening()
			if scorestatheld then
				self:playcommand("Off")
			else
				self:bouncebegin(0.375)
				self:y(20)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.375;addy,-192);
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
		CodeMessageCommand=function(self,params)
			self:finishtweening()
			if scorestatheld then
				self:playcommand("Off")
			else
				self:bouncebegin(0.375)
				self:y(121)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.375;addy,-192);
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

	--ScoreStat
	--Comment this

	Def.ActorFrame {
		Name="ScoreStatP1";
		InitCommand=cmd(xy,scorestatX-SCREEN_WIDTH/2,scorestatY);
		CodeMessageCommand=function(self,params)
			self:finishtweening()
			if scorestatheld then
				self:bouncebegin(0.375)
				self:addx(SCREEN_WIDTH/2)
			else
				self:bouncebegin(0.375)
				self:xy(scorestatX-SCREEN_WIDTH/2,scorestatY)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.375;addx,-SCREEN_WIDTH/2);
		Def.Quad{
			InitCommand=cmd(zoomto,scorestatWidth,scorestatHeight;horizalign,left;vertalign,top;diffuse,color("#333333");diffusealpha,0.7);
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(x,5;zoom,0.5;maxwidth,scorestatWidth/0.5-20;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext(songtitle.." - "..artist)
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,5,15;zoom,0.4;maxwidth,scorestatWidth/0.4;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext(stepstype.." "..difficulty.." "..meter.."\nPlaycount: "..playcount.."\nAchieved on: "..date)
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,6,50;diffuse,color("#cc6666");zoom,0.9;maxwidth,45/0.9;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:diffuse(CustomGradeColor(grade))
				self:settext(gradestring(grade))
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,53,57;zoom,0.4;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				if maxnotes ~= 0  then
					self:settextf("Score: %.2f%%",(math.floor(percentscore/maxps*10000))/100); 
				else
					self:settext("Score: 0.00%")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,53,65;zoom,0.4;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext("DP :"..playerdp.."/"..maxdp..' '..gradestring(nexttier)..' '..diffstring(playerdp-nextdp))
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,5,75;zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stopeffect()
				self:settext(cttext)
				if ctcolor == 'rainbow' then
					self:rainbow(true)
					self:effectperiod(1)
					self:diffuse(ctcolor)
				elseif cttext == "Marvelous Full Combo"then
					self:diffuseshift()
					self:effectcolor1(CustomGradeColor("Grade_Tier01"))
					self:effectcolor2(color(ctcolor))
					self:effectperiod(0.1)
				else
					self:diffuse(ctcolor)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,5,90;zoom,0.4;maxwidth,scorestatWidth/0.4-20;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext("Mods : \n"..mods)
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY;zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Marvelous ")
				self:diffuseshift()
				self:effectcolor1(TapNoteScoreToColor("TapNoteScore_W1"))
				self:effectcolor2(color("#66ccff"))
				self:effectperiod(0.1)
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W1"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W1"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_W1"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+15;diffuse,TapNoteScoreToColor("TapNoteScore_W2");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Perfect ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+15;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W2"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+15+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W2"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_W2"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+30;diffuse,TapNoteScoreToColor("TapNoteScore_W3");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Great ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+30;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W3"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+30+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W3"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_W3"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+45;diffuse,TapNoteScoreToColor("TapNoteScore_W4");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Good ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+45;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W4"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+45+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W4"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_W4"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+60;diffuse,TapNoteScoreToColor("TapNoteScore_W5");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Bad ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+60;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W5"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+60+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_W5"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_W5"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+75;diffuse,TapNoteScoreToColor("TapNoteScore_Miss");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("Miss ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+75;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_Miss"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+75+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = judgestats["TapNoteScore_Miss"]
				if temp ~= nil and maxnotes ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(judgestats["TapNoteScore_Miss"]/maxnotes*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+90;diffuse,TapNoteScoreToColor("TapNoteScore_W2");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("OK ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+90;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = holdstats["HoldNoteScore_Held"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+90+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = holdstats["HoldNoteScore_Held"]
				if temp ~= nil and maxholds ~= 0  then
					self:settextf("(%.2f%%)",(math.floor(holdstats["HoldNoteScore_Held"]/maxholds*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX,judgeY+105;diffuse,TapNoteScoreToColor("TapNoteScore_Miss");zoom,0.5;horizalign,left;vertalign,top);
			BeginCommand=function(self)
				self:settext("NG ")
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+100,judgeY+105;zoom,0.5;horizalign,right;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = holdstats["HoldNoteScore_LetGo"]
				if temp ~= nil then
					self:settext(temp)
				else
					self:settext(0)
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,judgeX+102,judgeY+105+4;zoom,0.35;horizalign,left;vertalign,top);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp = holdstats["HoldNoteScore_LetGo"]
				if temp ~= nil and maxholds ~= 0 then
					self:settextf("(%.2f%%)",(math.floor(holdstats["HoldNoteScore_LetGo"]/maxholds*10000))/100); 
				else
					self:settext("(0.00%)")
				end;
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,scorestatWidth-5,scorestatHeight-5;zoom,0.35;diffusealpha,0.5;horizalign,right;vertalign,bottom);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext("Showing 1 of "..numscore)
			end;
			OffCommand=cmd(bouncebegin,0.35;zoomy,0);
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};


	};

};

-- Switch to something like this for judgecounts since the current one is a giant copy-paste-fest.
-- Also Make them display in order
--[[
local i = 0
for k, v in pairs(judgestats) do
	i = 0
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,judgeX+100,judgeY;zoom,0.5;horizalign,right);
		BeginCommand=function(self)
			i=1+i
			self:y(judgeY+i*15*0.5)
			self:queuecommand("Set")
		end;
		SetCommand=function(self)
			self:settext(judgestats[k])
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,judgeX+105,judgeY;zoom,0.5;horizalign,left);
		BeginCommand=function(self)
			i=1+i
			self:y(judgeY-15/2+i*15*0.5)
			self:queuecommand("Set")
		end;
		SetCommand=function(self)
			self:settextf("%.1f%%",(math.floor(judgestats[k]/maxnotes*10000))/100); 
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,judgeX,judgeY;zoom,0.5;horizalign,right);
		BeginCommand=function(self)
			i=1+i
			self:y(judgeY-15+i*15*0.5)
			self:queuecommand("Set")
		end;
		SetCommand=function(self)
			self:settext(k)
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
end;
--]]
return t;