# maintain-samplerr-aliases

This project aim at making the most fine-grained data stored by samplerr
available easily without being annoyed with coarse data.

![Illustration of an uptime metric before and after using maintain-samplerr-aliases](https://raw.githubusercontent.com/opus-codium/maintain-samplerr-aliases/master/doc/images/problem-solved.gif)

## Running maintain-samplerr-aliases

### Basics

The `maintain-samplerr-aliases` command needs 3 arguemnts:

1. The number of daily aliases to maintain;
2. The number of monthly aliases to maintain;
3. The number of yearly aliases to maintain.

These values should match the TTL configured in [sampler's
`archives`](https://github.com/ccin2p3/samplerr#down-archives--children).  For
example, if sampler's `archives` is configured as

```clojure
(def archives     [{:tf "YYYY.MM.dd" :step (t/seconds 20) :ttl   (t/days 3) :cfunc cfunc}
                   {:tf "YYYY.MM"    :step (t/minutes 10) :ttl (t/months 2) :cfunc cfunc}
		   {:tf "YYYY"       :step    (t/hours 1) :ttl (t/years 10) :cfunc cfunc}])
```

you shoudl use the following call-sequence:

```
maintain-samplerr-aliases 3 2 10
```

### Icing

The rotation should happen on day change in Coordinated Universal Time (UTC).
Using `cron(1)` may not be suited because the system time zone may be changed
and daylight saving might happen.  Relying on systemd's timers is an elegant
way of circumventing this issue:

```ini
[Unit]
Description=Manage samplerr aliases

[Timer]
OnCalendar=*-*-* 00:00:20 UTC

[Install]
WantedBy=timers.target
```

Beware that the current day index must exist for maintain-samplerr-aliases to
work correctly, hense the OnCalendar schedules running the script 20 seconds
after the day change to be sure that samplerr has already created the index.
