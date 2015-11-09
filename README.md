Eru load balance
================

## Install

1. [Openresty](http://openresty.org)
2. [ngx_http_dyups_module](https://github.com/yzprofile/ngx_http_dyups_module)

## Feature

1. Dynamically add/remove/update backend (by ngx_http_dyups_module, part of [tengine](http://tengine.taobao.org/)).
2. Use redis to set servernames.
3. Calcuate upstream status (total response, avg response time, response code count).

## Configuration

1. Modify config.lua to set redis host and port.
2. Install openresty with ngx_http_dyups_module.
3. Copy and modify conf/dev.conf as you wish.
4. Start and enjoy.

We will offer dockerfile ASAP.

## API

1. Add servername.

```
http PUT :8080/domain backend=aaa name=vbox
```

2. Delete servername.

```
http DELETE :8080/domain name=vbox
```

3. Add/Update a backend. if it not exists, the module will create it automatically.

```
http PUT :8080/upstreams/update backend=aaa servers:='["server 127.0.0.1:5000 weight=2;", "server 127.0.0.1:4000;"]'
```

4. Delete a backend.

```
http DELETE :8080/upstreams/delete backend=aaa
```

5. Show backends detail.

```
http :8080/upstreams/detail
```

6. Show upstream response detail by domain.

```
http :8080/backend/status?host=domain
```

7. Show servernames list.

```
http :8080/domain
```
