module Minmax where
import Data.Char
import Board
import State

-- zwarca ruch dla gracza
getMove::State->PieceType->Int->(State, Int)
getMove state PieceType depth = result where
	result = getBestState (getMinmax (getPossibleStates state PieceType) PieceType depth)
	
getMinmax::[State]->PieceType->Int->[(State, Int)]
getMinmax [] _ _ = []
getMinmax (x:xs) PieceType depth = (x, minmax x PieceType depth PieceType) : getMinmax xs PieceType depth
	
getBestState::[(State, Int)]->(State, Int)
getBestState [x] = x
getBestState (x:y:ys) 	| (snd x) > (snd y)	= getBestState(x:ys)
						| otherwise 		= getBestState(y:ys)


minmax::State->PieceType->Int->PieceType->Int
minmax state PieceType k maximizingPlayer = if (isWolfWin state || isSheepsWin state) then getEndGameScore state PieceType else 
		if k == 0 then 0 else if maximizingPlayer == PieceType then getMax (countMinmax (getPossibleStates state PieceType) PieceType k maximizingPlayer) else 
			getMin (countMinmax (getPossibleStates state PieceType) PieceType k maximizingPlayer)

getMax::[(State, Int)]->Int
getMax [x] = snd x
getMax (x:y:ys) | (snd x) > (snd y)	= getMax (x:ys)
				| otherwise 		= getMax (y:ys)

getMin::[(State, Int)]->Int
getMin [x] = snd x
getMin (x:y:ys) | (snd x) < (snd y)	= getMin (x:ys)
				| otherwise 		= getMin (y:ys)

countMinmax::[State]->PieceType->Int->PieceType->[(State, Int)]
countMinmax [] _ _ _ = [] 
countMinmax (x:xs) PieceType k maximizingPlayer = result where
	player = if PieceType == Wolf then Sheep else Wolf
	result = (x, minmax x player (k-1) maximizingPlayer) : countMinmax xs PieceType k maximizingPlayer

-- zwraca wartosc funkcji oceny dla wygranej
getEndGameScore::State->PieceType->Int
getEndGameScore state Sheep = if isSheepsWin state then 1 else if isWolfWin state then -1 else 0 

getEndGameScore state Wolf = if isSheepsWin state then -1 else if isWolfWin state then 1 else 0

-- czy wilk wygral
isWolfWin::State->Bool
isWolfWin (x:xs) = if snd(snd x) == 0 then True else False

-- czy owce wygraly
isSheepsWin::State->Bool
isSheepsWin s = if length (getPossibleStates s Wolf) == 0 then True else False


-- zwraca wszystkie mozliwe ruchy dla Wolf lub Sheeps
getPossibleStates::State->PieceType->[State]
getPossibleStates [] _ = []

getPossibleStates (x:xs) Wolf = getPossibleStates' xs x

getPossibleStates s Sheep = getPossibleStates' ([s !! 0] ++ [s !! 2] ++ [s !! 3] ++ [s !! 4]) (s !! 1) 
	++ getPossibleStates' ([s !! 0] ++ [s !! 1] ++ [s !! 3] ++ [s !! 4]) (s !! 2) ++ getPossibleStates' ([s !! 0] ++ [s !! 1] ++ [s !! 2] ++ [s !! 4]) (s !! 3)
	++ getPossibleStates' ([s !! 0] ++ [s !! 1] ++ [s !! 2] ++ [s !! 3]) (s !! 4)

getPossibleStates'::State->(PieceType, Pos)->[State]
getPossibleStates' state (Wolf, pos) = result where
	x = fst pos
	y = snd pos
	r1 = if x+1<8 && y+1<8 && (isCollision (x+1, y+1) state) == False then [[(Wolf, (x+1, y+1))] ++ state] else []
	r2 = if x+1<8 && y-1>=0 && (isCollision (x+1, y-1) state) == False then [[(Wolf, (x+1, y-1))] ++ state] else []
	r3 = if x-1>=0 && y+1<8 && (isCollision (x-1, y+1) state) == False then [[(Wolf, (x-1, y+1))] ++ state] else []
	r4 = if x-1>=0 && y-1>=0 && (isCollision (x-1, y-1) state) == False then [[(Wolf, (x-1, y-1))] ++ state] else []
	result = r1 ++ r2 ++ r3 ++ r4

getPossibleStates' state (Sheep, pos) = result where
	x = fst pos
	y = snd pos
	r1 = if x+1<8 && y+1<8 && (isCollision (x+1, y+1) state) == False then [state ++ [(Sheep, (x+1, y+1))]] else []
	r2 = if x-1>=0 && y+1<8 && (isCollision (x-1, y+1) state) == False then [state ++ [(Sheep, (x-1, y+1))]] else []
	result = r1 ++ r2

-- sprawdza czy pionek ruszajac sie nie skoliduje sie z innym
isCollision::Pos->State->Bool
isCollision _ [] = False
isCollision newPos (x:xs) = result where
	pos = snd x
	result = if (fst pos) == (fst newPos) && (snd pos) == (snd newPos) then True else True && isCollision newPos xs
