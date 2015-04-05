# tmux-keylogger

A small self-contained bash script that makes `tmux` display all your ASCII
keystrokes, including control characters, right in your status bar.

![tmux-keylogger demo](https://raw.githubusercontent.com/concise/tmux-keylogger/master/demo.gif)

This codebase is a proof of concept about the idea of a portable keystroke
displayer...  My implementaion in bash has bad performance now.  (slow tmux
status message recalculate; I wrote some stupid code)

Feel free to fork it, or reimplement it with another language!


## Why

When doing screencast, I relied on tool like "KeyCastr" on OS X to display what
I've done with my keyboard.  But that project seems dead a few years ago, and I
do not know if there is any open source alternative.  So I decided to try if I
can make it under tmux, because most of the time I do my job under a text
console, and even though the programmability of tmux is awfully bad, it does
meet the minimun requirements for my idea...

And there it is, a single bash script that does almost what I want.  (Meta key
combos have not been implemented yet)  Though it is still at alpha quality, I
am pretty satisfied now.


## Usage

Put the `keylogger` file somewhere on your computer, preferably an empty
directory since it will automatically generate a log file `keylogger.log` at
the same place.  Or you can clone this repository with git:

    git clone https://github.com/concise/tmux-keylogger

After you get the script. Let's say, for example, you are in a tmux session and
the executable `keylogger` file is right under current working directory.  When
you want to start logging keystrokes, just type:

    ./keylogger start

and the keys you type will be displayed in the status bar.  Perhaps a
`keylogger stop` command will be useful, but for now I just throw away the tmux
session and start a new one when I really don't want to log any more.


## Developer Notes

- This script requires some dependancies outside GNU bash: `tmux`, `dirname`,
  `tail`, and `xxd`.

- The command `./keylogger start` changes bindings of the single letter
  key so that each of these type of keystrokes can be logged.

- One log file will be created in the same directory with this script.

- When you copy and paste a large chunk of text, it will not work properly.
  Same for the case that you type too fast...  Though it is not a big issue for
  me since when I use this keylogger I am demonstrating some cmdline stuff to
  others and I have to prevent me from typing too fast...

- This script is not well tested under various circumstances.
  Maybe it might break something but I haven't noticed

- Currently only one-byte ASCII keystrokes are
  supported, because most of the time we are entering
  these characters and it's pretty to handle in tmux.

  Other keystrokes like the meta keys (e.g. `M-b`) will not
  be logged if you do not press the `^[` key separately.

- My `l_log_update_viewk` function is slow.  It may take up to 100 ms every
  time when it wants to update the status bar...

  There are many possible ways to improve performance.  We can batch a
  series of status redraw tasks and execute them all together.  We can
  even spawn a "server" process that sits in the background with a
  minimal memory footprint maintaining the last N typed keystrokes
  instead of writing to the filesystem, though disk I/O should not be the
  problem in modern machines.  But after all, I just want to do a quick
  POC and this version already works for me.

- The very first quick hack version I approach this idea was done in
  Python.  Although if I do it all in Python, the number of lines I guess
  should be still about the same (2x ~ 3x lines needed for Bash) but the
  amount of time spent on Bash, without any useful list, number, or
  string data types are insane.  And the final result should take me 10x
  ~ 20x more time, in contrast to utilizing a good scripting language.

  Yet I just (stupidly) wanted to see if we can do these work with such a
  limited tool by trying to only use bash builtins...  And suddenly when
  I recalled that in Bash we cannot have a string with a null 0x00
  character, after I wrote a trivial and simple `log-byte-to-a-file`
  function, my mind was blown...

  Then I went back to my old friend called `xxd`.

  After all, when writing a shell script, it will be ridiculous to not
  utilize all the external tools already in your `$PATH`, and it makes no
  sense to write higher level code with a language that does not have a
  proper implementation for list, lambda, string, number...  But going in
  the reverse direction is pretty fun!
