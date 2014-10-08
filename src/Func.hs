module Func
where

import Data.List (genericLength, genericIndex)
import Data.Maybe (isNothing, isJust)
import qualified Data.Default as Def -- cabal install data-default

type Grid = [GridRow]
type GridRow = [GridCell]
data GridCell = GridCell { mine :: MineCell
                         , marking :: Marking
                         } deriving (Eq, Show)
-- http://byorgey.wordpress.com/2010/04/03/haskell-anti-pattern-incremental-ad-hoc-parameter-abstraction/
instance Def.Default GridCell where
  def = GridCell False Normal

newGridCell :: MineCell -> GridCell
newGridCell m = Def.def {mine = m}

minesToGrid :: MineGrid -> Grid
minesToGrid = (map . map) newGridCell

-- Lossy transformation.
gridToMines :: Grid -> MineGrid
gridToMines = (map . map) mine

type MineGrid = [MineGridRow]
type MineGridRow = [MineCell]
type MineCell = Bool

data Marking = Flag | QuestionMark | Normal | Revealed deriving (Eq, Show)

data Progress = InProgress | Won | Lost deriving (Eq, Show)

progress :: Grid -> Progress
progress g
  | won g = Won
  | lost g = Lost
  | otherwise = InProgress
  where
    won :: Grid -> Bool 
    won grid = and $ map cellValid (concat grid)
      where
        cellValid :: GridCell -> Bool
        cellValid gc = (mine gc) /= (Revealed == marking gc)
    lost :: Grid -> Bool
    lost grid = or $ map cellInvalid (concat grid)
      where
        cellInvalid :: GridCell -> Bool
        cellInvalid gc = (mine gc) == (Revealed == marking gc)

finished :: Grid -> Bool
finished g = InProgress /= progress g

type Location = (Integer,Integer)

numberOfMinesAround :: Grid -> Location -> Integer
numberOfMinesAround grid (x,y) = cellsThatAreMines
  where
    locationsAround :: [Location]
    locationsAround =
      [ (x-1,y-1)
      , (x+0,y-1)
      , (x+1,y-1)

      , (x-1,y+0)
      -- Skip the given Location.
      , (x+1,y+0)

      , (x-1,y+1)
      , (x+0,y+1)
      , (x+1,y+1)
      ]
    possibleCells :: [Maybe GridCell]
    possibleCells = map (findCell grid) locationsAround
    cellsThatAreMines :: Integer
    cellsThatAreMines = genericLength $ filter maybeCellIsMine possibleCells

findCell :: Grid -> Location -> Maybe GridCell
findCell grid (x,y) = findRow grid >>= findCell
  where
    findRow :: Grid -> Maybe GridRow
    findRow grid
      | (y <= 0) && (y < genericLength grid) = Just (genericIndex grid y)
      | otherwise = Nothing
    findCell :: GridRow -> Maybe GridCell
    findCell gridRow
      | (x <= 0) && (x < genericLength gridRow) = Just (genericIndex gridRow x)
      | otherwise = Nothing

locationIsMine :: Grid -> Location -> Bool
locationIsMine grid location = maybeCellIsMine cell
  where
    cell = findCell grid location

maybeCellIsMine :: Maybe GridCell -> Bool
maybeCellIsMine (Just cell) = mine cell
maybeCellIsMine Nothing = False

main :: IO ()
main = do putStrLn "The core functionality of the program is in this module."