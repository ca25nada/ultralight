function gradestring(tier) --to be moved
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

local lines = 9 -- number of scores to display
local profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]
local steps = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPlayedSteps()[1]
local scoreP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetHighScore();
local hstable = profileP1:GetHighScoreList(song,steps):GetHighScores()
local scoreindex = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPersonalHighScoreIndex()+1
local framex = WideScale(350,400)
local framey = 160
local spacing = 35


local t = Def.ActorFrame{};

local function scoreitem(index,scoreindex,drawindex)
	local equals = (index == scoreindex)
	local t = Def.ActorFrame {
		Def.Quad{
			InitCommand=cmd(xy,framex-40,framey+(drawindex*spacing)-4;zoomto,350,30;halign,0;valign,0;diffuse,color("#333333");diffusealpha,0.5;diffuserightedge,color("#33333300"));
			BeginCommand=function(self)
				self:visible(IsPlayerValid(PLAYER_1));
			end;
		};

		Def.Quad{
			InitCommand=cmd(xy,framex-40,framey+(drawindex*spacing)-4;zoomto,350,30;halign,0;valign,0;diffuse,color("#66ccff");diffusealpha,0.2;diffuserightedge,color("#33333300"));
			BeginCommand=function(self)
				self:visible(IsPlayerValid(PLAYER_1) and equals);
			end;
		};


		--rank
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex-38,framey+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)
				if #hstable >= 1 then
					self:settext("Rank: "..index)
					if equals then
						self:diffuseshift()
						self:effectcolor1(color("#ffcccc"))
						self:effectcolor2(color("#3399cc"))
						self:effectperiod(0.1)
					else
						self:stopeffect()
					end;
				end;
			end;
		};

		--grade and %score
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)

				if #hstable >= 1  and index>= 1 then
					local difference = (hstable[index]:GetPercentDP() - hstable[scoreindex]:GetPercentDP()) * 100
					if difference >= 0 then
						difference = string.format("(+%.2f%%)",difference)
					else
						difference = string.format("(%.2f%%)",difference)
					end
					self:settextf("%s %.2f%% %s",(gradestring(hstable[index]:GetGrade())),hstable[index]:GetPercentDP()*100,difference); 
				end;
			end;
		};

		--cleartype
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex,framey+9+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)
				if #hstable >= 1 and index>= 1 then
					self:settext(getClearTypeP1(hstable[index]))
					self:diffuse(getClearColorP1(hstable[index]))
				end;
			end;
		};

		--datetime
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex,framey+19+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)
				if #hstable >= 1 and index>= 1 then
					self:settext(hstable[index]:GetDate())
				end;
			end;
		};


	};
	return t;
end

if lines > #hstable then
	lines = #hstable
end;

local drawindex = 0
local startind = 1
local finishind = lines+startind-1

-- Sets the range of indexes to display depending on your rank
if scoreindex>math.floor(#hstable-lines/2) then
	startind = #hstable-lines+1
	finishind = #hstable 
elseif scoreindex>math.floor(lines/2) then
	finishind = scoreindex + math.floor(lines/2)
	if lines%2 == 1 then
		startind = scoreindex - math.floor(lines/2)
	else
		startind = scoreindex - math.floor(lines/2)+1
	end;
end;

while drawindex<#hstable and startind<=finishind do
	t[#t+1] = scoreitem(startind,scoreindex,drawindex)
	startind = startind+1
	drawindex  = drawindex+1
end;

t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex-38,framey-15;zoom,0.35;halign,0);
	BeginCommand=function(self)
		self:settext("Rank "..scoreindex.." / "..(#hstable))
	end;
};


--[[
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex,framey+10+(spacing);zoom,1;halign,0);
	BeginCommand=function(self)
		self:settext(scoreindex)
	end;
};
--]]

return t;