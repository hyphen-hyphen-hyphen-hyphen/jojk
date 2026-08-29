module Main (main) where

import System.IO
import System.Exit
import System.Environment
import Data.List
import Data.Maybe

donothing = return ()

removeLineMod :: String -> String
removeLineMod line
  | "\\head{3}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{3}" line)
  | "\\head{2}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{2}" line)
  | "\\head{1}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{1}" line)
  | otherwise = line

fndBckSlshPos :: String -> Maybe Int
fndBckSlshPos line = elemIndex '\\' line

findEndOfCommand :: String -> Int -> Int
findEndOfCommand line bckpos =
  let afterBackslash = drop (bckpos + 1) line
      cmdName = takeWhile (/= '{') afterBackslash
      openBracePos = bckpos + 1 + length cmdName
      afterOpen = drop (openBracePos + 1) line
      contentLen = length (takeWhile (/= '}') afterOpen)
  in openBracePos + 1 + contentLen

procLine :: String -> String
procLine line =
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
         else if cmdName == "ital"
            then before ++ "<i>" ++ content ++ "</i>" ++ procLine rest
         else if cmdName == "boldit"
            then before ++ "<b><i>" ++ content ++ "</i></b>" ++ procLine rest
         else if "head" `isPrefixOf` cmdName
            then let level = drop 4 cmdName
                  in before ++ "<h" ++ level ++ ">" ++ content ++ "</h" ++ level ++ ">" ++ procLine rest
         else before ++ "\\" ++ cmdName ++ "{" ++ content ++ "}" ++ procLine rest

wrapLine line =
  let pMark = checkLineForMod line
      cont = removeLineMod line
      processed = procLine cont
  in "<" ++ pMark ++ ">" ++ processed ++ "</" ++ pMark ++ ">"

failing reason = do
  putStrLn ("Failed: " ++ reason)
  exitFailure

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
  file <- openFile (args !! ((length args) - 1)) ReadMode
  filecont <- hGetContents file
  let linescontlist = lines filecont
  let htmlLines = map wrapLine linescontlist
  let htmlCont = unlines htmlLines
  writeFile "out.html" htmlCont
