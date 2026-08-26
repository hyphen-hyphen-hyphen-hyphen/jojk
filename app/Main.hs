module Main (main) where

import System.IO
import qualified MyLib (someFunc)
import System.Exit
import System.Environment

donothing = return ()

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
  putStrLn filecont
  MyLib.someFunc
