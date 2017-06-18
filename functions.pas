function getTriggerAction(inputText: string): eTriggerAction;
var text: string;
begin
    result := trigNone;
    text := lowercase(inputText);
    case (text) of
        '!vot', '!vote', '!votemap', '!votenext', '!votenextmap', '!next', '!nextmap':
            result := trigVoteNextMap;
    end;

    if (result <> trigNone) then exit;

    if (lowercase(getpiece(inputText, ' ', 0)) = '!vote') and (length(getpiece(inputText, ' ', 1)) >= 1) then
        result := trigVoteSpecificMap;
end;

function getCommandAction(inputText: string): eCommandAction;
var text: string;
begin
    result := cmdNone;
    text := lowercase(getpiece(text, ' ', 0));
    case (text) of
        '/map', '/nextmap', '/restart':
            result := cmdChangeMap;
    end;
end;

function calcNeededVotes(currentPercentage: extended): byte;
begin
    result := ceil(0.01 * playerCount() * (PercentThreshold - currentPercentage));
end;

function calcCurrentPercentage(): extended;
begin
    if (playerCount() = 0) then
        result := 0.0
    else
        result := 100.0 * vote.count / playerCount();
end;

procedure showPrompt();
var neededVotes: byte;
begin
    if (vote.prompted) then exit;

    neededVotes := calcNeededVotes(calcCurrentPercentage());
    logWarning(0, 'Still need ' + inttostr(neededVotes) + ' more ' + plural(neededVotes, 'vote') +
                  ' to change map to ' + vote.name + '.');
    vote.prompted := true;
end;

procedure clearData();
var i: byte;
begin
    for i := 1 to 32 do begin
        player[i].voted := false;
        player[i].active := getplayerstat(i, 'active') and getplayerstat(i, 'human');
    end;

    vote.ongoing := false;
    vote.succeeded := false;
    vote.prompted := false;
    vote.count := 0;
    vote.time := VoteDurationBase;
    vote.name := '';
end;

procedure changeMap();
begin
    vote.succeeded := true;
    logInfo(0, 'Vote passed.');
    logInfo(255, 'Vote passed.');

    if (vote.name = NextMap) then
        command('/nextmap')
    else
        command('/map ' + vote.name);
end;

procedure maybeChangeMap();
var neededVotes: byte;
    currentPercentage: extended;
    text: string;
begin
    if (not vote.ongoing) or (vote.succeeded) then exit;

    currentPercentage := calcCurrentPercentage();
    if (currentPercentage >= PercentThreshold) then begin
        changeMap();
    end else begin
        neededVotes := calcNeededVotes(currentPercentage);
        text := 'Need ' + inttostr(neededVotes) + ' more ' + plural(neededVotes, 'vote') + ' for the vote to pass.' +
                ' (' + inttostr(round(currentPercentage)) + '% / ' + inttostr(PercentThreshold) + '%)';
        logInfo(0, text);
        logInfo(255, text);
    end;
end;

procedure endVote();
begin
    if (vote.ongoing) then begin
        logError(0, 'Vote failed.');
        logError(255, 'Vote failed.');
    end;
    clearData();
end;

procedure startVote();
begin
    if (vote.name = '') then
        vote.name := NextMap;

    if (calcCurrentPercentage() < PercentThreshold) then
        logInfo(0, 'Type !vote to vote for ' + vote.name + '.');

    vote.ongoing := true;
end;

procedure removeVote(playerId: byte);
begin
    if (player[playerId].voted) then begin
        player[playerId].voted := false;
        dec(vote.count, 1);
    end;
end;

procedure addVote();
begin
    inc(vote.count, 1);

    if (vote.ongoing) then
        inc(vote.time, VoteDurationBumpOnNewVote)
    else
        startVote();

    maybeChangeMap();
end;

function canVote(playerId: byte): boolean;
begin
    if (vote.succeeded) then begin
        result := false;
        exit;
    end;

    if (player[playerId].voted) then begin
        logWarning(playerId, 'You have already voted.');
        logWarning(255, 'Not counting the vote (already voted).');
        result := false;
        exit;
    end;

    if (not SpectatorsCanVote) and (getplayerstat(playerId, 'Team') = 5) then begin
        logError(0, 'Spectators have no voting rights.');
        logError(255, 'Not counting the vote (spectator).');
        result := false;
        exit;
    end;

    result := true;
end;

procedure maybeAddVote(playerId: byte);
begin
    if (not canVote(playerId)) then exit;

    player[playerId].voted := true;
    addVote();
end;

procedure maybeAddVoteForSpecificMap(playerId: byte; inputMapName: string);
var mapName: string;
begin
    if (not canVote(playerId)) then exit;

    mapName := getMapName(inputMapName);

    if (vote.ongoing) then begin
        if (mapName = vote.name) then
            maybeAddVote(playerId)
        else begin
            logError(0, 'There''s an ongoing vote for ' + vote.name + '. Can''t start a vote for another one.');
            logError(255, 'Not counting the vote (ongoing vote for another map).');
        end;
        exit;
    end;

    if (mapName = '') then begin
        logError(0, 'Couldn''t find any map with this name. Check the spelling and try again.');
        logError(255, 'Not counting the vote (no such map).');
        exit;
    end;

    vote.name := mapName;
    maybeAddVote(playerId);
end;