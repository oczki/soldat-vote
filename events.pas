procedure AppOnIdle(ticks: integer);
begin
    if (ticks mod AppOnIdleTimer <> 0) then exit;
    
    if (vote.ongoing) and not (vote.succeeded) then begin
        if (vote.time > 0) then begin
            dec(vote.time, 1);
            if (vote.time = 15) then
                showPrompt();
        end else begin
            endVote();
        end;
    end;
end;

procedure ActivateServer();
begin
    clearData();
end;

procedure OnLeaveGame(id, teamId: byte; kicked: boolean);
begin
    removeVote(id);
    player[id].active := false;
    if (playerCount() > 0) then
        maybeChangeMap()
    else
        endVote();
end;

procedure OnJoinTeam(id, team: byte);
begin
    if (getplayerstat(id, 'human')) then
        player[id].active := true;
end;

procedure OnMapChange(newmap: string);
begin
    clearData();
end;

procedure OnGameEnd();
begin
    clearData();
    vote.succeeded := true;
end;

procedure OnPlayerSpeak(caller: byte; text: string);
var action: eTriggerAction;
begin
    action := getTriggerAction(text);
    if (action = trigNone) then exit;

    case (action) of
        trigVoteNextMap:
            maybeAddVote(caller);
        trigVoteSpecificMap:
            maybeAddVoteForSpecificMap(caller, getpiece(text, ' ', 1));
    end;
end;

function OnCommand(id: byte; text: string): boolean;
var action: eCommandAction;
begin
    action := getCommandAction(text);
    if (action = cmdNone) then exit;

    case (action) of
        cmdChangeMap:
            vote.succeeded := true;
    end;

    result := false;
end;