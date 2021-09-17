local tag(name) = {
  [name]: {
    label: name
  }
};

local categorize(mapFunction, arr, children = []) = {
  [std.strReplace(tag, '.', '_')]: {
    hosts: std.map(
      function(host) host.label,
      std.filter(
        function(host) (if std.isArray(mapFunction(host)) then std.member(mapFunction(host), tag) else mapFunction(host) == tag),
        arr
      )
    ),
    children: children
  } for tag in std.set(std.flatMap(mapFunction, arr))
};

local newHost(id, os, arch, provider, tags=[],) = {
  id: id,
  os: os,
  arch: arch,
  provider: provider,
  tags: tags,
  label: "%s-%s-%s" % [self.id, self.os.label, self.arch.label],
};

{
  newHost:: newHost,
  providers::
    tag("macstadium")
  + tag("azure"),
  archs::
    tag("x86_64")
  + tag("x86")
  + tag("arm64")
  + tag("arm32"),
  os:: {
    macos(version):: {
      family: "macos",
      version: version,
      label: "%s%s" % [self.family, self.version]
    },
    windows(version):: {
      family: "windows",
      version: version,
      label: "%s-%s" % [self.family, self.version]
    },
  },

  inventory(hosts):: {
    _meta: {
      hostvars: {
        [host.label]: {
          cbi_hostid: host.id,
          cbi_provider: host.provider.label,
          cbi_os: host.os.label,
          cbi_arch: host.arch.label,
          cbi_tags: host.tags,
        } for host in hosts
      },
    },
    all: {
      children: [
        "ungrouped"
      ]
    },
  }
  + categorize(function(host) [host.provider.label], hosts)
  + categorize(function(host) [host.arch.label], hosts)
  + categorize(function(host) [host.os.family], hosts)
  + categorize(function(host) [host.os.label], hosts)
  + categorize(function(host) host.tags, hosts)
}