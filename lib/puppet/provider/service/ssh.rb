unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative '../../type/transport'
require_relative '../../../puppet_x/puppetlabs/transport'
require_relative '../../../puppet_x/puppetlabs/transport/ssh'

Puppet::Type.type(:service).provide(:ssh) do
  include PuppetX::Puppetlabs::Transport

  def self.instances
    []
  end

  def initd_cmd
    "/etc/init.d/#{resource[:name]}"
  end

  def pattern
    resource[:pattern] || '[started|running]$'
  end

  def status
    cmd = resource[:status] || "#{initd_cmd} status"

    result = transport.exec!("#{cmd}; echo $?").split("\n").last

    if result == '0'
      :running
    else
      :stopped
    end
  end

  def restart
    cmd = resource[:restart] || "#{initd_cmd} restart"
    transport.exec!(cmd)
  end

  def start
    cmd = resource[:start] || "#{initd_cmd} start"
    transport.exec!(cmd)
  end

  def stop
    cmd = resource[:stop] || "#{initd_cmd} stop"
    transport.exec!(cmd)
  end
end
