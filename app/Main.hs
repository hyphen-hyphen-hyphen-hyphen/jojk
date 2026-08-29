module Main (main) where

import System.IO
import System.Exit
import System.Environment
import Data.List
import Data.Maybe

donothing :: IO ()
donothing = return ()

-- make it more *lispy*
car :: (b,a) -> b
cdr :: (a, b) -> b
t :: Bool
nil :: Bool
car (a,_) = a
cdr (_,a) = a
t = True
nil = False

rlm :: String -> String
rlm line
  | "\\head{3}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{3}" line)
  | "\\head{2}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{2}" line)
  | "\\head{1}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{1}" line)
  | otherwise = line

fb :: String -> Maybe Int
fb = (elemIndex '\\')

cil :: Eq t => t -> [t] -> Bool
cil thing list
  | list == [] = nil
  | otherwise =
    if head list == thing
      then t
    else let newlist = drop 1 list
    in cil thing newlist

cwl :: (Eq t1, Num t2) =>
                           t1 -> [t1] -> t2 -> t2
cwl = \s l i ->
  if head l == s
    then i
  else let nl = drop 1 l
           ni = i + 1
       in cwl s nl ni

fec :: String -> Int -> Int
fec line bckpos =
  let afterBackslash = drop (bckpos + 1) line
      cmdName = takeWhile (/= '{') afterBackslash
      openBracePos = bckpos + 1 + length cmdName
      afterOpen = drop (openBracePos + 1) line
      contentLen = length (takeWhile (/= '}') afterOpen)
  in openBracePos + 1 + contentLen


specCaseTwoArgs content rest =
  let secContent = takeWhile (/= '}') (drop 1 rest)
  in (content, secContent)


p :: String -> String
p line
  | line == "" = ""
  | otherwise =
    case fb line of
      Nothing -> line
      
      Just pos ->
        let afterBackslash = drop (pos + 1) line
            cmdName = takeWhile (/= '{') afterBackslash
            openBracePos = pos + 1 + length cmdName
            afterOpen = drop (openBracePos + 1) line
            content = takeWhile (/= '}') afterOpen
            endPos = fec line pos
            rest = drop (endPos + 1) line
            before = take pos line
        in if cmdName == "bold"
              then before ++ "<b>" ++ content ++ "</b>" ++ p rest
           else if cmdName == "italic"
              then before ++ "<i>" ++ content ++ "</i>" ++ p rest
           else if cmdName == "break"
              then before ++ "<br>" ++ p rest
           else if cmdName == "link"
              then let ccc = specCaseTwoArgs content rest
              in before ++ "<a href=\"" ++ (cdr ccc) ++ "\">" ++ (car ccc) ++ "</a>" ++ p (drop 1 (dropWhile (/= '}') rest))
           else if cmdName == "boldit"
              then before ++ "<b><i>" ++ content ++ "</i></b>" ++ p rest
           else if "head" `isPrefixOf` cmdName
              then let level = drop 4 cmdName
                    in before ++ "<h" ++ level ++ ">" ++ content ++ "</h" ++ level ++ ">" ++ p rest
           else before ++ "\\" ++ cmdName ++ "{" ++ content ++ "}" ++ p rest

w :: String -> String
w =
    let pm = clm
        c = rlm
        pr = p . c
    in \l -> "<" ++ pm l ++ ">" ++ pr l ++ "</" ++ pm l ++ ">"

fl :: [Char] -> IO b
fl r = do
  putStrLn ("Failed: " ++ r)
  exitFailure

clm :: [Char] -> String
clm line
  | "\\head{3}" `isPrefixOf` line = "h3"
  | "\\head{2}" `isPrefixOf` line = "h2"
  | "\\head{1}" `isPrefixOf` line = "h1"
  | otherwise = "p"

re = \l ->
  if l == "<p></p>" then "<br>" else l


main :: IO ()
main = do
  a <- getArgs
  if length a == 0
    then fl "no filename"
    else donothing
  let on = if cil "-o" a then a !! ((cwl "-o" a 0) + 1) else "out.html"
  f <- openFile (a !! ((length a) - 1)) ReadMode
  fc <- hGetContents f
  let lcl = lines fc
  let hl = map w lcl
  let hl2 = map re hl
  let hc = unlines hl2
  writeFile on hc
