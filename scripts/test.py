#!/usr/bin/python
#coding:utf-8

import sys
import json
import requests
import httplib

def patch_send():
    old_send= httplib.HTTPConnection.send
    def new_send( self, data ):
        print data
        return old_send(self, data) #return is not necessary, but never hurts, in case the library is changed
    httplib.HTTPConnection.send= new_send

patch_send()

TEST_HOST = 'elb'
TEST_BACKEND = 'tb'

def gen_headers(addr):
    s = addr.split(':')
    if len(s) == 1:
        host = TEST_HOST
    else:
        host = '%s:%s' % (TEST_HOST, s[1])
    print host
    return {'Host': host}

def gen_url(addr):
    return 'http://%s' % addr

def test_add_domain(url, headers):
    data = {'backend': TEST_BACKEND, 'name': TEST_HOST}
    r = requests.put(url, headers=headers, data=json.dumps(data))
    assert(r.status_code == requests.codes.ok)
    req = r.json()
    assert(req['msg'] == 'ok')
    r = requests.put(url, headers=headers, data=json.dumps(data))
    assert(r.status_code == requests.codes.ok)
    req = r.json()
    assert(req['msg'] == 'exists')

def test_delete_domain(url, headers):
    data = {'name': TEST_HOST}
    r = requests.delete(url, headers=headers, data=json.dumps(data))
    req = r.json()
    assert(req['msg'] == 'ok')

def test_eru_lb(addr):
    base_url = gen_url(addr)
    headers = gen_headers(addr)
    r = requests.get(base_url, headers=headers)
    assert(r.status_code == requests.codes.not_found)

    url = '%s/domain' % base_url
    test_add_domain(url, headers)

    # test 502
    r = requests.get(base_url, headers=headers)
    assert(r.status_code == requests.codes.bad_gateway)

    # store backend after test
    url = '%s/upstream' % base_url
    test_update_upstream(url, headers)
    test_upstream_detail(url, headers)

    rs = {'8088':0, '8089':0}
    for i in range(3):
        r = requests.get(base_url, headers=headers)
        assert(r.status_code == requests.codes.ok)
        rs[r.text] = rs[r.text] + 1
    assert(rs['8088'] == 2 and rs['8089'] == 1)

    url = '%s/domain' % base_url
    test_delete_domain(url, headers)

    url = '%s/upstream' % base_url
    test_delete_upstream(url, headers)

def test_delete_upstream(url, headers):
    data = {'backend': TEST_BACKEND}
    r = requests.delete(url, headers=headers, data=json.dumps(data))
    req = r.json()
    assert(req['msg'] == 'ok')

def test_upstream_detail(url, headers):
    r = requests.get(url, headers=headers)
    req = r.json()
    assert(req.get(TEST_BACKEND))
    assert(len(req[TEST_BACKEND])== 2 )

def test_update_upstream(url, headers):
    data = {'backend': TEST_BACKEND, 'servers': [
        'server 127.0.0.1:8088 weight=2;',
        'server 127.0.0.1:8089;',
    ]}
    r = requests.put(url, headers=headers, data=json.dumps(data))
    req = r.json()
    assert(req['msg'] == 'ok')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'Wrong params'
        sys.exit(-1)
    test_eru_lb(sys.argv[1])
