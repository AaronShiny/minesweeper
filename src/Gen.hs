module Gen
where

import Data.List (genericLength, genericIndex, genericTake, genericDrop)
import qualified System.Random as R

import qualified Func as F

type Size = (Integer,Integer)

data Settings = Settings { size :: Size
                         , mineCount :: Integer
                         } deriving (Eq, Show)

beginnerSettings = Settings (9,9) 10
intermediateSettings = Settings (16,16) 40
advancedSettings = Settings (16,30) 99

-- Return the chosen element and the remainder of the list in a tuple.
chooseIndex :: [a] -> Integer -> (a,[a])
chooseIndex xs index
  | index < 0 = error "Indexes below zero are invalid."
  | pred len < index = error "Index too large for the length of the List."
  | otherwise = chooseIndex' xs index
  where
    len = genericLength xs
    chooseIndex' :: [a] -> Integer -> (a,[a])
    chooseIndex' xs index = (element,rest)
      where
        element = genericIndex xs index
        rest = concat [before, after]
          where
            before = genericTake index xs
            after = genericDrop (succ index) xs

chooseRandom :: [a] -> IO (a,[a])
chooseRandom xs = do index <- randomIndex
                     return $ chooseIndex xs index
  where
    randomIndex :: IO Integer
    randomIndex = R.randomRIO (0, pred $ genericLength xs)

shuffle :: [a] -> IO [a]
shuffle [] = return []
shuffle [x] = return [x]
shuffle xs = do (chosen,rest) <- chooseRandom xs
                shuffledRest <- shuffle rest
                return (chosen:shuffledRest)

generateMineGrid :: Settings -> F.MineGrid
generateMineGrid = undefined

main :: IO ()
main = do putStrLn "Generator of Minesweeper Grids."
