# Jojk

Jojk is a command based markup language with a parser written in haskell

## Installation

### Binary

Download the binary from the latest release and either execute direclty or place in `$PATH`

### From source

#### With GHC

Make sure you have [ghc](https://www.haskell.org/ghc/) installed and either clone the repository or download directly the `app/Main.hs` file. \
Navigate to the directory with the `Main.hs` file and run 
```
ghc Main.hs
```
This will create the files
```
Main
Main.hi
Main.o
```
You can disregard `Main.hi` and `Main.o` \
The `Main` file is the ELF and the only file needed \
Now to run it you can either run it directly with 
```
./Main
```
Or move it to `$PATH`
```
sudo cp Main /usr/bin/jojk
jojk
```

#### With cabal

Make sure you have [cabal](https://www.haskell.org/cabal/) installed and clone the repository with
```
git clone https://github.com/hyphen-hyphen-hyphen-hyphen/jojk.git
cd jojk
```

## Usage

Run `jojk` with any potential flags and the filename of the jojk file as the last argument \
For example:
```
jojk -m file.jojk
```

### Flags

| Flags | |
| ---- | ----- |
| `-o` | specifies an output file |
| `-m` | outputs in markdown instead of HTML |
| `-q` | supersses the printing of ascii art |


## Writing jojk files

### Commands

Jojk commands consist of a backslash (\) the command (for example "bold") and brackets({}) containing the command content. For example `\bold{text}`

#### Legend

```
     content
       ↓
\xxxx{xxxx}
  ↑  |____|
command |
      term
```

#### Table

| Jojk | HTML | MarkDown |
| ---- | ---- | -------- |
| \bold{text} | <b>text</b> | \*\*text\*\* |
| \italic{text} | <i>text</i> | \*text\* |
| \boldit{text} | <i><b>text</b></i> | \*\*\*text\*\*\* |
| \break{} | <br> | \ |
| \ulist | see ulist header | see ulist header |
| \olist | see olist header | see olist header |
| \link{text}{link} | <a href="link">text</a> | [text](link) |
| \block{text} | <blockquote>text</blockquote>  | > text |
| \head{number 1-3}text | <h1-3>text</h1-3> | #, ##, ### text |

#### bold

The command for bold text looks like this:
```
\bold{text}
```

and it outputs: \
HTML
```HTML
<b>text</b>
```
MarkDown
```md
**text**
```

#### italic

The command for italic text looks like this:
```
\italic{text}
```

and it outputs: \
HTML
```HTML
<i>text</i>
```
MarkDown
```md
*text*
```

#### boldit

If you want both bold and italic text use boldit:
```
\boldit{text}
```

and it outputs: \
HTML
```HTML
<b><i>text</i></b>
```
MarkDown
```md
***text***
```

#### break

```
\break{}
```
Inserts a line break \
HTML:
```HTML
<br>
```
Markdown
```md
\
```

#### Ulist

```
\ulist{x}{a}{b}{c}{d}...
```

This creates an unordered list with *x* number of terms *a, b, c, d...* \
For example:
```
\ulist{3}{this is}{a}{list}
```
outputs: \
HTML
```
<ul>
  <li>this is</li>
  <li>a</li>
  <li>list</li>
</ul>
```
Markdown
```md
- this is
- a
- list
```

#### Olist

```
\olist{x}{a}{b}{c}{d}...
```

This creates an ordered list with *x* number of terms *a, b, c, d...* \
For example:
```
\olist{3}{this is}{a}{list}
```
outputs: \
HTML
```
<ol>
  <li>this is</li>
  <li>a</li>
  <li>list</li>
</ol>
```
Markdown
```md
1. this is
2. a
3. list
```

#### Block

The `block` command makes the content a blockquote by wrapping it in `<blockquote>` tags when outputing to HTML. \
When outputing to Markdown, the entire line becomes a blockquote, where the command is and what the content is does not matter. \
For example: \
>>>>>>> 7129044 (readme update)
Command
```
Text\block{more text} more more text
```
outputs: \
HTML
```html
Text<blockquote>more text</blockquote> more more text
```
Markdown
```md
> Textmore text more more text
```

#### link

```
\link{text}{link}
```
Creates a link with text *text* linking to *link* \
Example output: \
HTML
```html
<a href="link">text</a>
```
markdown
```
[text](link)
```

#### head

The head command should always be placed at the beginning of the line, and it makes the entire line a header, the command contents being the header level, for example:
```
\head{2}text
```
outputs \
HTML
```
<h2>text</h2>
```
Markdown
```
## text
```
