# maintain-samplerr-data

This project aim at making the most fine-grained data stored by samplerr
available easily without being annoyed with coarse data.

![Illustration of an uptime metric before and after using maintain-samplerr-aliases](https://raw.githubusercontent.com/opus-codium/maintain-samplerr-aliases/master/doc/images/problem-solved.gif)

## Running maintain-samplerr-data

### Basics

The `maintain-samplerr-data` command needs 3 arguemnts:

1. The number of daily indices to maintain;
2. The number of monthly indices to maintain;
3. The number of yearly indices to maintain.

These values should match the TTL configured in [sampler's
`archives`](https://github.com/ccin2p3/samplerr#down-archives--children) for
purging and rotation.  For example, if sampler's `archives` is configured as

```clojure
(def archives     [{:tf "YYYY.MM.dd" :step (t/seconds 20) :ttl   (t/days 3) :cfunc cfunc}
                   {:tf "YYYY.MM"    :step (t/minutes 10) :ttl (t/months 2) :cfunc cfunc}
		   {:tf "YYYY"       :step    (t/hours 1) :ttl (t/years 10) :cfunc cfunc}])
```

the equivalent maintain-samplerr-data call-sequence is:

```
maintain-samplerr-data 3 2 10
```

Because maintain-samplerr-data will remove outdated indices and update aliases,
the configuration of samplerr's purge (`(purge)`, `(periodically-purge)`) and
rotation (`rotate`, `periodically-rotate`) can be removed from your
configuration.

### Icing

The rotation should happen on day change in Coordinated Universal Time (UTC).
Using `cron(1)` may not be suited because the system time zone may be changed
and daylight saving might happen.  Relying on systemd's timers is an elegant
way of circumventing this issue:

```ini
[Unit]
Description=Manage samplerr data

[Timer]
OnCalendar=*-*-* 00:00:20 UTC

[Install]
WantedBy=timers.target
```

Beware that the current day index must exist for maintain-samplerr-data to
work correctly, hense the OnCalendar schedules running the script 20 seconds
after the day change to be sure that samplerr has already created the index.
