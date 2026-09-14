curl -Lf https://raw.github.com/hyphen-hyphen-hyphen-hyphen/jojk/blob/trunk/app/Main.hs > Main.hs
ghc Main.hs
sudo cp Main /usr/bin/jojk
rm Main Main.o Main.hi Main.hs
