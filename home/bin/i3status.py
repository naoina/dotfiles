#!/bin/env python3

import json
import os
import re
import time


class NetSpeed(object):
    sysdevices = '/sys/class'

    def __init__(self):
        self.wlp1s0_rx_bytes = NetSpeed.sysdevices + '/net/wlp1s0/statistics/rx_bytes'
        self.wlp1s0_tx_bytes = NetSpeed.sysdevices + '/net/wlp1s0/statistics/tx_bytes'
        self.old_time = 0
        self.old_rx = 0
        self.old_tx = 0

    def status(self):
        try:
            with open(self.wlp1s0_rx_bytes) as wlp1s0_rx_f, \
                    open(self.wlp1s0_tx_bytes) as wlp1s0_tx_f:
                wlp1s0_rx = int(wlp1s0_rx_f.readline().strip())
                wlp1s0_tx = int(wlp1s0_tx_f.readline().strip())
        except FileNotFoundError:
            return ' NOP '
        t = int(time.time())
        rx = wlp1s0_rx
        tx = wlp1s0_tx
        time_diff = t - self.old_time
        if time_diff > 0:
            rx_rate = (rx - self.old_rx) // time_diff
            tx_rate = (tx - self.old_tx) // time_diff
            # incoming
            rx_kib = rx_rate >> 10
            if rx_rate > 1048576:
                out = '%.1f M↓' % (rx_kib / 1024)
            else:
                out = '%s K↓' % rx_kib
            out += '  '
            # outgoing
            tx_kib = tx_rate >> 10
            if tx_kib > 1048576:
                out += '%.1f M↑' % (tx_kib / 1024)
            else:
                out += '%s K↑' % tx_kib
        else:
            out = ' ? '
        self.old_time = t
        self.old_rx = rx
        self.old_tx = tx
        return [{'name': 'net_speed', 'full_text': out}]


class Memory(object):
    regexp = re.compile(r'(.+?):\s+(\d+).*')
    meminfo = '/proc/meminfo'

    def status(self):
        mem = {}
        reg = Memory.regexp
        with open(Memory.meminfo) as f:
            for line in f:
                m = reg.search(line)
                if m is None:
                    raise RuntimeError(line)
                k, v = m.groups()
                mem[k] = int(v) // 1024
        mem['free'] = mem['MemFree'] + mem['Buffers'] + mem['Cached']
        mem['inuse'] = mem['MemTotal'] - mem['free']
        mem['swap_inuse'] = mem['SwapTotal'] - mem['SwapFree']
        memory = '%(inuse)s/%(MemTotal)s MB' % mem
        swap = '%(swap_inuse)s/%(SwapTotal)s MB' % mem
        return [
            {'name': 'memory', 'full_text': memory},
            {'name': 'swap', 'full_text': swap},
        ]

status_objs = (
    (NetSpeed(), 2),
    (Memory(), 5),
)


def main():
    print(input())  # skip {"version":1}
    print(input())  # skip [
    print(input())  # skip first items
    while True:
        line = input().lstrip(',')
        status = json.loads(line)
        insert = status.insert
        for status_obj, at in status_objs:
            for i, st in enumerate(status_obj.status()):
                insert(at + i, st)
        print(',' + json.dumps(status))

if __name__ == '__main__':
    main()
