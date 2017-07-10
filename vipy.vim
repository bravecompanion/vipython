" Vim comments start with a double quote.
" Function definition is VimL. We can mix VimL and Python in
" function definition.
function! Send2IPython() range " need the 'range' here to specify that the function is to be executed on a visually-selected range

" We start the python code like the next line.

python3 << endPython
import vim

from jupyter_client import BlockingKernelClient
from os.path import join

# TODO: move these into a module & import
V_KERNELFILE = "g:vipython_kernel_file"
FMT = "%m%d%H%M%S" # Format for creating localtime()-based string
KERNELDIR = "C:/Users/kgeohaga/AppData/Roaming/jupyter/runtime" # TODO: make a vimrc variable

def get_selection():
    buf = vim.current.buffer
    lin_beg, col_beg = buf.mark('<')
    lin_end, col_end = buf.mark('>')

    lines = vim.eval('getline({}, {})'.format(lin_beg, lin_end))
    if len(lines) > 1:
        lines[0]  = lines[0][col_beg:]
        lines[-1] = lines[-1][:col_end + 1]
    else:
        lines[0] = lines[0][col_beg:col_end + 1]

    with open('lines.txt', 'w') as f:
        for line in lines:
            f.write(line + '\n')

    return "\n".join(lines)

def connect_and_send():
    """
    Makes a connection to the ipython kernel specified by V_KERNELFILE, gets selected
    text, and sends to the ipython kernel.

    See ipython kernel client documentation here: http://jupyter-client.readthedocs.io/en/latest/api/client.html
    """
    kc = BlockingKernelClient()
    kc.load_connection_file(join(KERNELDIR, vim.eval("{}".format(V_KERNELFILE))))
    kc.start_channels()
    kc.execute(get_selection())

connect_and_send()

endPython
endfunction

function! LaunchIPython()
python3 << endPython

import vim
import time
import subprocess

# TODO: move these into a module & import
V_KERNELFILE = "g:vipython_kernel_file"
FMT = "%m%d%H%M%S" # Format for creating localtime()-based string
KERNELDIR = "C:/Users/kgeohaga/AppData/Roaming/jupyter/runtime"

kernelfile = "kernel-{}.json".format(time.strftime(FMT))
subprocess.Popen("jupyter-qtconsole.exe -f {}".format(kernelfile), shell=True)
#subprocess.Popen("python C:/ProgramData/Anaconda3/Scripts/jupyter-qtconsole-script.py", shell=True)
vim.command('silent let {} = "{}"'.format(V_KERNELFILE, kernelfile))

endPython
endfunction

command! Lipy call LaunchIPython()
command! -range Sipy call Send2IPython()
