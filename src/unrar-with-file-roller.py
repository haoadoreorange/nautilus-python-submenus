from gi import require_version
require_version('Gtk', '3.0')
require_version('Nautilus', '3.0')
from gi.repository import Nautilus, GObject
from subprocess import call
import os

# path to file-roller
FILE_ROLLER = 'file-roller'

class UnrarExtension(GObject.GObject, Nautilus.MenuProvider):

    def unrar_here(self, menu, safepath):
        call(FILE_ROLLER + ' -h ' + safepath, shell=True)
        
    def unrar_to(self, menu, safepath):
        call(FILE_ROLLER + ' -f ' + safepath, shell=True) 

    def get_file_items(self, window, files):
        if len(files) == 1:
            filepath = files[0].get_location().get_path()
            if os.path.splitext(filepath)[1] == '.rar':
                safepath = '"' + filepath + '"'
                item1 = Nautilus.MenuItem(
                    name='UnrarHere',
                    label='Unrar Here',
                    tip='Unrar in the current directory'
                )
                item1.connect('activate', self.unrar_here, safepath)
                item2 = Nautilus.MenuItem(
                    name='UnrarTo',
                    label='Unrar to',
                    tip='Unrar to a chosen directory'
                )
                item2.connect('activate', self.unrar_to, safepath)
                return [item1, item2]
            return None 
        return None 

    def get_background_items(self, window, file_):
        return None
