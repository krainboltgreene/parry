#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive &&
	apt-get install --no-install-recommends -y inotify-tools &&
	curl -fSL -o /tmp/elixir-otp-26.zip https://github.com/elixir-lang/elixir/releases/download/v1.15.3/elixir-otp-26.zip &&
	unzip /tmp/elixir-otp-26.zip -d /usr/bin/elixir &&
	rm /tmp/elixir-otp-26.zip