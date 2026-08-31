module Main (main) where

import System.IO
import System.Exit
import System.Environment
import Data.List
import Data.Maybe
import Data.Typeable

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
fec = \l b ->
  let afterBackslash = drop (b + 1) l
      cmdName = takeWhile (/= '{') afterBackslash
      openBracePos = b + 1 + length cmdName
      afterOpen = drop (openBracePos + 1) l
      contentLen = length (takeWhile (/= '}') afterOpen)
  in openBracePos + 1 + contentLen


specCaseTwoArgs = \c r -> 
  let secContent = takeWhile (/= '}') (drop 1 r)
  in (c, secContent)


liiist content rest preFin itnum
  | itnum == read content = preFin ++ "</ul>"
  | otherwise =
    let nxtcontent = if preFin == "" then "<ul><li>" ++  takeWhile (/= '}') (drop 1 rest) ++ "</li>" else preFin ++ "<li>" ++ takeWhile (/= '}') (drop 1 rest) ++ "</li>"
    in liiist content (drop 1 (dropWhile (/= '}') rest)) nxtcontent (itnum + 1)
        
ordlist content rest preFin itnum
  | itnum == read content = preFin ++ "</ol>"
  | otherwise =
    let nxtcontent = if preFin == "" then "<ol><li>" ++  takeWhile (/= '}') (drop 1 rest) ++ "</li>" else preFin ++ "<li>" ++ takeWhile (/= '}') (drop 1 rest) ++ "</li>"
    in ordlist content (drop 1 (dropWhile (/= '}') rest)) nxtcontent (itnum + 1)

unfuckitup content rest itnum
  | read content == itnum = rest
  | otherwise =
    let nxtcont = drop 1 (dropWhile (/= '}') rest)
    in unfuckitup content nxtcont (itnum + 1)

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
         in putdaformatingon before content rest cmdName

putdaformatingon before content rest cmdName = 
  if cmdName == "bold"
     then before ++ "<b>" ++ content ++ "</b>" ++ p rest
  else if cmdName == "italic"
     then before ++ "<i>" ++ content ++ "</i>" ++ p rest
  else if cmdName == "break"
     then before ++ "<br>" ++ p rest
  else if cmdName == "ulist"
     then before ++ (liiist content rest "" 0) ++ p (unfuckitup content rest 0)
  else if cmdName == "olist"
     then before ++ (ordlist content rest "" 0) ++ p (unfuckitup content rest 0)
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
        pro = p . c
    in \l -> "<" ++ pm l ++ ">" ++ pro l ++ "</" ++ pm l ++ ">"

fl :: [Char] -> IO b
fl r = do
  putStrLn ("jojk misstag(oops): " ++ r)
  exitFailure

clm :: [Char] -> String
clm line
  | "\\head{3}" `isPrefixOf` line = "h3"
  | "\\head{2}" `isPrefixOf` line = "h2"
  | "\\head{1}" `isPrefixOf` line = "h1"
  | otherwise = "p"

re = \l ->
  if l == "<p></p>" then "<br>" else l

pr = do
  putStrLn "     /)/)/) /).-') "
  putStrLn "    ////((.'_.--'   .(\\(\\(\\                   n/(/.')_         . "
  putStrLn "   ((((_/ .'      .-`)))))))                  `-._ ('.'        \\`(\\ "
  putStrLn "  (_._ ` (         `.   (/ |                      \\ (           `-.\\ "
  putStrLn "      `-. \\          `-.  /                        `.`.           \\ \\ "
  putStrLn "         `.`.          | /                /)         \\ \\           | L "
  putStrLn "           `.`._.      ||_               (()          `.\\          ) F "
  putStrLn "   (`._      `. <    .'.-'                \\`-._____    ||        .' / "
  putStrLn "    `(\\`._.._(\\(\\)_.'.'-------------.___   `-.(`._ `-./ /     _.' .' "
  putStrLn "      (.-.| \\_`.__.-<     `.    . .-'   `-.   _> `-._((`.__.-'_.-' "
  putStrLn "          (.--'   ' |    \\ \\     /| \\.-./ |\\ `-.   _.'>.___,-'`. "
  putStrLn "             (  o  <      |     |  `o   o'  |  /(`'.-'   --.    \\ "
  putStrLn "           .'     /      .'   _ |   |   |   |  ( .'/  o .-'   \\  | "
  putStrLn "           (__.-.`-._  -'    '   \\  \\   /  /    ' /    _/      | J "
  putStrLn "                 \\_  `.      _.__.L |   | J      (  .'\\`.    _/-./ "
  putStrLn "                   `-<  .-L|'`-|  ||\\\\V/ ||       `'   L \\  /   / "
  putStrLn "                      |J  ||    \\ ||||  |||            |  |_|  ) "
  putStrLn "                      ||  ||     )||||  |||            || / ||J "
  putStrLn "                      (|  (|    / |||)  (||            |||  ||| "
  putStrLn "                      ||  ||   / /||||  |||            |(|  ||| "
  putStrLn "                      ||  ||  / / ||||  |||            |||  ||| "
  putStrLn "_______.------.______/ |_/ |_/_|_/// |__| \\\\__________// |--( \\\\--------- "
  putStrLn "                    '-' '-'       '-'    `-`           '-'   `-` "

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
  pr
