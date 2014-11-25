#!/usr/bin/python
# coding: utf-8
"""
    add %magic for memory_profiler extension
"""
__author__ = 'Henning Dickten'

try:
    import memory_profiler
except ImportError:
    pass


def load_ipython_extension(ip):
    ip.define_magic('memit', memory_profiler.magic_memit)
    ip.define_magic('mprun', memory_profiler.magic_mprun)


if __name__ == '__main__':
    pass
