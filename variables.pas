type tPlayer = record
    voted: boolean;
    active: boolean;
end;

var player: array [1..32] of tPlayer;

type tVote = record
    ongoing: boolean;
    succeeded: boolean;
    prompted: boolean;
    count: byte;
    time: integer;
    name: string;
end;

var vote: tVote;

type eTriggerAction = (trigNone,
                       trigVoteNextMap,
                       trigVoteSpecificMap);

type eCommandAction = (cmdNone,
                       cmdChangeMap);

type eLogSeverity = (sevInfo,
                     sevWarning,
                     sevError);