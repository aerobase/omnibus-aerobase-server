require 'mixlib/shellout'
require_relative 'helper'

class OmnibusHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def should_notify?(service_name)
    File.symlink?("/opt/unifiedpush/service/#{service_name}") && service_up?(service_name) && service_enabled?(service_name)
  end

  def not_listening?(service_name)
    File.exists?("/opt/unifiedpush/service/#{service_name}/down") && service_down?(service_name)
  end

  def service_enabled?(service_name)
    node['unifiedpush'][service_name]['enable']
  end

  def service_up?(service_name)
    success?("/opt/unifiedpush/embedded/bin/sv status #{service_name}")
  end

  def service_down?(service_name)
    failure?("/opt/unifiedpush/embedded/bin/sv status #{service_name}")
  end

  def user_exists?(username)
    success?("id -u #{username}")
  end

  def group_exists?(group)
    success?("getent group #{group}")
  end
end

