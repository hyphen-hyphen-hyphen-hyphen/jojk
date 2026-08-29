module Main (main) where

import System.IO
import System.Exit
import System.Environment
import Data.List
import Data.Maybe

donothing :: IO ()
donothing = return ()

removeLineMod :: String -> String
removeLineMod line
  | "\\head{3}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{3}" line)
  | "\\head{2}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{2}" line)
  | "\\head{1}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{1}" line)
  | otherwise = line

fndBckSlshPos :: String -> Maybe Int
fndBckSlshPos line = elemIndex '\\' line

checkIfthinginlist :: Eq t => t -> [t] -> Bool
checkIfthinginlist thing list
  | list == [] = False
  | otherwise =
    if head list == thing
      then True
    else let newlist = drop 1 list
    in checkIfthinginlist thing newlist

checkwherethingisinlist :: (Eq t1, Num t2) =>
                           t1 -> [t1] -> t2 -> t2
checkwherethingisinlist thing list itnumber =
  if head list == thing
    then itnumber
  else let newlist = drop 1 list
           newitnum = itnumber + 1
       in checkwherethingisinlist thing newlist newitnum

findEndOfCommand :: String -> Int -> Int
findEndOfCommand line bckpos =
  let afterBackslash = drop (bckpos + 1) line
      cmdName = takeWhile (/= '{') afterBackslash
      openBracePos = bckpos + 1 + length cmdName
      afterOpen = drop (openBracePos + 1) line
      contentLen = length (takeWhile (/= '}') afterOpen)
  in openBracePos + 1 + contentLen

specLink :: [Char] -> [Char] -> [Char]
specLink content rest =
  let secContent = takeWhile (/= '}') (drop 1 rest)
  in "<a href=\"" ++ secContent ++ "\">" ++ content ++ "</a>"


procLine :: String -> String
procLine line
  | line == "" = ""
  | otherwise =
    case fndBckSlshPos line of
      Nothing -> line
      
      Just pos ->
        let afterBackslash = drop (pos + 1) line
            cmdName = takeWhile (/= '{') afterBackslash
            openBracePos = pos + 1 + length cmdName
            afterOpen = drop (openBracePos + 1) line
            content = takeWhile (/= '}') afterOpen
            endPos = findEndOfCommand line pos
            rest = drop (endPos + 1) line
            before = take pos line
        in if cmdName == "bold"
              then before ++ "<b>" ++ content ++ "</b>" ++ procLine rest
           else if cmdName == "italic"
              then before ++ "<i>" ++ content ++ "</i>" ++ procLine rest
           else if cmdName == "link"
              then before ++ (specLink content rest) ++ procLine (drop 1 (dropWhile (/= '}') rest))
           else if cmdName == "boldit"
              then before ++ "<b><i>" ++ content ++ "</i></b>" ++ procLine rest
           else if "head" `isPrefixOf` cmdName
              then let level = drop 4 cmdName
                    in before ++ "<h" ++ level ++ ">" ++ content ++ "</h" ++ level ++ ">" ++ procLine rest
           else before ++ "\\" ++ cmdName ++ "{" ++ content ++ "}" ++ procLine rest

wrapLine :: String -> String
wrapLine line
  | line == "" = ""
  | otherwise =
    let pMark = checkLineForMod line
        cont = removeLineMod line
        processed = procLine cont
    in "<" ++ pMark ++ ">" ++ processed ++ "</" ++ pMark ++ ">"

failing :: [Char] -> IO b
failing reason = do
  putStrLn ("Failed: " ++ reason)
  exitFailure

checkLineForMod :: [Char] -> String
checkLineForMod line
  | "\\head{3}" `isPrefixOf` line = "h3"
  | "\\head{2}" `isPrefixOf` line = "h2"
  | "\\head{1}" `isPrefixOf` line = "h1"
  | otherwise = "p"

main :: IO ()
main = do
  args <- getArgs
  if length args == 0
    then failing "no filename"
    else donothing
  let outname = if checkIfthinginlist "-o" args then args !! ((checkwherethingisinlist "-o" args 0) + 1) else "out.html"
  file <- openFile (args !! ((length args) - 1)) ReadMode
  filecont <- hGetContents file
  let linescontlist = lines filecont
  let htmlLines = map wrapLine linescontlist
  let htmlCont = unlines htmlLines
  writeFile outname htmlCont
