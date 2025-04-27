%% FLP Project 2 - Graph Spanning Tree
%% Author: Pavel Osinek (xosine00)
%% Date: April 27, 2025
%% This Prolog program prints all possible spanning trees of an undirected graph given on input.

%% spanning_tree(+Nodes:list, +Edges:list, -Tree:list)
%
%  Finds a spanning tree of the given undirected graph.
%
spanning_tree(Nodes, Edges, Tree) :-
    length(Nodes, N),
    N > 0,
    N1 is N - 1,
    select_k_elements(N1, Edges, Tree),
    covers_all_nodes(Tree, Nodes),
    is_valid_tree(Tree, Nodes).

%% is_valid_tree(+Edges:list, +Nodes:list)
%
%  Succeeds if Edges form a valid tree over Nodes.
%
is_valid_tree(Edges, Nodes) :-
    length(Edges, M),
    length(Nodes, N),
    M =:= N - 1,
    is_connected(Edges, Nodes).

%% covers_all_nodes(+Edges:list, +Nodes:list)
%
%  Succeeds if all Nodes are present in Edges.
%
covers_all_nodes([], Nodes) :-
    length(Nodes, 1), !.
covers_all_nodes(Edges, Nodes) :-
    setof(N, A^B^(member(A-B, Edges), (N = A ; N = B)), Covered),
    sort(Nodes, Sorted),
    Covered == Sorted.

%% is_connected(+Edges:list, +Nodes:list)
%
%  Succeeds if all Nodes are connected by Edges.
%
is_connected(Edges, Nodes) :-
    Nodes = [Start|_],
    reachable(Start, Edges, Reachable),
    sort(Reachable, SortedReachable),
    sort(Nodes, SortedNodes),
    SortedReachable == SortedNodes.

%% reachable(+Start:atom, +Edges:list, -Reachable:list)
%
%  Finds all nodes reachable from Start using Edges.
%
reachable(Start, Edges, Reachable) :-
    bfs([Start], Edges, [], Reachable).

%% bfs(+Queue:list, +Edges:list, +Visited:list, -Reachable:list)
%
%  Performs BFS to collect all reachable nodes.
%
bfs([], _, Visited, Visited).
bfs([Current|Queue], Edges, Visited, Reachable) :-
    member(Current, Visited), !,
    bfs(Queue, Edges, Visited, Reachable).
bfs([Current|Queue], Edges, Visited, Reachable) :-
    neighbors_of(Current, Edges, Neighbors),
    append(Queue, Neighbors, NewQueue),
    bfs(NewQueue, Edges, [Current|Visited], Reachable).

%% neighbors_of(+Node:atom, +Edges:list, -Neighbors:list)
%
%  Returns list of neighbors for Node in Edges.
%
neighbors_of(Node, Edges, Neighbors) :-
    findall(Neighbor,
        ( member(A-B, Edges),
          (A == Node, Neighbor = B ; B == Node, Neighbor = A),
          Neighbor \= Node ),
        Neighbors).

%% sort_edge(+Edge:pair, -SortedEdge:pair)
%
%  Normalizes undirected edge so that smaller node comes first.
%
sort_edge(A-B, A-B) :- A @=< B, !.
sort_edge(A-B, B-A).

%% select_k_elements(+K:integer, +List:list, -Combination:list)
%
%  Selects K elements from List as combination (combinatorial).
%
select_k_elements(0, _, []).
select_k_elements(K, [X|Xs], [X|Ys]) :-
    K > 0, K1 is K - 1,
    select_k_elements(K1, Xs, Ys).
select_k_elements(K, [_|Xs], Ys) :-
    K > 0,
    select_k_elements(K, Xs, Ys).

%% print_spanning_trees(+Nodes:list, +Edges:list)
%
%  Prints all possible spanning trees of the given graph.
%
print_spanning_trees(Nodes, Edges) :-
    spanning_tree(Nodes, Edges, Tree),
    print_tree(Tree),
    (spanning_tree(Nodes, Edges, _) -> nl ; true),
    fail.
print_spanning_trees(_, _).

%% print_tree(+Tree:list)
%
%  Prints edges of a spanning tree.
%
print_tree([Edge]) :- !,
    print_edge(Edge).
print_tree([Edge|Rest]) :-
    print_edge(Edge),
    write(' '),
    print_tree(Rest).

%% print_edge(+Edge:pair)
%
%  Prints a single edge A-B.
%
print_edge(A-B) :-
    write(A), write('-'), write(B).

%% Input parsing logic

%% start
%
%  Reads edges from input and prints all spanning trees.
%
start :-
    prompt(_, ''),
    read_lines(Lines),
    split_lines(Lines, Split),
    filter_lines(Split, Filtered),
    process_edge_lines(Filtered, RawEdges),
    normalize_edges(RawEdges, Edges),
    ( Edges == [] ->
        halt ;
        extract_nodes(Edges, Nodes),
        ( length(Nodes, N), N < 2 ->
            halt ;
            print_spanning_trees(Nodes, Edges),
            halt
        )
    ).

%% read_lines(-Lines:list)
%
%  Reads all lines from input as character lists.
%
read_lines(Lines) :-
    read_line(Line, Char),
    ( Char == end_of_file -> Lines = []
    ; read_lines(Rest), Lines = [Line|Rest]
    ).

%% read_line(-Line:list, -Char:char)
%
%  Reads a line into a list of characters.
%
read_line(L, C) :-
    get_char(C),
    ( iseofeol(C), L = [], ! ;
      read_line(L1, _), L = [C|L1] ).

%% iseofeol(+Char:char)
%
%  True if Char is end of file or newline.
%
iseofeol(C) :-
    C == end_of_file ;
    char_code(C, Code), Code == 10.

%% split_lines(+Lines:list, -Split:list)
%
%  Splits all character lines into word lists.
%
split_lines([], []).
split_lines([L|Ls], [H|T]) :-
    split_line(L, H),
    split_lines(Ls, T).

%% split_line(+Line:list, -Words:list)
%
%  Splits a character list into words separated by space.
%
split_line([], [[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T, S1).
split_line([32|T], [[]|S1]) :- !, split_line(T, S1).
split_line([H|T], [[H|G]|S1]) :- split_line(T, [G|S1]).

%% filter_lines(+Lines:list, -Filtered:list)
%
%  Filters out lines that are not valid edge definitions.
%
filter_lines([], []).
filter_lines([Line|Rest], [Line|Filtered]) :-
    valid_edge_line(Line), !,
    filter_lines(Rest, Filtered).
filter_lines([_|Rest], Filtered) :-
    filter_lines(Rest, Filtered).

%% valid_edge_line(+Line:list)
%
%  True if Line represents a valid edge (two different non-empty strings).
%
valid_edge_line([A, B]) :-
    A \= [], B \= [], A \= B.

%% process_edge_lines(+SplitLines:list, -Edges:list)
%
%  Converts split input into normalized edge terms.
%
process_edge_lines([], []).
process_edge_lines([Line|Rest], Edges) :-
    process_edge_line(Line, Edge),
    process_edge_lines(Rest, TailEdges),
    ( var(Edge) -> Edges = TailEdges ; Edges = [Edge|TailEdges] ).

%% process_edge_line(+Line:list, -Edge:pair)
%
%  Converts one input line into a normalized edge term, ignoring invalid lines.
%
process_edge_line([[A], [B]], Edge) :-
    atom_string(AtomA, A),
    atom_string(AtomB, B),
    AtomA \== AtomB,
    atom_codes(AtomA, [CodeA]),
    atom_codes(AtomB, [CodeB]),
    between(65, 90, CodeA),
    between(65, 90, CodeB),
    sort_edge(AtomA-AtomB, Edge), !.
process_edge_line(_, _) :- fail.

%% normalize_edges(+Edges:list, -UniqueEdges:list)
%
%  Normalizes and deduplicates edges.
%
normalize_edges([], []).
normalize_edges(Edges, UniqueEdges) :-
    maplist(sort_edge, Edges, Normalized),
    sort(Normalized, UniqueEdges).

%% extract_nodes(+Edges:list, -Nodes:list)
%
%  Extracts a sorted list of unique nodes from edges.
%
extract_nodes(Edges, Nodes) :-
    findall(N, (
        member(A-B, Edges),
        (N = A ; N = B)
    ), All),
    sort(All, Nodes).