% Grammar Checker (Prolog version)
%
% Reads sentences from inputs/grammar/sentences.txt, checks each one
% against a small English grammar, and writes the results to
% output/prolog/grammar.txt.
%
% Run from the project folder:
%   swipl prolog/grammar/grammar.pl

% initialization(main, main) runs main/0 once the file is loaded and
% then halts. If main fails or throws, swipl exits with a non-zero code.
:- initialization(main, main).

% prolog_load_context/2 gives the folder this file was loaded from, so
% the input and output paths work no matter where swipl is started.
% The value is stored as a fact with assertz/1 so main/0 can look it up.
:- dynamic script_dir/1.
:- prolog_load_context(directory, Dir), assertz(script_dir(Dir)).


% ---------------------------------------------------------------------
% Grammar rules
%
% These are DCG rules (written with -->). Prolog translates each rule
% into an ordinary predicate with two extra hidden arguments: the list
% of words before the rule runs and the words left over after it. So
% the grammar itself is the parser; there is no separate parsing code.
%
% Extra arguments on a rule are passed along like normal predicate
% arguments. Here they carry:
%   Mode - strict (number must agree) or loose (agreement ignored)
%   Num  - singular or plural, filled in by unification
%   Tree - the parse tree built while the sentence is matched
% ---------------------------------------------------------------------

% sentence --> noun_phrase verb_phrase
% The same variable Num appears in both parts. Unification forces the
% subject and the verb to have the same number, which is how
% "the dogs chases the cat" gets rejected.
sentence(Mode, s(NP, VP)) -->
    noun_phrase(Mode, Num, NP),
    verb_phrase(Mode, Num, VP).

% noun_phrase --> determiner adjective* noun prep_phrase*
% Code inside { } is plain Prolog that runs during parsing without
% consuming any words. =.. ("univ") builds a term from a list, so
% NP =.. [np, det(the), n(dog)] makes NP = np(det(the), n(dog)).
% This lets the tree leave out parts that are not there.
noun_phrase(Mode, Num, NP) -->
    determiner(Mode, Num, Det),
    adjectives(Adjs),
    noun(Num, Noun),
    prep_phrases(Mode, PPs),
    { append([Det|Adjs], [Noun|PPs], Parts),
      NP =.. [np|Parts] }.

% verb_phrase --> verb object? prep_phrase*
% The verb's lexicon entry says whether it is transitive. That value is
% passed to object//3, so only transitive verbs can take an object.
verb_phrase(Mode, Num, VP) -->
    verb(Mode, Num, Type, Verb),
    object(Mode, Type, Obj),
    prep_phrases(Mode, PPs),
    { append([Verb|Obj], PPs, Parts),
      VP =.. [vp|Parts] }.

object(Mode, transitive, [NP]) --> noun_phrase(Mode, _, NP).
object(_, intransitive, []) --> [].

% Zero or more adjectives. The first clause is tried first, so the rule
% takes as many adjectives as it can. If the rest of the sentence then
% fails, Prolog backtracks into the second clause automatically.
adjectives([adj(A)|As]) --> [A], { adjective(A) }, adjectives(As).
adjectives([]) --> [].

% Zero or more prepositional phrases. A prepositional phrase contains a
% noun phrase, and a noun phrase can contain more prepositional
% phrases, so the two rules call each other recursively.
prep_phrases(Mode, [PP|PPs]) --> prep_phrase(Mode, PP), prep_phrases(Mode, PPs).
prep_phrases(_, []) --> [].

prep_phrase(Mode, pp(prep(P), NP)) -->
    [P], { preposition(P) },
    noun_phrase(Mode, _, NP).

% Single-word rules. [W] in a DCG body matches exactly one word from
% the input list and binds it to W.
determiner(Mode, Num, det(W)) -->
    [W], { det(W, DetNum), agree(Mode, DetNum, Num) }.

noun(Num, n(W)) -->
    [W], { noun(W, Num) }.

verb(Mode, Num, Type, v(W)) -->
    [W], { verb(W, VerbNum, Type), agree(Mode, VerbNum, Num) }.

% agree/3 is where the two modes differ. In strict mode both numbers
% must unify. In loose mode anything passes. Running the same grammar
% in loose mode tells us whether a rejected sentence failed only
% because of agreement.
agree(strict, Num, Num).
agree(loose, _, _).


% ---------------------------------------------------------------------
% Lexicon
%
% Each word is a fact. An unbound second argument, as in det(the, _),
% means the word works with both singular and plural.
% ---------------------------------------------------------------------

det(the, _).
det(a, singular).
det(every, singular).
det(two, plural).
det(many, plural).

noun(dog, singular).        noun(dogs, plural).
noun(cat, singular).        noun(cats, plural).
noun(student, singular).    noun(students, plural).
noun(teacher, singular).    noun(teachers, plural).
noun(professor, singular).  noun(professors, plural).
noun(book, singular).       noun(books, plural).
noun(ball, singular).       noun(balls, plural).
noun(park, singular).       noun(parks, plural).

adjective(big).
adjective(small).
adjective(lazy).
adjective(happy).
adjective(old).
adjective(red).

verb(chases, singular, transitive).     verb(chase, plural, transitive).
verb(sees, singular, transitive).       verb(see, plural, transitive).
verb(likes, singular, transitive).      verb(like, plural, transitive).
verb(reads, singular, transitive).      verb(read, _, transitive).
verb(chased, _, transitive).
verb(sleeps, singular, intransitive).   verb(sleep, plural, intransitive).
verb(runs, singular, intransitive).     verb(run, plural, intransitive).
verb(laughs, singular, intransitive).   verb(laugh, plural, intransitive).

preposition(in).
preposition(on).
preposition(with).
preposition(near).

known_word(W) :- det(W, _).
known_word(W) :- noun(W, _).
known_word(W) :- adjective(W).
known_word(W) :- verb(W, _, _).
known_word(W) :- preposition(W).


% ---------------------------------------------------------------------
% Checking a sentence
%
% classify/2 tries its clauses from top to bottom. The cut (!) stops
% Prolog from trying the later clauses once one has succeeded, so each
% sentence gets exactly one result.
% ---------------------------------------------------------------------

% phrase/2 runs a DCG rule on a word list and succeeds only if every
% word is used up. A sentence can have more than one parse (for
% example, which noun a "with ..." phrase attaches to); the cut keeps
% the first one.
classify(Words, valid(Tree)) :-
    phrase(sentence(strict, Tree), Words), !.
classify(Words, invalid(Reason)) :-
    member(W, Words), \+ known_word(W), !,
    format(atom(Reason), "unknown word '~w'", [W]).
classify(Words, invalid('number agreement error')) :-
    phrase(sentence(loose, _), Words), !.
classify(_, invalid('does not match the grammar')).

% Lowercases the line and splits it on spaces and tabs. The third
% argument of split_string/4 lists characters to strip from both ends
% of each piece, which removes punctuation like "dog." -> "dog".
tokenize(Line, Words) :-
    string_lower(Line, Lower),
    split_string(Lower, " \t", " \t.,!?;:\"'()-", Pieces),
    exclude(==(""), Pieces, NonEmpty),
    maplist(atom_string, Words, NonEmpty).

% Builds one output line in the form:
%   STATUS | sentence | parse tree or reason
result_line(Line, Text) :-
    tokenize(Line, Words),
    classify(Words, Result),
    (   Result = valid(Tree)
    ->  format(string(Text), "VALID | ~w | ~w", [Line, Tree])
    ;   Result = invalid(Reason),
        format(string(Text), "INVALID | ~w | ~w", [Line, Reason])
    ).


% ---------------------------------------------------------------------
% File input and output
% ---------------------------------------------------------------------

read_lines(File, Lines) :-
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", " \t\r", Raw),
    exclude(==(""), Raw, Lines).

% setup_call_cleanup/3 makes sure the output file is closed even if
% something in the middle throws an error.
main :-
    script_dir(Dir),
    atomic_list_concat([Dir, '/../../inputs/grammar/sentences.txt'], InFile),
    atomic_list_concat([Dir, '/../../output/prolog/grammar.txt'], OutFile),
    read_lines(InFile, Lines),
    maplist(result_line, Lines, Results),
    setup_call_cleanup(
        open(OutFile, write, Out),
        forall(member(R, Results), format(Out, "~w~n", [R])),
        close(Out)),
    forall(member(R, Results), format("~w~n", [R])).
