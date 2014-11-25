#!/usr/bin/python
# coding: utf-8
"""
    add %magic for line_profiler extension
"""
__author__ = 'Henning Dickten'

try:
    import line_profiler
except ImportError:
    pass
else:
    def load_ipython_extension(ip):
        ip.define_magic('lprun', line_profiler.magic_lprun)


if __name__ == '__main__':
    pass
