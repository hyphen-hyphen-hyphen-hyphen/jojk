module Main (main) where

import System.IO
import qualified MyLib (someFunc)
import System.Exit
import System.Environment

donothing = return ()

wrapPara line = "<p>" ++ line ++ "</p>"
failing reason = do
  putStrLn ("Failed: " ++ reason)
  exitFailure

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
  let htmlLines = map wrapPara linescontlist
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
  MyLib.someFunc
