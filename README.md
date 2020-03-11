# cd++
A bash replacement for directory changing tools, with added event hooks

Sometimes we find ourselves wanting to automate something small in a project. Something totally not worth 
setting up a build system for. Something that could be accomplished by a few lines executed when you 
enter/exit a directory. 

You could do something low-level and super fancy like setting something to run with `inotify` or 
something convoluted with `cron`, but that probably isn't going to be easy, and isn't exactly what you would 
call "portable".

This fills that void by allowing you to automate whatever you want just be creating a few basic `bash`
-based scripts.

## How to install
1. Download the repository, however you like to normally do so. There isn't any special installation to do.
2. Set up an alias that `source`s the script, preferably in your .bash_profile (or whatever your shell's 
equivalent is), specifying the type of directory change operation to do (more on that below).
3. You're done with setup! Now you can use it whenever you like!

## How it works
While handy, the script itself is pretty simple. The first thing you need to do is "install" the script 
(instructions above). Once you've done that, you'll need to create the script files that will be executed 
as directory change event hooks. At the present time, these are `onenter.cd` and `onexit.cd`, which are 
pretty self explanatory. Note the `.cd` extenstions, as opposed to `.sh`. These were chosen to minimize 
possible collisions with other scripts that may serve more integral purposes. These names may be changed 
at any time by editing `plus.sh`, and adjusting the `cdpp_onenter` and/or `cdpp_onexit` variables 
accordingly. When the script is used to change directories, it looks for if these files exist, and 
`source`s them.

## Usage
Now this has been pretty simple up to this point, but there are some basic usage notes to be aware of. 
As most people who have tried to "rewrite" `cd` can probably tell you, if you call your function/script 
`cd`, it will turn into infinite recursive hell without a little finesse. That's not an issue with 
this script. If you provide the `-o` flag, this indicates you are overriding the builtin and you can call 
your alias whatever you want.

Further information on some design suggestions and useful tidbits are in the comments at the top of the 
script. Reading the source file is highly encouraged, as there is no help text at this time (and sourcing 
code you aren't familiar with is a super bad idea).

### Tips
Given it's scripted nature, any functions cd++ provides are extremely slow compared to their built-in 
counterparts. This slowdown, while signficant, is largely unnoticable for command-line work and will be 
dwarfed by any hook scripts that are run, but it could matter in a time-sensitve script, especially one 
that does a lot of directory-hopping.

If you introduce variables or functions in `onenter.cd`, it's prudent to unset them or undo any changes in 
`onexit.cd`, especially if they apply strictly to that directory and its children. This is to reduce 
inconvenient collisions with other programs on the computer. 

A handy way to do this is to prefix everything in a certain script with a specific string, then run these 
two commands in `onexit.cd`:
```
unset ${!<prefix>@}
unset -f $(compgen -A function <prefix>) 
```
where `<prefix>` is whatever prefix you use.

### Options
At the present moment, there are 3 options for changing directories:
* cd
* push
* pop

which correspond to `cd`, `pushd`, and `popd`, respectively. Note that you need to use these options, 
and not the acutal command name when you provide the method argument.

### Example
In .bash_profile:
```
# Creates alias `cd`
# Note the -o flag, since we are overriding the existing cd
alias cd='/<path>/<to>/plus.sh -o cd'

# Creates option for `pushd`
# Change push to pop for `popd`
alias push='/<path>/<to>/plus.sh push'
```

# WARNING
This hopefully occured to you already, but this script can do some nasty damage if you're not careful. As 
a precaution, **NEVER** run this with `sudo` or as root or use a script which requires either, and never 
ever, under any circumstances, use this to run code that you don't know, understand, or trust.

```
THE AUTHOR OF THE PROGRAM KNOWN AS cdplusplus OR cd++ (HEREAFTER "THE SCRIPT") ASSUMES NO LIABILITY 
FOR ANY DAMAGES OR LOSSES CAUSED BY USAGE OF THE SCRIPT.
```

## Future ideas
If there is enough of a reason to do so, these are some ideas that may be added at later dates:
* Provide hook filenames as arguments, allowing multiple indpendent versions of hooks
* Add more directory changing options (don't know what they would be at this moment)
