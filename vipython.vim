function! Send2IPython() range " need the 'range' here to specify that the function is to be executed on a visually-selected range

python3 << endPython
# TODO feature list:
# * exception handling (ImportError at least)
# * logging (add config var for logging)
# * ability to connect to existing kernel
# * option to use non-jupyter-qtconsole

import vim

from jupyter_client import BlockingKernelClient
from os.path import join

V_KERNELFILE = "g:vipython_kernel_file"
V_KERNELDIR  = "g:vipython_kernel_dir"

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

    return "\n".join(lines)

def connect_and_send():
    """
    Makes a connection to the ipython kernel specified by V_KERNELFILE, gets selected
    text, and sends to the ipython kernel.

    See ipython kernel client documentation here: http://jupyter-client.readthedocs.io/en/latest/api/client.html
    """
    kc = BlockingKernelClient()
    kc.load_connection_file(join(vim.eval("{}".format(V_KERNELDIR)), vim.eval("{}".format(V_KERNELFILE))))
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

V_KERNELFILE = "g:vipython_kernel_file"
FMT = "%m%d%H%M%S" # Format for creating localtime()-based string

kernelfile = "kernel-{}.json".format(time.strftime(FMT))
subprocess.Popen("jupyter-qtconsole.exe -f {}".format(kernelfile), shell=True) # TODO: check PATH for exe first
vim.command('silent let {} = "{}"'.format(V_KERNELFILE, kernelfile))

endPython
endfunction

command! Lipy call LaunchIPython()
command! -range Sipy call Send2IPython()
