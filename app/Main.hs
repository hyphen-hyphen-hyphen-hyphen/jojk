module Main (main) where

import System.IO
import System.Exit
import System.Environment
import Data.List
import Data.Maybe

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

cil :: String -> [String] -> Bool
cil _ [] = nil
cil thing (x:xs) = if thing == x then t else cil thing xs

checkWhereInList :: String -> [String] -> Int -> Int
checkWhereInList _ [] _ = -1

checkWhereInList hing (a:xs) int
  | a == hing = int
  | otherwise =
    let nwInt = int + 1
    in checkWhereInList hing xs nwInt

fec :: String -> Int -> Int
fec = \l b ->
  let afterBackslash =  drop  (b + 1) l
      cmdName =  takeWhile (/= '{') afterBackslash
      openBracePos = b + 1 + length cmdName
      afterOpen =  drop  (openBracePos + 1) l
      contentLen = length ( takeWhile (/= '}') afterOpen)
  in openBracePos + 1 + contentLen


specCaseTwoArgs :: any -> String -> (any, String)
specCaseTwoArgs = \c r -> 
  let secContent =  takeWhile (/= '}') ( drop  1 r)
  in (c, secContent)


specCaseTwoArgsMark :: any -> String -> (any, String)
specCaseTwoArgsMark = \c r -> 
  let secContent =  takeWhile (/= '}') ( drop  1 r)
  in (c, secContent)


liiist :: String -> String -> String -> Int -> String
liiist content rest preFin itnum
  | itnum == read content = preFin ++ "</ul>"
  | otherwise =
    let nxtcontent = if preFin == "" then "<ul><li>" ++   takeWhile (/= '}') ( drop  1 rest) ++ "</li>" else preFin ++ "<li>" ++  takeWhile (/= '}') ( drop  1 rest) ++ "</li>"
    in liiist content ( drop  1 ( dropWhile (/= '}') rest)) nxtcontent (itnum + 1)
        
liiistMark :: String -> String -> String -> Int -> String
liiistMark content rest preFin itnum
  | itnum == read content = preFin ++ "\n"
  | otherwise =
    let nxtcontent = if preFin == "" then "\n- " ++   takeWhile (/= '}') ( drop  1 rest) ++ "\n" else preFin ++ "- " ++  takeWhile (/= '}') ( drop  1 rest) ++ "\n"
    in liiistMark content ( drop  1 ( dropWhile (/= '}') rest)) nxtcontent (itnum + 1)

ordlistMark :: String -> String -> String -> Int -> String
ordlistMark content rest preFin itnum
  | itnum == read content = preFin ++ "\n"
  | otherwise =
    let nxtcontent = if preFin == "" then "\n" ++ show (itnum + 1) ++ ". " ++  takeWhile (/= '}') ( drop  1 rest) ++ "\n" else preFin ++ show (itnum + 1) ++ ". " ++  takeWhile (/= '}') ( drop  1 rest) ++ "\n"
    in ordlistMark content ( drop  1 ( dropWhile (/= '}') rest)) nxtcontent (itnum + 1)

ordlist :: String -> String -> String -> Int -> String
ordlist content rest preFin itnum
  | itnum == read content = preFin ++ "</ol>"
  | otherwise =
    let nxtcontent = if preFin == "" then "<ol><li>" ++   takeWhile (/= '}') ( drop  1 rest) ++ "</li>" else preFin ++ "<li>" ++  takeWhile (/= '}') ( drop  1 rest) ++ "</li>"
    in ordlist content ( drop  1 ( dropWhile (/= '}') rest)) nxtcontent (itnum + 1)

unfuckitup :: String -> String -> Int -> String
unfuckitup content rest itnum
  | read content == itnum = rest
  | otherwise =
    let nxtcont =  drop  1 ( dropWhile (/= '}') rest)
    in unfuckitup content nxtcont (itnum + 1)

p :: String -> String
p line
  | line == "" = ""
  | otherwise =
    case fb line of
      Nothing -> line
      
      Just pos ->
        let afterBackslash =  drop  (pos + 1) line
            cmdName =  takeWhile (/= '{') afterBackslash
            openBracePos = pos + 1 + length cmdName
            afterOpen =  drop  (openBracePos + 1) line
            content =  takeWhile (/= '}') afterOpen
            endPos = fec line pos
            rest =  drop  (endPos + 1) line
            before =  take  pos line
         in caseText before content rest cmdName

caseText :: String -> String -> String -> String -> String
caseText before content rest "bold" = before ++ "<b>" ++ p content ++ "</b>" ++ (takeWhile (/= '}') (p rest))++ dropWhile (== '}') (takeWhile (/= '}') (p rest))
caseText before content rest "italic" =before ++ "<i>" ++ p content ++ "</i>" ++ (takeWhile (/= '}') (p rest))++ dropWhile (== '}') (takeWhile (/= '}') (p rest))
caseText before _ rest "break" =before ++ "<br>" ++ (takeWhile (/= '}') (p rest))++ dropWhile (== '}') (takeWhile (/= '}') (p rest))
caseText before content rest "ulist" = before ++ p (liiist content rest "" 0) ++ (takeWhile (/= '}') (p (unfuckitup content rest 0)))++ dropWhile (== '}') (takeWhile (/= '}') (p (unfuckitup content rest 0)))
caseText before content rest "olist" = before ++ p (ordlist content rest "" 0) ++ (takeWhile (/= '}') (p (unfuckitup content rest 0)))++ dropWhile (== '}') (takeWhile (/= '}') (p (unfuckitup content rest 0)))
caseText before content rest "link" =before ++ "<a href=\"" ++ (cdr (specCaseTwoArgs content rest)) ++ "\">" ++ (car (specCaseTwoArgs content rest)) ++ "</a>" ++ p (drop  1 ( dropWhile (/= '}') rest))
caseText before content rest "block" = before ++ "<blockquote>" ++ p content ++ "</blockquote>" ++ (takeWhile (/= '}') (p rest))++ dropWhile (== '}') (takeWhile (/= '}') (p rest))
caseText before content rest cmdName = before ++ "\\" ++ cmdName ++ "{" ++ p content ++ "}" ++ (takeWhile (/= '}') (p rest))++ dropWhile (== '}') (takeWhile (/= '}') (p rest))

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

clmbutMark :: String -> String
clmbutMark line
  | "\\head{3}" `isPrefixOf` line = "h3"
  | "\\head{2}" `isPrefixOf` line = "h2"
  | "\\head{1}" `isPrefixOf` line = "h1"
  | otherwise = "h0"


caseTextMark :: String -> String -> String -> String -> String
caseTextMark before content rest "bold" = before ++ "**" ++ pMark content ++ "**" ++ takeWhile (/= '}') (pMark rest) ++ dropWhile (== '}') (takeWhile (/= '}') (pMark rest))
caseTextMark before content rest "boldit" = before ++ "***" ++ pMark content ++ "***" ++ takeWhile (/= '}') (pMark rest) ++ dropWhile (== '}') (takeWhile (/= '}') (pMark rest))
caseTextMark before content rest "italic" = before ++ "*" ++ pMark content ++ "*" ++ takeWhile (/= '}') (pMark rest) ++ dropWhile (== '}') (takeWhile (/= '}') (pMark rest))
caseTextMark before _ rest "break" = before ++ "\\" ++ takeWhile (/= '}') (pMark rest) ++ dropWhile (== '}') (takeWhile (/= '}') (pMark rest))
caseTextMark before content rest "ulist" = before ++ pMark (liiistMark content rest "" 0) ++ (takeWhile (/= '}') (p (unfuckitup content rest 0)))++ dropWhile (== '}') (takeWhile (/= '}') (p (unfuckitup content rest 0)))
caseTextMark before content rest "olist"= before ++ pMark (ordlistMark content rest "" 0) ++ (takeWhile (/= '}') (p (unfuckitup content rest 0)))++ dropWhile (== '}') (takeWhile (/= '}') (p (unfuckitup content rest 0)))
caseTextMark before content rest "link" = before ++ "[" ++ pMark (car (specCaseTwoArgsMark content rest)) ++ "](" ++ (cdr (specCaseTwoArgsMark content rest)) ++ ")" ++ pMark ( drop  1 ( dropWhile (/= '}') rest))
caseTextMark before content rest "block" = "> " ++ before ++ pMark content ++ takeWhile (/= '}') (pMark rest) ++ dropWhile (== '}') (takeWhile (/= '}') (pMark rest))
caseTextMark before content rest cmdName = before ++ "\\" ++ cmdName ++ "{" ++ pMark content ++ "}" ++ pMark rest

pMark :: [Char] -> [Char]
pMark line
  | line == "" = ""
  | otherwise =
    case fb line of
      Nothing -> line
      
      Just pos ->
        let afterBackslash =  drop  (pos + 1) line
            cmdName =  takeWhile (/= '{') afterBackslash
            openBracePos = pos + 1 + length cmdName
            afterOpen =  drop  (openBracePos + 1) line
            content =  takeWhile (/= '}') afterOpen
            endPos = fec line pos
            rest =  drop  (endPos + 1) line
            before =  take  pos line
         in caseTextMark before content rest cmdName
    
wMark :: String -> [Char]
wMark = \l ->
  let pm = clmbutMark l
      c = rlm l
      pro = pMark c 
      heed= ( take  (read ( drop  1 pm)) ( repeat  "#")) ++ [" "]
  in concat (heed ++ [pro])

clm :: [Char] -> String
clm line
  | "\\head{3}" `isPrefixOf` line = "h3"
  | "\\head{2}" `isPrefixOf` line = "h2"
  | "\\head{1}" `isPrefixOf` line = "h1"
  | otherwise = "p"

re :: String -> String
re "<p></p>" = "<br>"
re l = l

-- remendpar lst
--   | lst == [] = []
--   | otherwise =
--     if cil '}' lst then take (fromMaybe (fb lst)) ++ drop fromMaybe (((fb lst) + 1)) lst else lst

reMark :: [Char] -> [Char]
reMark (' ':aa) = aa
reMark l = l

pr :: IO ()
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
    else return ()
  let outFormat = if cil "-m" a then "markdown" else "html"
  let end = if outFormat == "markdown" then "md" else "html"
  let on = if cil "-o" a then a !! ((checkWhereInList "-o" a 0) + 1) else "out." ++ end
  f <- openFile (a !! (( length a) - 1)) ReadMode
  fc <- hGetContents f
  let lcl = lines fc
  let hl = if outFormat == "html" then map w lcl else map wMark lcl
  let hl2 = if outFormat == "html" then map re hl else map reMark hl
  let hc = unlines hl2
  writeFile on hc
  if cil "-q" a then return () else pr
