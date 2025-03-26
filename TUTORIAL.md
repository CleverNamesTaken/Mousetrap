# Tutorial

Open up two terminal windows.  In one, open up this README is Neovim, and execute the command `StartMousetrap`.  In the second terminal window, execute the command `tmux attach -t Mousetrap`

## Send keys

### Safety features.

Next, we want to execute commands.  We have a safety feature to make sure we are executing commands where we think we are. Try running the following line by putting your cursor over it in normal mode, and hitting the `H` key.

```
whoami
```

Nothing happened, because you have no terminal tags.  Try again on the line below:

```
[[ LOCAL~Admin ]]
whoami
```

This worked because we have a terminal tag above the command.  The format of a terminal tag is `[[ <WindowName>~<PaneName> ]]`. Use `CTRL+s` to insert a terminal tag while in normal mode.  This is a time stamp for where and when you executed a command.

The philosphy behind terminal tag naming is that each window is named according to the major task we want to accomplish, and the pane is named based on the subtask needed to support the major task. Do what works for you.

It is good to get into the habit of timestamping your commands with the terminal tag to make it easier to follow along and retrace your steps.

### Consumption

Use the `H` key to preserve the command you executed, either because you want it for record keeping or because you intend to modify it to re-run it.  If it is not worth preserving, then you can use the `K` key to execute the command, and then remove it from your notes.  Try this below for a survey:

```
[[ LOCAL~Admin ]]
ps aux
w
ss -punta
history
uname -a
id
```

### Save output

Often it isn't just the command that you want to preserve in your notes, but the output as well.  Mousetrap has two ways to pull back the command output after you execute a command.  The first one is to hit send the command with the `U` keystroke.

```
[[ LOCAL~Admin ]]
id
```

This works if your command output comes back relatively soon after you execute it.  Sometimes it takes longer for the output to return, but you still want it.  You also don't want to use your mouse to go grab it, because eww.  In this case, you can execute your command with `H`, and then follow up with `-` once your command output has returned.  Also notice that you may get some extra junk depending on what your `$PS1` looks like.  Feel free to modify `mousetrap/bufferOps.lua` as it pertains to your workflow.


Try using the `U` to grab the output from the sleep command below. Watch it fail, and then call it back with `-`.

```
[[ LOCAL~Admin ]] 
sleep 2 && echo here we go
```

### CTRL+C to pane

Sometimes you need to CTRL+C a process.  There are two ways to do this.  Either by sending `C-c` or, in normal mode, `<leader>c`.  Try this below:

```
[[ LOCAL~Admin ]] 
python3 -m http.server
C-c

python3 -m http.server
#Try <leader>c
```

`C-c` is the way to do it according to tmux send-keys.  `<leader>c` is a hotkey defined in `plugin/mousetrap.lua`

## Windows management

Mousetrap tries to keep you organized by allowing you to create new windows and panes without leaving your keyboard or vim session.

### Create a new window

First, let's create a new window by using the `NewWindow` command.  You can either supply the name of the new window as an argument, or get prompted for it if it is left empty.  Try both, and create two new windows called "First" and "Second".

Special characters are not permitted for window names because it has the potential to break some Mousetrap parsing on the backend.

### Navigating windows

In tmux, each window created has an index number.  In default tmux settings, this is shown near the window name.  Using Mousetrap, we can navigate to a specific window by typing our leaderkey, plus the index number.  In default neovim configuration, the leader key is `\`.  Type your leaderkey 0, leaderkey 1 and leaderkey 2 to navigate between the three windows you've created.

Mousetrap can do as many windows as tmux can, although you'll have to tweak the contents of `plugin/mousetrap.lua` to do more than 9.

## Pane management

As mentioned previously, panes are where the real work gets done whereas windows are used to organize larger tasks.

### Create a new pane

Similar to how we created a new window with the `NewWindow` command, we can create new panes with the `NewPane` command by either supplying the name as an argument, or leaving it blank and getting prompted.  In any of your three windows, create two more panes using either of these two methods.

### Navigating panes

Assuming you've navigated to your target window , you now need to focus on the specific pane you care about.  We can toggle through our panes using `leader key + space bar`.

### Re-arranging panes

Perhaps your panes are not arranged in a way that sparks joy for you.  Mousetrap allows you to do some dumb rearranging with `leader key + ctrl spacebar`.  You can do this a number for times to get your panes roughly the same size in a way that does spark joy for you. 

### Pane zoom toggle

Humans are not great at multi-tasking, so perhaps you'd rather not look at all of your panes at once.  You can toggle a zoom on your focused pane by typing `leaderkey+z`. Zoom back out by executing the same keystrokes.

### Clear a pane

When rawdogging a terminal, I like my output to remain clean, so I will frequently type `clear` or `clr`.

With Mousetrap, we can use the command `:Clear`.  This is a ton of typing though, so this command is also mapped to `Ctrl a`.  Note that this mapping removes the ability to increment the number under your cursor.  These, and other keymappings can be customized in `plugin/mousetrap.lua`.


```
[[ LOCAL~Admin ]]
ps -auxfww

    #Now hit `Ctrl a` to reset your pane
```

## Smart Features

### navigation

It is all well and good to navigate around with the leader key and space bar, but if you know where you want to go, why fumble around?  Mousetrap has some smart navigation features to let you bounce around between different panes using `Ctrl+k`.  Place your cursor on the commands below and execute them with precision by typing `K` and `CTRL k`.

```
[[ LOCAL~Admin ]]
echo LOCAL
[[ Second~Admin ]]
echo Second
[[ First~Admin ]]
echo First
[[ Second~Admin ]]
echo second time on second
[[ LOCAL~Admin ]]
echo second time on local
[[ Second~Admin ]]
echo third time on local
[[ First~Admin ]]
echo oh hey, back to first
[[ Second~Admin ]]
echo Okay, probably got the picture now
```

You might have also noticed that you got blocked if you tried to send a terminal tag.  This is by design because you probably didn't mean to do that.  If you do want to send something that looks like a terminal tag into your terminal, you can turn off the safety features by typing `MousetrapSafetyToggle`. You can add more things you think are unsafe by modifying the blockSend function in `mousetrap/sendKeys.lua`.

### Window and pane creation

Manually typing out the names of your panes and windows also seems unnecessary, especially if you are doing repetitive tasks that have predictable names.  You can also use `CTRL+k` to create new windows and panes.  Place your cursor on the lines indicated below, and try it out.

```
[[ Fourth~Bar ]]
echo put your cursor on this line and try


[[ Fourth~Foo ]]
echo put the cursor on the tag itself and try it
```

Notice that it was smart enough to add the pane to the window that already existed.

## Logging features

### Session command execution log

Any command that we execute through Mousetrap is saved in a mousetrap.csv file located wherever we define our logDir in `mousetrap/config.lua`.

Assuming you did not change the `mousetrap/config.lua` yet, the logDir is located in the `work` directory within the home directory of the user running Mousetrap. 

```
[[ LOCAL~Admin ]]
cat ~/work/mousetrap/logs/mousetrap.csv
```

It records the time the command was executed, the terminal in which it was executed, and the command that was executed.

### Individual command execution log

The csv is nice for a quick overview of the commands that you've executed. If you want the output, then we have to check out the command execution logs.

By default, they are located at ~/mousetrap/logs/$TERMINAL_TAG

```
[[ LOCAL~Admin ]]
ls ~/work/mousetrap/logs/LOCAL~Admin/
```

They are named with the Mousetrap command index number, the time of execution, the terminal tag, and the command that was executed.. If you read the yaml file, you will see that it contains the full command that was executed, the time it was executed, the target pane, the time the log was generated, and an attempt at the output.

```
[[ LOCAL~Admin ]]
cat ~/work/mousetrap/logs/LOCAL~Admin/*ps*.yaml| head -n 20
```

The output recorded in the yaml will probably be imperfect because there is no programmatic way to tell if the output has been returned entirely.  Mousetrap assumes that the output is back if the user types another sendkeys command, pulls back the output with `-`, or forces a blind update by pressing `+`.

### Blind updates

Blind updates should be used under one of two conditions:

1) You want the output to be recorded in the command execution log but do not want it sent back to your vim buffer.
2) You are about to start raw dogging and typing commands into the terminal directly rather than use Mousetrap.  This is important because of the way that a sendkeys function is used as a trigger to update the previous command execution log file.  If you forget to use the blind update, raw dog, then start using Mousetrap again, the command execution log for the command sent before raw dogging is likely to contain your raw dogging activity.

Mousetrap has a timer such that if more than a certain amount of time has passed between key presses, it will not try to update the previous command execution log. By default in `mousetrap/config.lua`, this `logTime` variable is 5 minutes.

### last command file

The last logging file is at $logDir/lastCommand.txt.  It contains what Mousetrap thinks is the output of your command.

```
[[ LOCAL~Admin ]]
id
cat ~/work/mousetrap/logs/lastCommand.txt
```

It is useful if you want to parse the output a command that you executed, but don't want to re-run the command or go into the command execution yaml file.  This log is also updated when you use either fetch output from the last command with `-` or do a blind update with `+`.

## Shutting it down

Once you are done, there isn't anything special you have to do.  Your scripted windows are saving everything all along, as is all of the Mousetrap logging.  If you do want to feel like you are doing something right, you can run the `StopMousetrap` command, which will kill your tmux session.

