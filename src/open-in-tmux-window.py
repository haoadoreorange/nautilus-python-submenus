# Modified for tmux from https://github.com/harry-cpp/code-nautilus
# 
# Place me in ~/.local/share/nautilus-python/extensions/,
# ensure you have python-nautilus package, restart Nautilus, and enjoy :)

from gi import require_version
require_version('Gtk', '3.0')
require_version('Nautilus', '3.0')
from gi.repository import Nautilus, GObject
from subprocess import call
import os

# path to vscode
TMUX = 'tmux'

# what name do you want to see in the context menu?
TMUXNAME = 'tmux'

class TmuxExtension(GObject.GObject, Nautilus.MenuProvider):

    def launch_tmux(self, menu, dirs):
        safepaths = ''
        args = ''

        for dir in dirs:
            dirpath = dir.get_location().get_path()
            safepath = '"' + dirpath + '" '
            call(TMUX + ' new-window -c ' + safepath, shell=True)

    def get_file_items(self, window, dirs):
        no_files_selected = True
        for dir in dirs:
            dirpath = dir.get_location().get_path()
            if not os.path.isdir(dirpath) or not os.path.exists(dirpath):
                no_files_selected = False
                break


        if no_files_selected:
            item = Nautilus.MenuItem(
                name='TmuxOpen',
                label='Open in new ' + TMUXNAME + ' window',
                tip='Opens new ' + TMUX + ' windows to the selected folders'
            )
            item.connect('activate', self.launch_tmux, dirs)
            return [item]
