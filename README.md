Eru load balance
================

## Install

1. [Openresty](http://openresty.org)
2. [ngx_http_dyups_module](https://github.com/yzprofile/ngx_http_dyups_module)

## Performance

ab test eru-agent debug pprof API

10K requests and 100 concurrency

Direct: 11904.49 requests / sec (by 24 core)
Proxy: 8100 requests / sec (by 8 core config)

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

* Add servername.

```
http PUT :8080/domain backend=aaa name=vbox
```

* Delete servername.

```
http DELETE :8080/domain name=vbox
```

* Add/Update a backend. if it not exists, the module will create it automatically.

```
http PUT :8080/upstreams backend=aaa servers:='["server 127.0.0.1:5000 weight=2;", "server 127.0.0.1:4000;"]'
```

* Delete a backend.

```
http DELETE :8080/upstreams backend=aaa
```

* Show backends detail.

```
http :8080/upstreams
```

* Show upstream response detail by domain.

```
http :8080/backend/status?host=domain
```

* Show servernames list.

```
http :8080/domain

```

* Add analysis hosts.

```
http PUT :8080/analysis hosts:='["domain1", "domain2"]'
```

* Delete analysis host

```
http DELETE :8080/analysis host=domain
```

* Get analysis hosts

```
http :8080/analysis
```
