from typing import List  # noqa: F401
import os
import subprocess
# from os import path

from libqtile import bar, layout, widget, hook, qtile #backend
from libqtile.config import Click, Drag, Group, ScratchPad, DropDown, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"
terminal = "ghostty"

keys = [
# Open rofi
    # Key([mod], "end", lazy.spawn('rofi -show drun -show-icons')),
    Key([mod], "end", lazy.spawn('rofi -show drun -theme ~/.config/waybar/rofi/Launcher.rasi')),
    Key([mod], "d", lazy.spawn('discord')),
    Key([mod], "s", lazy.spawn('steam')),
# Open terminal
    Key([mod], "Return", lazy.spawn(terminal)),
# Qtile System Actions
    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "x", lazy.shutdown()),
    Key([mod, "shift"], "b", lazy.widget['battery'].charge_to_full()),
    Key([mod, "control"], "b", lazy.widget['battery'].charge_dynamically()),
# Active Window Actions
    Key([mod], "f", lazy.window.toggle_fullscreen()),
    Key([mod], "q", lazy.window.kill()),
    Key([mod, "control"], "h",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete()
        ),
    Key([mod, "control"], "Right",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete()
        ),
    Key([mod, "control"], "l",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add()
        ),
    Key([mod, "control"], "Left",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add()
        ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster()
        ),
    Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster()
        ),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster()
        ),
    Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster()
        ),

    Key([mod], "Up", lazy.layout.up()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Right", lazy.layout.right()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),

# Qtile Layout Actions
    Key([mod], "r", lazy.layout.reset()),
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod, "shift"], "f", lazy.layout.flip()),
    Key([mod, "shift"], "space", lazy.window.toggle_floating()),

# Move windows around MonadTall/MonadWide Layouts
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Left", lazy.layout.swap_left()),
    Key([mod, "shift"], "Right", lazy.layout.swap_right()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "h", lazy.layout.swap_left()),
    Key([mod, "shift"], "l", lazy.layout.swap_right()),
    
# Switch focus to specific monitor (out of three)
    Key([mod], "i", lazy.to_screen(0)),
    Key([mod], "o", lazy.to_screen(1)),

# Switch focus of monitors
    Key([mod], "period", lazy.next_screen()),
    Key([mod], "comma", lazy.prev_screen()),

# This is a screenshot test
    Key([mod], 'Print', lazy.spawn("flameshot gui"), desc="Screenshot tool"),
    Key([mod], "P", lazy.spawn("flameshot full"), desc="Screenshot tool"),
]

# Create labels for groups and assign them a default layout.
groups = []


group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

group_layouts = ["monadtall", "monadwide", "stack", "monadtall", "monadtall", "max", "monadtall", "monadtall", "max", "monadtall"]

# Add group names, labels, and default layouts to the groups object.
for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))

# Add group specific keybindings
for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc="Mod + number to move to that group."),
        Key(["mod1"], "Tab", lazy.screen.next_group(), desc="Move to next group."),
        Key(["mod1", "shift"], "Tab", lazy.screen.prev_group(), desc="Move to previous group."),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name), desc="Move focused window to new group."),
    ])

# Define scratchpads
groups.append(ScratchPad("scratchpad", [
    DropDown("term", "ghostty --class=scratch", width=0.6, height=0.7, x=0.2, y=0.1, opacity=1),
    DropDown("term2", "ghostty --class=scratch", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),
    DropDown("kew", "ghostty --class=kew -e kew", width=0.8, height=0.8, x=0.1, y=0.1, opacity=0.9),
    DropDown("ytop", "ghostty --class=btop -e btop", width=0.8, height=0.8, x=0.1, y=0.1, opacity=0.9),
    DropDown("tut", "ghostty --class=tut -e tut", width=0.8, height=0.8, x=0.1, y=0.1, opacity=0.9),

]))

# Scratchpad keybindings
keys.extend([
    Key([mod], "n", lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([mod], "c", lazy.group['scratchpad'].dropdown_toggle('kew')),
    Key([mod], "v", lazy.group['scratchpad'].dropdown_toggle('btop')),
    Key([mod], "z", lazy.group['scratchpad'].dropdown_toggle('tut')),
    Key([mod, "shift"], "n", lazy.group['scratchpad'].dropdown_toggle('term2')),
])

colors = [
 ["#1E1E2E", "#1E1E2E"],  # 0 Deep Black
 ["#D9E0EE", "#D9E0EE"],  # 1 Soft gray/white
 ["#45475a", "#45475a"],  # 2 An actual gray
 ["#F28FAD", "#F28FAD"],  # 3 Salmon like soft red
 ["#ABE9B3", "#ABE9B3"],  # 4 Green
 ["#FAE3B0", "#FAE3B0"],  # 5 Soft yellow
 ["#96CDFB", "#96CDFB"],  # 6 baby teal
 ["#988BA2", "#988BA2"],  # 7 lighter gray
 ["#96CDFB", "#96CDFB"],  # 8 baby teal again, idk why
 ["#988BA2", "#988BA2"],  # 9 lighter gray again
 ["#DDB6F2", "#DDB6F2"],  # 10 soft magenta
 ["#c6a0f6", "#c6a0f6"],  # 11 mauve
 ["#96CDFB", "#96CDFB"],  # 12 teal again
 ["#f5a97f", "#f5a97f"],  # 13 Peach
 ["#F5C2E7", "#F5C2E7"],  # 14 
 ["#D9E0EE", "#D9E0EE"]   # 15
        ]
# Define layouts and layout themes
layout_theme = {
        "margin":20,
        "border_width": 5,
        "border_focus": colors[4],
        "border_normal": colors[0]
    }

layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.MonadThreeCol(**layout_theme),
    layout.Floating(**layout_theme),
    layout.Max(**layout_theme)
]

# Mouse callback functions
def launch_menu():
    qtile.cmd_spawn("rofi -show drun -show-icons")


def open_rofi():
    qtile.cmd_spawn("rofi -show drun -show-icons")


# Define Widgets
widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize = 13,
    padding = 3,
    background=colors[0]
)

extension_defaults = widget_defaults.copy()

def init_widgets_list(monitor_num):
    widgets_list = [
                widget.TextBox(
                   text=" 󱄅 ", 
                    mouse_callbacks={"Button1": open_rofi},
                    fontsize=20,
                    foreground=colors[6],
                    background=colors[0],
                    margin=4,
                    padding=3,
                ),
                widget.Spacer(
                    length=1,
                    background=colors[0],
                    # **slash_powerlineLeft,
                ),
                widget.GroupBox(
                font="JetBrainsMono Nerd Font Mono",
                fontsize=20,
                padding_x=5,
                padding_y=5,
                rounded=True,
                center_aligned=True,
                disable_drag=True,
                borderwidth=3,
                highlight_method="line",
                hide_unused = True,
                active=colors[7],
                inactive=colors[1],
                highlight_color=colors[0],
                this_current_screen_border=colors[4],
                this_screen_border=colors[7],
                other_screen_border=colors[1],
                other_current_screen_border=colors[3],
                background=colors[0],
                foreground=colors[3],
                # **slash_powerlineLeft,
            ),
            widget.TaskList(
                background=colors[0],
                foreground=colors[1],
                borderwidth=1,
                spacing=5,
            ),
             widget.Spacer(
                background=colors[0],
            ),
            
            widget.Spacer(
                length=1,
                background=colors[0],
            ),
            widget.Mpris2(
                 background=colors[0],
                 foreground=colors[6],
                 # playing_text='(track)',
                 name='kew',
                 # objname=
                 padding=5,
            ),
            # widget.Battery(
            #     background=colors[3],
            #     foreground=colors[0],
            #     padding=5,
            # ),
            widget.CPU(
                    padding=5,
                    format="  {freq_current}GHz {load_percent}%",
                    foreground=colors[0],
                    background=colors[13],
                    # **slash_powerlineRight,
                ),
            widget.PulseVolume(
                    fmt="󰕾 {}",
                    foreground=colors[0],
                    background=colors[5],
                    padding=5,
                    # **slash_powerlineRight,
                ),
            widget.Memory(
                    padding=5,
                    format="󰈀 {MemUsed:.0f}{mm}",
                    background=colors[4],
                    foreground=colors[0],
                    # **slash_powerlineRight,
                ),
            widget.Clock(
                    padding=5,
                    format="  %a %d %b %H:%M:%S",
                    foreground=colors[0],
                    background=colors[6],
                    # **slash_powerlineRight,
                ),
            widget.Systray(
                    foreground=colors[0],
                    background=colors[11],
                    padding=10,
                    # **slash_powerlineRight,
                ),
            widget.CurrentLayoutIcon(
                    padding=5,
                    scale=0.5,
                    background=colors[11],
                ),
            ]

    return widgets_list

def init_secondary_widgets_list(monitor_num):
    secondary_widgets_list = init_widgets_list(monitor_num)
    del secondary_widgets_list[11]
    return secondary_widgets_list

widgets_list = init_widgets_list("1")
secondary_widgets_list = init_secondary_widgets_list("2")

screens = [
    Screen(top=bar.Bar(widgets=widgets_list, size=30, background=colors[0], margin=6),),
    Screen(top=bar.Bar(widgets=secondary_widgets_list, size=30, background=colors[0], margin=6),),
    ]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

@hook.subscribe.startup_once
def autostart():
   home = os.path.expanduser('~/.config/qtile/autostart.sh')
   subprocess.run([home])

dgroups_key_binder = None
dgroups_app_rules = []  # type: List:
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
floating_layout = layout.Floating(float_rules=[
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
    Match(title='FINAL FANTASY XIV'),
], fullscreen_border_width = 0, border_width = 0)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

auto_minimize = True
wmname = "Winder Manajer"
