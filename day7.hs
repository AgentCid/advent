--Day 7: Some Assembly Required
import Data.Bits
import qualified Data.Map.Lazy as Map
import Data.Char
import Data.Maybe
import Data.Word
import Data.List
import Data.Function

data Wire = Straight Word16 | Unary (Word16 -> Word16) Word16 | Gate Word16 (Word16 -> Word16 -> Word16) Word16
instance Show Wire where 
    show (Straight a) = "Straight " ++ show a
    show (Unary f a) = "Unary " ++ show (f a)
    show (Gate a f b) = "Gate " ++ show (f a b)

evaluate :: Wire -> Word16
evaluate (Straight a) = a
evaluate (Unary f a) = f a
evaluate (Gate a f b) = f a b

wordIsNumber :: String -> Bool
wordIsNumber = all (==True) . map isDigit

fLookup :: String -> (Word16 -> Word16 -> Word16)
fLookup "AND" = (.&.)
fLookup "OR" = (.|.)
fLookup "LSHIFT" = (\a b -> shiftL a (fromIntegral b))
fLookup "RSHIFT" = (\a b -> shiftR a (fromIntegral b))

tokenize :: [String] -> Map.Map String Word16 -> (String, Wire)
tokenize [i, _, o] m
    | wordIsNumber i = (o, Straight $ read i)
    | otherwise = (o, Straight . fromJust $ Map.lookup i m)

-- the only unary function is not, so we don't need to parse it
tokenize [f, i, _, o] m
    | wordIsNumber i = (o, Unary complement (read i))
    | otherwise = (o, Unary complement (fromJust $ Map.lookup i m))

tokenize [i1, f, i2, _, o] m
    | wordIsNumber i1 && wordIsNumber i2 = (o, Gate (read i1) (fLookup f) (read i2))
    | wordIsNumber i1 = (o, Gate (read i1) (fLookup f) (fromJust $ Map.lookup i2 m))
    | wordIsNumber i2 = (o, Gate (fromJust $ Map.lookup i1 m) (fLookup f) (read i2))
    | otherwise = (o, Gate (fromJust $ Map.lookup i1 m) (fLookup f) (fromJust $ Map.lookup i2 m))

--these two only worked because the simple case was already ordered the right way
parse :: Map.Map String Word16 -> String -> Map.Map String Word16
parse m s = Map.insert k (evaluate v) m
    where token = tokenize (words s) m
          k = fst token
          v = snd token

day7Simple = do
    contents <- readFile "day7_simple.txt"
    let results = foldl parse Map.empty $ lines contents 
    putStrLn (show results)

--from here on is the real solution, sorting the list for only those values we have defined
parse' :: Map.Map String Word16 -> [String] -> Map.Map String Word16
parse' m s = Map.insert k (evaluate v) m
    where token = tokenize s m
          k = fst token
          v = snd token

complete :: [String] -> Map.Map String Word16 -> Bool
complete [i, _, _] m 
    | wordIsNumber i = True
    | otherwise = Map.member i m
complete [_, i, _, _] m
    | wordIsNumber i = True
    | otherwise = Map.member i m
complete [i1, _, i2, _, _] m
    | wordIsNumber i1 && wordIsNumber i2 = True
    | wordIsNumber i1 = Map.member i2 m
    | wordIsNumber i2 = Map.member i1 m
    | otherwise = Map.member i1 m && Map.member i2 m

organize :: Map.Map String Word16 -> [[String]] -> Map.Map String Word16
organize m [s] = parse' m s
organize m xs = organize (parse' m (head ss)) $ tail ss
    where ss = reverse $ sortBy (compare `on` (flip complete) m) xs

day7 = do
    contents <- readFile "day7.txt"
    let split = map words $ lines contents
        results = organize Map.empty split
        answer = Map.lookup "a" results
    putStrLn (show answer)

day7' = do
    contents <- readFile "day7_2.txt"
    let split = map words $ lines contents
        results = organize Map.empty split
        answer = Map.lookup "a" results
    putStrLn (show answer)