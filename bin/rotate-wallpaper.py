#!/usr/bin/env python3

__author__ = "Naoya Inada <naoina@kuune.org>"

__all__ = [
        ]

import logging
import os
import subprocess
import sys
import time
import random

from argparse import ArgumentParser

logging.basicConfig(format='%(message)s')
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

SETROOT = ["Esetroot", "-fit"]


def daemonize():
    if os.fork() > 0:
        os._exit(0)
    os.setsid()
    if os.fork() > 0:
        os._exit(0)
    # os.chdir("/")
    os.umask(0)
    sys.stdin.close()
    sys.stdout.close()
    sys.stderr.close()


def takearg():
    parser = ArgumentParser()
    parser.add_argument("directory", metavar="DIR", action="store",
            type=os.path.expanduser, help="images contains directory")
    parser.add_argument("-m", "--interval", metavar="MIN", action="store",
            type=int, default=10, help="rotate interval minutes")
    parser.add_argument('-n', '--nodaemon', action='store_true',
            help="do not daemonize")
    parser.add_argument('-d', '--debug', action='store_true',
            help="print the debug output")
    args = parser.parse_args()
    return args


def rotate(directory, interval):
    directory = os.path.abspath(directory)
    logger.debug("search directory is %s", directory)
    images = os.listdir(directory)
    random.shuffle(images)
    sleeptime = interval * 60
    logger.debug("sleep time is %s minutes", sleeptime)

    for img in images:
        logger.debug("switch to %s", img)
        cmd = SETROOT + [os.path.join(directory, img)]
        subprocess.call(cmd)
        time.sleep(sleeptime)
        cur_images = os.listdir(directory)
        images_len = len(images)
        cur_images_len = len(cur_images)
        if images_len == cur_images_len:
            continue
        if images_len < cur_images_len: # add
            diff = set(cur_images).difference(images)
            images.extend(diff)
        elif images_len > cur_images_len: # sub
            diff = set(images).difference(cur_images)
            for d in diff:
                images.remove(d)
        random.shuffle(images)


def main():
    args = takearg()
    if not args.nodaemon:
        daemonize()
    if args.debug:
        logger.setLevel(logging.DEBUG)

    # main loop
    while True:
        rotate(args.directory, args.interval)

if __name__ == "__main__":
    main()
