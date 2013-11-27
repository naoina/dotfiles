#!/bin/env python3

import json
import os
import re
import time


def find_file(root, filename):
    for root, dirs, files in os.walk(root):
        for f in files:
            p = os.path.join(root, f)
            if p.endswith(filename) and os.path.isfile(p):
                return p


class NetSpeed(object):
    sysdevices = '/sys/devices'

    def __init__(self):
        self.eth0_rx_bytes = find_file(NetSpeed.sysdevices, 'eth0/statistics/rx_bytes')
        self.eth0_tx_bytes = find_file(NetSpeed.sysdevices, 'eth0/statistics/tx_bytes')
        self.wlan0_rx_bytes = find_file(NetSpeed.sysdevices, 'wlan0/statistics/rx_bytes')
        self.wlan0_tx_bytes = find_file(NetSpeed.sysdevices, 'wlan0/statistics/tx_bytes')
        self.old_time = 0
        self.old_rx = 0
        self.old_tx = 0

    def status(self):
        try:
            with open(self.eth0_rx_bytes) as eth0_rx_f, \
                    open(self.eth0_tx_bytes) as eth0_tx_f, \
                    open(self.wlan0_rx_bytes) as wlan0_rx_f, \
                    open(self.wlan0_tx_bytes) as wlan0_tx_f:
                eth0_rx = int(eth0_rx_f.readline().strip())
                eth0_tx = int(eth0_tx_f.readline().strip())
                wlan0_rx = int(wlan0_rx_f.readline().strip())
                wlan0_tx = int(wlan0_tx_f.readline().strip())
        except FileNotFoundError:
            return ' NOP '
        t = int(time.time())
        rx = eth0_rx + wlan0_rx
        tx = eth0_tx + wlan0_tx
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
                # k, v = reg.search(line).groups()
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
            {'name': 'swap', 'full_text': swap},
            {'name': 'memory', 'full_text': memory},
        ]

status_objs = (
    NetSpeed(),
    Memory(),
)


def main():
    print(input())  # skip {"version":1}
    print(input())  # skip [
    print(input())  # skip first items
    while True:
        line = input().lstrip(',')
        status = json.loads(line)
        insert = status.insert
        for status_obj in status_objs:
            for st in status_obj.status():
                insert(3, st)
        print(',' + json.dumps(status))

if __name__ == '__main__':
    main()
