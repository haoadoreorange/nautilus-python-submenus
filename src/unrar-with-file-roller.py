from gi import require_version
require_version('Gtk', '3.0')
require_version('Nautilus', '3.0')
from gi.repository import Nautilus, GObject
from subprocess import Popen
import os

# path to file-roller
FILE_ROLLER = 'file-roller'

class UnrarExtension(GObject.GObject, Nautilus.MenuProvider):

    def unrar_here(self, menu, files):
        for file in files:
            filepath = file.get_location().get_path()
            if os.path.splitext(filepath)[1] == '.rar':
                Popen([FILE_ROLLER, '-h', filepath])
        
    def unrar_to(self, menu, files):
        for file in files:
            filepath = file.get_location().get_path()
            if os.path.splitext(filepath)[1] == '.rar':
                Popen([FILE_ROLLER, '-f', filepath])

    def get_file_items(self, window, files):
        for file in files:
            filepath = file.get_location().get_path()
            if os.path.splitext(filepath)[1] == '.rar':
                item1 = Nautilus.MenuItem(
                    name='UnrarHere',
                    label='Unrar Here',
                    tip='Unrar in the current directory'
                )
                item1.connect('activate', self.unrar_here, files)
                item2 = Nautilus.MenuItem(
                    name='UnrarTo',
                    label='Unrar to',
                    tip='Unrar to a chosen directory'
                )
                item2.connect('activate', self.unrar_to, files)
                return [item1, item2]
        return None 

    def get_background_items(self, window, file_):
        return None
