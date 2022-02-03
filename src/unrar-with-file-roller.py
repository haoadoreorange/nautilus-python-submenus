from gi import require_version
require_version('Gtk', '3.0')
require_version('Nautilus', '3.0')
from gi.repository import Nautilus, GObject
from subprocess import Popen
import os

# path to file-roller
FILE_ROLLER = 'file-roller'

class UnrarExtension(GObject.GObject, Nautilus.MenuProvider):

    def unrar_here(self, menu, filepath):
        Popen([FILE_ROLLER, '-h', filepath])
        
    def unrar_to(self, menu, filepath):
        Popen([FILE_ROLLER, '-f', filepath])

    def get_file_items(self, window, files):
        if len(files) == 1:
            filepath = files[0].get_location().get_path()
            if os.path.splitext(filepath)[1] == '.rar':
                item1 = Nautilus.MenuItem(
                    name='UnrarHere',
                    label='Unrar Here',
                    tip='Unrar in the current directory'
                )
                item1.connect('activate', self.unrar_here, filepath)
                item2 = Nautilus.MenuItem(
                    name='UnrarTo',
                    label='Unrar to',
                    tip='Unrar to a chosen directory'
                )
                item2.connect('activate', self.unrar_to, filepath)
                return [item1, item2]
            return None 
        return None 

    def get_background_items(self, window, file_):
        return None
