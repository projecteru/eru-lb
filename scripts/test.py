#!/usr/bin/python
#coding:utf-8

import sys
import requests

TEST_HOST = 'ELB'

def test_eru_lb(addr):
    s = addr.split(':')
    if len(s) == 1:
        host = 'http://%s' % TEST_HOST
    else:
        host = 'http://%s:%s' % (TEST_HOST, s[1])
    print host
    r = requests.get('http://%s' % addr)
    assert(r.status_code == requests.codes.not_found)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'Wrong params'
        sys.exit(-1)
    test_eru_lb(sys.argv[1])
