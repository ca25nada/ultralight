-- judgecounter/scoregraph (and a bunch of other things now)
-- t.hanks shakesoda(!!)

-- todo - clean up this mess

--[[ 
Current (known) issues with scoregraph:

	Can be inaccurate if a file is autogen'd from a different mode. Due to #of notes in radarvalues and the actual note in the conversion being different in some cases.
	
	Missed holds do not do not get scored by HoldNoteScores so total hold count does not match with the actual # of holds played when a player misses a hold entirely.
	The total hold count will be forced to match the values indicated by the radarvalues when the last note is hit, so the targetgraph can appear to spike at the end.
	^ Probably going to be fixed in the next SM5 release since HNS_Miss has been added.

	Unlike SM 3.9/3.95 versions, the game rewards AAAA/AAA rank even when multiple mines are hit. 
	The mines however, reduces the DP score anyway resulting in a lower score if a player gets a non-AAAA/AAA rank. 
	So a player can get a AAAA/AAA rank even when the graph shows otherwise.

	Errything is hardcoded for 1P atm so playing as 2P will "probably" crash the game at some point.
--]]

---------------------------------------
-- Score Weights and Rank Conditions --
---------------------------------------
local gradestring = {
	Grade_Tier01 = 'AAAA',
	Grade_Tier02 = 'AAA',
	Grade_Tier03 = 'AA',
	Grade_Tier04 = 'A',
	Grade_Tier05 = 'B',
	Grade_Tier06 = 'C',
	Grade_Tier07 = 'D',
	Grade_Failed = 'F'
};

local gradetier = {
	Tier01 = THEME:GetMetric("PlayerStageStats", "GradePercentTier01"), -- AAAA
	Tier02 = THEME:GetMetric("PlayerStageStats", "GradePercentTier02"), -- AAA
	Tier03 = THEME:GetMetric("PlayerStageStats", "GradePercentTier03"), -- AA
	Tier04 = THEME:GetMetric("PlayerStageStats", "GradePercentTier04"), -- A
	Tier05 = THEME:GetMetric("PlayerStageStats", "GradePercentTier05"), -- B
	Tier06 = THEME:GetMetric("PlayerStageStats", "GradePercentTier06"), -- C
	Tier07 = THEME:GetMetric("PlayerStageStats", "GradePercentTier07"), -- D
};

local scoreweight =  { -- Score Weights for DP score (MAX2)
	TapNoteScore_W1				= 2,--PREFSMAN:GetPreference("GradeWeightW1"),					--  2
	TapNoteScore_W2				= 2,--PREFSMAN:GetPreference("GradeWeightW2"),					--  2
	TapNoteScore_W3				= 1,--PREFSMAN:GetPreference("GradeWeightW3"),					--  1
	TapNoteScore_W4				= 0,--PREFSMAN:GetPreference("GradeWeightW4"),					--  0
	TapNoteScore_W5				= -4,--PREFSMAN:GetPreference("GradeWeightW5"),					-- -4
	TapNoteScore_Miss			= -8,--PREFSMAN:GetPreference("GradeWeightMiss"),				-- -8
	HoldNoteScore_Held			= 6,--PREFSMAN:GetPreference("GradeWeightHeld"),				--  6
	TapNoteScore_HitMine		= -8,--PREFSMAN:GetPreference("GradeWeightHitMine"),				-- -8
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("GradeWeightLetGo"),				--  0
	-- HoldNoteScore_Missed = 0 --Placeholder for now
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
	TapNoteScore_HitMine			= 0,--PREFSMAN:GetPreference("PercentScoreWeightHitMine"),
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("PercentScoreWeightLetGo"),
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointHit"),
	TapNoteScore_CheckpointMiss 	= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointMiss"),
};

local migsweight =  { -- Score Weights for MIGS score
	TapNoteScore_W1			= 3,
	TapNoteScore_W2			= 2,
	TapNoteScore_W3			= 1,
	TapNoteScore_W4			= 0,
	TapNoteScore_W5			= -4,
	TapNoteScore_Miss			= -8,
	HoldNoteScore_Held			= 6,
	TapNoteScore_HitMine			= -8,
	HoldNoteScore_LetGo			= 0,
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
};

local judgestats = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	-- HoldNoteScore_Missed = 0 --Placeholder for now
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
};


-----------------------------------------
-- Variables for JudgeCount/PA Counter --
-----------------------------------------
local center1P = PREFSMAN:GetPreference("Center1Player"); -- For relocating graph/judgecount frame
local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame

--Position of JudgeCount, the values here assumes center1P being enabled.
local framex = 20
local framey = SCREEN_HEIGHT*0.62

-- Change X Position depending on centered 1p
if center1P == false and cols == 4 then
	framex = framex + 320
elseif center1P == false and cols == 6 then
	framex = framex + 384
end;

local judgetype = tonumber(GetUserPref("JudgeTypeP1"));
local judgemode
if judgetype == 1 then
	judgemode = "Off"
elseif judgetype == 2 then
	judgemode = "Simple"
elseif judgetype == 3 then
	judgemode = "On"
else
	judgemode = "Off"
end;


-------------------------------
-- Variables for  Scoregraph --
-------------------------------
local target = (tonumber(GetUserPref("GraphTargetP1"))+1)/100; -- target score from 0% to 100%.
--local targetdec = (tonumber(GetUserPref("GraphTargetP1dec"))+1)/10000; -- not used yet, will be used for decimal places for score target.

local graphx = SCREEN_WIDTH -- Location of graph, graph is aligned to right.
local graphy = SCREEN_HEIGHT-80 -- Location of scoregraph bottom (aka: 0% line)
local graphheight = 300 -- scoregraph height (aka: height from 0% to max)
local graphwidth = 100 -- width of scoregraph, minimum of 100 recommended to avoid overlapping text.


 -- for Rank <Grade> get messages on the scoregraph to make sure they only display once since DP score can go back down.
local playedgrade = {
	playedC = false, -- Played<Rank>
	playedB = false, 
	playedA = false,
	playedAA = false,
	playedAAA = false,
}

-- Sets everything in playedgrade to true if hidegrademessage is true so "Rank <grade> pass" message no longer appears.
local hidegraphmessage = tonumber(GetUserPref("GraphMessageP1")) -- Used to toggle graphmessage preferences
if hidegraphmessage == 1 then
	hidegraphmessage = true
else
	hidegraphmessage = false
end;

for k,v in pairs(playedgrade) do
	playedgrade[k] = hidegraphmessage
end;
local graphtype = tonumber(GetUserPref("GraphTypeP1"));
local graphmode
if graphtype == 1 then
	graphmode = "Off"
elseif graphtype == 2 then
	graphmode = "DP"
elseif graphtype == 3 then
	graphmode = "PS"
elseif graphtype == 4 then
	graphmode = "MIGS"
else
	graphmode = "Off"
end;

----------------------------------------------
-- Variables for  Ghost Score and Avg Score --
----------------------------------------------
local avgscoretype = tonumber(GetUserPref("AvgScoreTypeP1")); -- unused. will allow users to select scoretype for average score. currently hardcoded to percent score.
local avgscoremode
if avgscoretype == 1 then
	avgscoremode = "DP"
elseif avgscoretype == 2 then
	avgscoremode = "PS"
elseif avgscoretype == 3 then
	avgscoremode = "MIGS"
else
	avgscoremode = "Off"
end;
--local ghostscoretype = "On" -- unused. for toggling ghostscore on and off.


-------------------------------------------
-- Variables for Current Play Statistics --
-------------------------------------------
local p1name = GAMESTATE:GetPlayerDisplayName(PLAYER_1)
local maxnotes = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_TapsAndHolds"); -- Radarvalue, maximum number of notes
local maxholds = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls"); -- Radarvalue, maximum number of holds
local totnotes = 0 -- #number of notes played so far
local totholds = 0 -- #number of holds played so far
local totmines = 0 -- #number of mines played so far

local dpscore = 0 -- current player score
local curmaxdp = 0 -- highest possible DP score at given moment
local maxdp = maxnotes*scoreweight["TapNoteScore_W1"]+maxholds*scoreweight["HoldNoteScore_Held"] -- maximum DP
local dppercent = 0.0 -- current player score percent

local percentscore = 0 -- current player score
local curmaxps = 0 -- highest possible percent score at given moment
local maxps = maxnotes*pweight["TapNoteScore_W1"]+maxholds*pweight["HoldNoteScore_Held"]  -- maximum %score DP
local pspercent = 0.0

local migsscore = 0 -- current player score
local curmaxmigs = 0 -- highest possible MIGS score at given moment
local maxmigs = maxnotes*migsweight["TapNoteScore_W1"]+maxholds*migsweight["HoldNoteScore_Held"]  -- maximum MIGS DP
local migspercent = 0.0

local curgrade

-------------
--Functions--
-------------

-- Takes both DP and %Score and player number as input, returns grade.
-- GetGradeFromPercent() doesn't seem to be able to distinguish AAAA and AAA
function curavggrade(DPScore,MaxDP,PScore,MaxPDP,pn)
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

function PJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores(judge)
end; 
function PHJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetHoldNoteScores(judge)
end; 


-- copy+paste galore
local t = Def.ActorFrame {

	----------------
	-- Judgecount --
	----------------

	Def.ActorFrame{ -- Judge Count
		InitCommand=cmd(visible,true);
		BeginCommand=function(self)
			if judgemode == 'Off' or cols >= 8 then
				self:visible(false);
			end;
		end;
		Def.Quad{ -- Judgecount Background
				Name="BackGround";
				InitCommand=cmd(x,-5+framex;y,-5+framey;zoomto,55,95;diffuse,color("0,0,0,0.4");horizalign,left;vertalign,top);
		};		
		Def.Actor{ -- PlayerFail
				Name="PlayerFail";
				JudgmentMessageCommand=function(self)
					P1Fail = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetFailed();
					P2Fail = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetFailed();
				end;
		};	
		Def.Quad{ --JudgeHighlight
				Name="JudgeHighlight/W1";
				InitCommand=cmd(x,-5+framex;y,0+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_W1' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+0);
						self:linear(0.1);
						self:diffuse(color("0.2,0.773,0.953,0.5"));
						self:linear(0.5)
						self:diffusealpha(0)
					end;
				end;
		};
		Def.Quad{ --JudgeHighlight W2
				Name="JudgeHighlightW2";
				InitCommand=cmd(x,-5+framex;y,10+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_W2' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+10);
						self:linear(0.1);
						self:diffuse(color("1,0.8,0,0.4"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["TapNoteScore_W2"] = judgestats["TapNoteScore_W2"] + 1
					end;
				end;
		};
		Def.Quad{ --JudgeHighlight W3
				Name="JudgeHighlightW3";
				InitCommand=cmd(x,-5+framex;y,20+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_W3' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+20);
						self:linear(0.1);
						self:diffuse(color("0.4,0.8,0.4,0.4"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["TapNoteScore_W3"] = judgestats["TapNoteScore_W3"] + 1
					end;
				end;
		};
		Def.Quad{ --JudgeHighlight W4
				Name="JudgeHighlightW4";
				InitCommand=cmd(x,-5+framex;y,30+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_W4' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+30);
						self:linear(0.1);
						self:diffuse(color("0.35,0.46,0.73,0.5"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["TapNoteScore_W4"] = judgestats["TapNoteScore_W4"] + 1
					end;
				end;
		};
		Def.Quad{ --JudgeHighlight W5
				Name="JudgeHighlightW5";
				InitCommand=cmd(x,-5+framex;y,40+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_W5' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+40);
						self:linear(0.1);
						self:diffuse(color("0.78,0.48,1,0.5"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["TapNoteScore_W5"] = judgestats["TapNoteScore_W5"] + 1
					end;
				end;
		};
		Def.Quad{ --JudgeHighlight Miss
				Name="JudgeHighlightMiss";
				InitCommand=cmd(x,-5+framex;y,50+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.TapNoteScore == 'TapNoteScore_Miss' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+50);
						self:linear(0.1);
						self:diffuse(color("0.85,0.33,0.33,0.5"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["TapNoteScore_Miss"] = judgestats["TapNoteScore_Miss"] + 1
					end;
				end;
		};
		Def.Quad{ --HoldHighlightOK
				Name="HoldHighlightOK";
				InitCommand=cmd(x,-5+framex;y,60+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.HoldNoteScore == 'HoldNoteScore_Held' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+60);
						self:linear(0.1);
						self:diffuse(color("1,0.8,0,0.4"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["HoldNoteScore_Held"] = judgestats["HoldNoteScore_Held"] + 1
					end;
				end;
		};
		Def.Quad{ --HoldHighlightNG
				Name="HoldHighlightNG";
				InitCommand=cmd(x,-5+framex;y,70+framey;zoomto,55,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
				JudgmentMessageCommand=function(self,params)
					if judgemode == 'On' and params.HoldNoteScore == 'HoldNoteScore_LetGo' then
						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						--self:y(framey+70);
						self:linear(0.1);
						self:diffuse(color("0.85,0.33,0.33,0.5"));
						self:linear(0.5)
						self:diffusealpha(0)
						--judgestats["HoldNoteScore_LetGo"] = judgestats["HoldNoteScore_LetGo"] + 1
					end;
				end;
		};
        LoadFont("Common Normal") .. { --JudgeLetters W1
                Name="P1W1";
				InitCommand=cmd(x,0+framex;y,0+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("MA")
					self:diffuse(color("#99ccff"))
				end;
        };
        LoadFont("Common Normal") .. { --JudgeLetters W2
                Name="P1W2";
                InitCommand=cmd(x,0+framex;y,10+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("PR")
					self:diffuse(HSV(48,0.8,0.95))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters W3
                Name="P1W3";
                InitCommand=cmd(x,0+framex;y,20+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("GR")
					self:diffuse(HSV(160,0.9,0.8))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters W4
                Name="P1W4";
                InitCommand=cmd(x,0+framex;y,30+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("GD")
					self:diffuse(HSV(200,0.9,1))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters W5
                Name="P1W5";
                InitCommand=cmd(x,0+framex;y,40+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("BD")
					self:diffuse(HSV(320,0.9,1))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters Miss
                Name="P1Miss";
                InitCommand=cmd(x,0+framex;y,50+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("MS")
					self:diffuse(HSV(0,0.8,0.8))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters OK
                Name="P1OK";
                InitCommand=cmd(x,0+framex;y,60+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("OK")
					self:diffuse(HSV(48,0.8,0.95))
				end;
        };
		LoadFont("Common Normal") .. { --JudgeLetters NG
                Name="P1NG";
                InitCommand=cmd(x,0+framex;y,70+framey;zoom,0.4;horizalign,left);
				BeginCommand=function(self)
					self:settext("NG")
					self:diffuse(HSV(0,0.8,0.8))
				end;
        };
        LoadFont("Common Normal") .. { --JudgeCount  W1
                Name="P1W1count";
				InitCommand=cmd(x,45+framex;y,0+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_W1')
						judgestats["TapNoteScore_W1"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
        LoadFont("Common Normal") .. { --JudgeCount  W2
                Name="P1W2count";
                InitCommand=cmd(x,45+framex;y,10+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_W2')
						judgestats["TapNoteScore_W2"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { --JudgeCount  W3
                Name="P1W3count";
                InitCommand=cmd(x,45+framex;y,20+framey;zoom,0.35;horizalign,right);
 				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_W3')
						judgestats["TapNoteScore_W3"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { --JudgeCount  W4
                Name="P1W4count";
                InitCommand=cmd(x,45+framex;y,30+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_W4')
						judgestats["TapNoteScore_W4"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { --JudgeCount  W5
                Name="P1W5count";
                InitCommand=cmd(x,45+framex;y,40+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_W5')
						judgestats["TapNoteScore_W5"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { --JudgeCount  Miss
                Name="P1Misscount";
                InitCommand=cmd(x,45+framex;y,50+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PJudge(PLAYER_1,'TapNoteScore_Miss')
						judgestats["TapNoteScore_Miss"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { --JudgeCount  OK
                Name="P1OKcount";
                InitCommand=cmd(x,45+framex;y,60+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PHJudge(PLAYER_1,'HoldNoteScore_Held')
						judgestats["HoldNoteScore_Held"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
        };
		LoadFont("Common Normal") .. { --JudgeCount  NG
                Name="P1NGcount";
                InitCommand=cmd(x,45+framex;y,70+framey;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0)
				end;
				SetCommand=function(self)
					if P1Fail == false then
						local count = PHJudge(PLAYER_1,'HoldNoteScore_LetGo')
						judgestats["HoldNoteScore_LetGo"] = count
						self:settext(count)
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
        };
		Def.Actor{ -- Minehit Count
			Name="P1MineHitCount";
			InitCommand=cmd();
			SetCommand=function(self)
				if P1Fail == false then
					local count = PJudge(PLAYER_1,"TapNoteScore_HitMine")
					judgestats["TapNoteScore_HitMine"] = count
				end;
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		Def.Actor{ -- ScoreCalc
			SetCommand=function(self)
				if P1Fail == false then
					dpscore = (judgestats["TapNoteScore_W1"]*scoreweight["TapNoteScore_W1"]+judgestats["TapNoteScore_W2"]*scoreweight["TapNoteScore_W2"]+judgestats["TapNoteScore_W3"]*scoreweight["TapNoteScore_W3"]+judgestats["TapNoteScore_W4"]*scoreweight["TapNoteScore_W4"]+judgestats["TapNoteScore_W5"]*scoreweight["TapNoteScore_W5"]+judgestats["TapNoteScore_Miss"]*scoreweight["TapNoteScore_Miss"]+judgestats["TapNoteScore_HitMine"]*scoreweight["TapNoteScore_HitMine"]+judgestats["HoldNoteScore_Held"]*scoreweight["HoldNoteScore_Held"]+judgestats["HoldNoteScore_LetGo"]*scoreweight["HoldNoteScore_LetGo"])
					percentscore = (judgestats["TapNoteScore_W1"]*pweight["TapNoteScore_W1"]+judgestats["TapNoteScore_W2"]*pweight["TapNoteScore_W2"]+judgestats["TapNoteScore_W3"]*pweight["TapNoteScore_W3"]+judgestats["TapNoteScore_W4"]*pweight["TapNoteScore_W4"]+judgestats["TapNoteScore_W5"]*pweight["TapNoteScore_W5"]+judgestats["TapNoteScore_Miss"]*pweight["TapNoteScore_Miss"]+judgestats["TapNoteScore_HitMine"]*pweight["TapNoteScore_HitMine"]+judgestats["HoldNoteScore_Held"]*pweight["HoldNoteScore_Held"]+judgestats["HoldNoteScore_LetGo"]*pweight["HoldNoteScore_LetGo"])
					migsscore = (judgestats["TapNoteScore_W1"]*migsweight["TapNoteScore_W1"]+judgestats["TapNoteScore_W2"]*migsweight["TapNoteScore_W2"]+judgestats["TapNoteScore_W3"]*migsweight["TapNoteScore_W3"]+judgestats["TapNoteScore_W4"]*migsweight["TapNoteScore_W4"]+judgestats["TapNoteScore_W5"]*migsweight["TapNoteScore_W5"]+judgestats["TapNoteScore_Miss"]*migsweight["TapNoteScore_Miss"]+judgestats["TapNoteScore_HitMine"]*migsweight["TapNoteScore_HitMine"]+judgestats["HoldNoteScore_Held"]*migsweight["HoldNoteScore_Held"]+judgestats["HoldNoteScore_LetGo"]*migsweight["HoldNoteScore_LetGo"])
				end;
				curmaxdp = (totnotes*scoreweight["TapNoteScore_W1"]+totholds*scoreweight["HoldNoteScore_Held"])
				curmaxps = (totnotes*pweight["TapNoteScore_W1"]+totholds*pweight["HoldNoteScore_Held"])
				curmaxmigs = (totnotes*migsweight["TapNoteScore_W1"]+totholds*migsweight["HoldNoteScore_Held"])
				dppercent = string.format("%.2f",dpscore/curmaxdp)
				pspercent = string.format("%.2f",percentscore/curmaxps)
				migspercent = string.format("%.2f",migsscore/curmaxmigs)
				
			end;
			JudgmentMessageCommand=function(self,params)
				
				if params.HoldNoteScore then
					totholds = totholds + 1;
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					totmines = totmines + 1;
				else
					totnotes = totnotes + 1;
				end;
				--halfassed attempt at fixing hold issue, might cause graph issues with songs with just holds at ending.
				--to be removed after it's fixed.
				if totnotes == maxnotes then
					if totholds ~= maxholds then
						totholds = maxholds
					end;
				end;
				self:queuecommand("Set");
			end;
		};
		LoadFont("Common Normal") .. { --grade
                Name="curGrade";
                InitCommand=cmd(x,framex+0;y,framey+80;zoom,0.45;horizalign,left);
				BeginCommand=function(self)
					self:settext(gradestring[GetGradeFromPercent(0)])
				end;
				SetCommand=function(self)
					local temp = GetGradeFromPercent(0)
					if curmaxdp ~= 0 then -- bunch of error messages pop up when getgradefrompercent is called with a undefined value
						temp = curavggrade(dpscore,curmaxdp,percentscore,curmaxps,PLAYER_1)
					end;
					self:settext(gradestring[temp])
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
        };
	};

	-----------------------------------------
	-- ScoreGraph / Ghost Score / AvgScore --
	-----------------------------------------

	Def.ActorFrame{ -- Score Graph
		InitCommand=cmd(visible,true);
		BeginCommand=function(self)
			if graphmode == 'Off' or cols >= 8 then
				self:visible(false)
			end;
		end;
		Def.Quad{ --Graph BG
				Name="graphbg";
				--InitCommand=cmd(x,graphx;y,50+graphy;zoomto,100,graphheight+125;diffuse,color("0,0,0,0.4");vertalign,bottom);
				InitCommand=cmd(halign,1;x,graphx;y,0;zoomto,graphwidth,SCREEN_HEIGHT;diffuse,color("0,0,0,0.6");vertalign,top;fadeleft,1);
		};
		Def.Quad{ --Graph BG
				Name="graphbg";
				--InitCommand=cmd(x,graphx;y,50+graphy;zoomto,100,graphheight+125;diffuse,color("0,0,0,0.4");vertalign,bottom);
				InitCommand=cmd(halign,1;x,graphx;y,0;zoomto,graphwidth,SCREEN_HEIGHT;diffuse,color("0.2,0.2,0.2,0.4");vertalign,top;);
		};
		Def.Quad{ -- AAA Grade Line
				Name="AAALine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= 1 then
						self:diffuse(color("1,0.8,0,0.4"));
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --AAA Text
                Name="AAALineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight-3;zoom,0.3;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('AAA');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if percentscore == maxps then
						self:diffuse(CustomGradeColor("Grade_Tier01"));
						self:diffusealpha(1);
					elseif dpscore == maxdp then
						self:diffuse(CustomGradeColor("Grade_Tier02"));
						self:diffusealpha(1);
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
        };
        LoadFont("Common Normal") .. { --AAA UpdateMessage
                Name="AAAUpdateMessage";
                InitCommand=cmd(x,graphx+50;y,graphy-graphheight*gradetier["Tier02"]-3;zoom,0.4;diffuse,color("1,1,1,0.8");vertalign,bottom;maxwidth,90*(1/0.4);visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('Rank AAA Pass');
						--self:visible(false);
					else
						self:visible(false)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier02"] then
						playedgrade['playedAAA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						--self:visible(false);
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" and playedgrade['playedAAA'] == false then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- AA Grade Line
				Name="AALine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*gradetier["Tier03"];zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier03"] then
						self:diffuse(color("1,0.8,0,0.4"));
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --AA Text
                Name="AALineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*gradetier["Tier03"]-3;zoom,0.3;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('AA');
						self:visible(true)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier03"] then
						self:diffuse(CustomGradeColor("Grade_Tier03"));
						self:diffusealpha(1);
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
        };
        LoadFont("Common Normal") .. { --AA UpdateMessage
                Name="AAUpdateMessage";
                InitCommand=cmd(x,graphx+50;y,graphy-graphheight*gradetier["Tier03"]-3;zoom,0.4;diffuse,color("1,1,1,0.8");vertalign,bottom;maxwidth,90*(1/0.4);visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('Rank AA Pass');
						--self:visible(false);
					else
						self:visible(false)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier03"] then
						playedgrade['playedAA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						--self:visible(false);
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" and playedgrade['playedAA'] == false then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- A Grade Line
				Name="ALine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*gradetier["Tier04"];zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier04"] then
						self:diffuse(color("1,0.8,0,0.4"));
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --A Text
                Name="ALineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*gradetier["Tier04"]-3;zoom,0.3;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('A');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier04"] then
						self:diffuse(CustomGradeColor("Grade_Tier04"));
						self:diffusealpha(1);
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
        };
        LoadFont("Common Normal") .. { --A UpdateMessage
                Name="AUpdateMessage";
                InitCommand=cmd(x,graphx+50;y,graphy-graphheight*gradetier["Tier04"]-3;zoom,0.4;diffuse,color("1,1,1,0.8");vertalign,bottom;maxwidth,90*(1/0.4);visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('Rank A Pass');
						--self:visible(false);
					else
						self:visible(false)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier04"] then
						playedgrade['playedA'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						--self:visible(false);
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" and playedgrade['playedA'] == false then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- B Grade Line
				Name="BLine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*gradetier["Tier05"];zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier05"] then
						self:diffuse(color("1,0.8,0,0.4"));
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --B Text
                Name="BLineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*gradetier["Tier05"]-3;zoom,0.3;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('B');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier05"] then
						self:diffuse(CustomGradeColor("Grade_Tier05"));
						self:diffusealpha(1);
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
        };
        LoadFont("Common Normal") .. { --B UpdateMessage
                Name="BUpdateMessage";
                InitCommand=cmd(x,graphx+50;y,graphy-graphheight*gradetier["Tier05"]-3;zoom,0.4;diffuse,color("1,1,1,0.8");vertalign,bottom;maxwidth,90*(1/0.4);visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('Rank B Pass');
						--self:visible(false);
					else
						self:visible(false)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier05"] then
						playedgrade['playedB'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						--self:visible(false);
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" and playedgrade['playedB'] == false then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- C Grade Line
				Name="CLine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*gradetier["Tier06"];zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier06"] then
						self:diffuse(color("1,0.8,0,0.4"));
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --C Text
                Name="CLineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*gradetier["Tier06"]-3;zoom,0.3;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('C');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier06"] then
						self:diffuse(CustomGradeColor("Grade_Tier06"));
						self:diffusealpha(1);
					else
						self:diffuse(color("1,1,1,0.4"));
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" then
						self:queuecommand("Set");
					end;
				end;
        };
        LoadFont("Common Normal") .. { --C UpdateMessage
                Name="CUpdateMessage";
                InitCommand=cmd(x,graphx+50;y,graphy-graphheight*gradetier["Tier06"]-3;zoom,0.4;diffuse,color("1,1,1,0.8");vertalign,bottom;maxwidth,90*(1/0.4);visible,false);
				BeginCommand=function(self)
					if graphmode == "DP" then
						self:settext('Rank C Pass');
						--self:visible(false);
					else
						self:visible(false)
					end;
				end;
				SetCommand=function(self)
					if dpscore/maxdp >= gradetier["Tier06"] then
						playedgrade['playedC'] = true
						self:stoptweening();
						self:visible(true);
						self:sleep(0.1);
						self:linear(0.2);
						self:x(graphx-graphwidth/2);
						self:sleep(3);
						self:linear(0.2);
						self:x(graphx+50);
						--self:visible(false);
					end;
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "DP" and playedgrade['playedC'] == false then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- 100% Line
				Name="100Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*1;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore == maxps then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore == maxmigs then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --100% Text
                Name="100LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*1-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('100%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore == maxps then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore == maxmigs then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- 90% Line
				Name="90Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*0.9;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.9 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.9 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --90% Text
                Name="90LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*0.9-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('90%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.9 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.9 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- 80% Line
				Name="80Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*0.8;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.8 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.8 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --80% Text
                Name="80LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*0.8-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('80%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.8 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.8 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- 70% Line
				Name="70Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*0.7;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.7 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.7 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --70% Text
                Name="70LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*0.7-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('70%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.7 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.7 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };
		Def.Quad{ -- 60% Line
				Name="60Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*0.6;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.6 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.6 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --60% Text
                Name="60LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*0.6-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('60%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.6 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.6 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };	
		Def.Quad{ -- 50% Line
				Name="50Line";
				InitCommand=cmd(halign,1;x,graphx;y,graphy-graphheight*0.5;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,false);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.5 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.5 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
		};
		LoadFont("Common Normal") .. { --50% Text
                Name="50LineText";
                InitCommand=cmd(halign,0;x,graphx-(graphwidth)+2;y,graphy-graphheight*0.5-3;zoom,0.25;diffuse,color("1,1,1,0.4");vertalign,bottom);
				BeginCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:settext('50%');
						self:visible(true);
					end;
				end;
				SetCommand=function(self)
					if graphmode == "PS" then
						if percentscore >= maxps*0.5 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;
					if graphmode == "MIGS" then
						if migsscore >= maxmigs*0.5 then
							self:diffuse(color("1,0.8,0,0.4"));
						else
							self:diffuse(color("1,1,1,0.4"));
						end;
					end;	
				end;
				JudgmentMessageCommand=function(self)
					if graphmode == "PS" or graphmode =="MIGS" then
						self:queuecommand("Set");
					end;
				end;
        };
        Def.Quad{ -- Base Line
				Name="BaseLine";
				InitCommand=cmd(halign,1;x,graphx;y,graphy;zoomto,graphwidth,2;diffuse,color("1,1,1,0.4");vertalign,bottom;visible,true);
		};
		LoadFont("Common Normal") .. { --Pacemaker Curscore
                Name="Pacemaker Curscore";
                InitCommand=cmd(x,graphx-5;y,65-1;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0);
				end;
				SetCommand=function(self)
					if graphmode == 'DP' then
						self:settext(dpscore);
					elseif graphmode == 'PS' then
						self:settext(percentscore);
					elseif graphmode == 'MIGS' then
						self:settext(migsscore);
					else
						self:visible(false);
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
        };
        LoadFont("Common Normal") .. { --Pacemaker username
                Name="Pacemaker username";
                InitCommand=cmd(x,graphx-graphwidth+2;y,65;zoom,0.4;horizalign,left;maxwidth,(graphwidth-30)/0.4);
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					if graphmode == 'DP' then
						self:settext(p1name);
					end;
				end;
        };
		LoadFont("Common Normal") .. { --Pacemaker TargetScore
                Name="Pacemaker_TargetScore";
                InitCommand=cmd(x,graphx-5;y,75-1;zoom,0.35;horizalign,right);
				BeginCommand=function(self)
					self:settext(0);
				end;
				SetCommand=function(self)
					if graphmode == 'DP' then
						self:settext(math.ceil(curmaxdp*target));
					elseif graphmode == 'PS' then
						self:settext(math.ceil(curmaxps*target));
					elseif graphmode == 'MIGS' then
						self:settext(math.ceil(curmaxmigs*target));
					else
						self:visible(false);
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
        };
        LoadFont("Common Normal") .. { --Pacemaker Label
                Name="Pacemaker_TargetScore";
                InitCommand=cmd(x,graphx-graphwidth+2;y,75;zoom,0.4;horizalign,left);
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					self:settext('Pacemaker');
				end;
        };
		Def.Quad{ --CurrentTargetBar
				Name="CurrentTargetBar";
				InitCommand=cmd(x,graphx-graphwidth*0.3;y,graphy;zoomx,graphwidth*0.3;diffuse,color("#ff9999");vertalign,bottom;visible,true;diffuseshift;effectcolor1,color("1,0.5625,0.5625,0.5");effectcolor2,color("1,0.5625,0.5625,0.4");effectperiod,2;);
				
				SetCommand=function(self)
					if graphmode == "DP" then
						self:zoomtoheight(((curmaxdp/maxdp)*(graphheight-1)*target)+1);
					elseif graphmode == "PS" then
						self:zoomtoheight(((curmaxps/maxps)*(graphheight-1)*target)+1);
					elseif graphmode == "MIGS" then
						self:zoomtoheight(((curmaxmigs/maxmigs)*(graphheight-1)*target)+1);
					else
						self:visible(false);
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { -- TargetScore
			Name="TargetScore";
			InitCommand=cmd(x,graphx-graphwidth*0.3;y,graphy-10;zoom,0.45;);
			BeginCommand=function(self)
					self:settext('0')
			end;
			SetCommand=function(self,params)
				if graphmode == "DP" then
					self:settext(math.ceil(curmaxdp*target))
				elseif graphmode == "PS" then
					self:settext(math.ceil(curmaxps*target))
				elseif graphmode == "MIGS" then
					self:settext(math.ceil(curmaxmigs*target))
				else
					self:visible(false)
				end;
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		Def.Quad{ --CurrentScoreBar
				Name="CurrentScoreBar";
				InitCommand=cmd(x,graphx-graphwidth*0.7;y,graphy;zoomx,graphwidth*0.3;diffuse,color("#99ccff");vertalign,bottom;visible,true;diffuseshift;effectcolor1,color("0.5625,0.75,1,0.5");effectcolor2,color("0.5625,0.75,1,0.4");effectperiod,2;);
				SetCommand=function(self)
					if graphmode == "DP" then
						local dpscoregraph = dpscore
						if dpscoregraph < 0 then
							dpscoregraph = 0
						end;
						self:zoomtoheight((dpscoregraph/maxdp*(graphheight-1))+1);
					elseif graphmode == "PS" then
						local psscoregraph = percentscore
						if psscoregraph < 0 then
							psscoregraph = 0
						end;
						self:zoomtoheight((psscoregraph/maxps*(graphheight-1))+1);
					elseif graphmode == "MIGS" then
						local migsscoregraph = migsscore
						if migsscoregraph < 0 then
							migsscoregraph = 0
						end;
						self:zoomtoheight((migsscoregraph/maxmigs*(graphheight-1))+1);
					else
						self:visible(false);
					end;
				end;
				JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { -- CurrentScore
			Name="CurrentScore";
			InitCommand=cmd(x,graphx-graphwidth*0.7;y,graphy-10;zoom,0.45;);
			BeginCommand=function(self)
					self:settext('0')
			end;
			SetCommand=function(self,params)
				if graphmode == "DP" then
					self:settext(dpscore)
				elseif graphmode == "PS" then
					--self:y(textpos);
					self:settext(percentscore)
				elseif graphmode == "MIGS" then
					--self:y(textpos);
					self:settext(migsscore)
				else
					self:visible(false)
				end;
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set");
		};
		LoadFont("Common Normal") .. { -- GraphType (Player)
			InitCommand=cmd(x,graphx-graphwidth/2;y,graphy+10;zoom,0.45;diffuse,color("#99ccff"));
			BeginCommand=function(self)
				self:settext(p1name..' '..graphmode)
			end;
		};
		LoadFont("Common Normal") .. { -- GraphType (Target)
			InitCommand=cmd(x,graphx-graphwidth/2;y,graphy+25;zoom,0.45;diffuse,color("#ff9999"));
			BeginCommand=function(self)
				if graphmode == "DP" then
					if target == 1 then
						self:settext('Rank AAA')
					elseif target == gradetier["Tier03"] then
						self:settext('Rank AA')
					elseif target == gradetier["Tier04"] then
						self:settext('Rank A')
					elseif target == gradetier["Tier05"] then
						self:settext('Rank B')
					elseif target == gradetier["Tier06"] then
						self:settext('Rank C')
					else
						self:settext('DP '..tostring(target*100)..'%')
					end;
				elseif graphmode == "PS" then
					self:settext(tostring(target*100)..'%')
				else
					self:settext('MIGS '..tostring(target*100)..'%')
				end;
			end;
		};
		LoadFont("Common Normal") .. { -- Target Difference / Ghost Score
			Name="TargetDiff";
			InitCommand=cmd(x,SCREEN_CENTER_X+52;y,SCREEN_CENTER_Y+23;zoom,0.45;diffuse,color("#ff9999");horizalign,left);
			BeginCommand=function(self)
				self:settext('+0')
				self:visible(false)
				if GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse() == true then
					self:y(SCREEN_CENTER_Y-36)
				end;
				if center1P == false then
					self:x((SCREEN_CENTER_X*0.57)+52)
				end;
			end;
			SetCommand=function(self,params)
				if STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetCurrentCombo() > 1 then
					self:visible(true);
				else
					self:visible(false);
				end;
				local targetdiff = 0
				if graphmode == "DP" then
					targetdiff = dpscore-(math.ceil(curmaxdp*target))
				elseif graphmode == "PS" then
					targetdiff = percentscore-(math.ceil(curmaxps*target))
				elseif graphmode == "MIGS" then
					targetdiff = migsscore-(math.ceil(curmaxmigs*target))
				end;
				if targetdiff > 0 then
					self:settext('+'..targetdiff)
					self:diffuse(color("#66ccff"))
				elseif targetdiff == 0 then
					self:settext('+'..targetdiff)
					self:diffuse(color("#FFFFFF"))
				else
					self:settext('-'..(math.abs(targetdiff)))
					self:diffuse(color("#FF9999"))
				end;
			end;
			JudgmentMessageCommand=function(self,params)
				self:queuecommand("Set");
			end;
		};
		LoadFont("Common Normal") .. { -- Current/Average Percentage Score
			Name="AvgScore";
			InitCommand=cmd(x,SCREEN_CENTER_X+50;y,SCREEN_CENTER_Y+23;zoom,0.45;diffuse,color("#ffffff");horizalign,right);
			BeginCommand=function(self)
				self:settext('0.00%')
				self:visible(false)
				if GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse() == true then
					self:y(SCREEN_CENTER_Y-36)
				end;
				if center1P == false then
					self:x((SCREEN_CENTER_X*0.57)+50)
				end;
			end;
			SetCommand=function(self,params)
				if STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetCurrentCombo() > 1 then
					self:visible(true);
				else
					self:visible(false);
				end;
				if avgscoremode == "DP" then
					if curmaxdp ~= 0 then
						self:settextf("%.2f%%",(math.floor(dpscore/curmaxdp*10000))/100); 
					else
						self:settext('0.00%')
					end;
				elseif avgscoremode == "PS" then
					if curmaxps ~= 0 then
						self:settextf("%.2f%%",(math.floor(percentscore/curmaxps*10000))/100); 
					else
						self:settext('0.00%')
					end;
				elseif avgscoremode == "MIGS" then
					if curmaxmigs ~= 0 then
						self:settextf("%.2f%%",(math.floor(migsscore/curmaxmigs*10000))/100); 
					else
						self:settext('0.00%')
					end;
				end;
			end;
			JudgmentMessageCommand=function(self)
				self:queuecommand("Set");
			end;
		};
		
	};
};
return t;

