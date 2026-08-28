module Main (main) where

import System.IO
import qualified MyLib (someFunc)
import System.Exit
import System.Environment
import Data.List
import Data.Maybe

donothing = return ()
removeLineMod line
  | "\\head{3}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{3}" line)
  | "\\head{2}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{2}" line)
  | "\\head{1}" `isPrefixOf` line = fromMaybe line (stripPrefix "\\head{1}" line)
  | otherwise = line
wrapLine line = 
  let pMark = checkLineForMod line
      cont = removeLineMod line
  in "<" ++ pMark ++ ">" ++ cont ++ "</" ++ pMark ++ ">"
wrapPara line = "<p>" ++ line ++ "</p>"
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
  if (length args) == 0
    then failing "no filename"
  else donothing
  file <- openFile (args !! ((length args) - 1)) ReadMode
  filecont <- hGetContents file
  let htmlcontlist = []
  let linescontlist = lines filecont
  let htmlLines = map wrapLine linescontlist
  let htmlCont = unlines htmlLines
  -- let loop1 i
  --   | i <= (length (lines filecont)) = do
  --     -- let loop2 j
  --       -- | j <= (length (words ((lines filecont) !! i))) = do
  --       -- | otherwise = donothing
  --     if (not (any (== '\\') ((lines filecont) !! i)))
  --       -- append and prepend "<p>" and "</p>" respectively somehow
  --     else donothing
  --     loop1 (i + 1)
  --   | otherwise = donothing
  writeFile "out.html" htmlCont
