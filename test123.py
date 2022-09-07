# -*- coding: utf-8 -*-
# version 11.0
"""
Created on Wed Apr 11 16:37:50 2018

@author: alexander.komarovclient
"""
import requests
import time


def main():
    r = requests.get('https://api.ipify.org?format=json')
    print(r.text)
    print(F'time now is {time.time()}')


if __name__ == "__main__":
    main()