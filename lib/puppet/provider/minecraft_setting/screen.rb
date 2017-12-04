require 'json'
require 'timeout'

Puppet::Type.type(:minecraft_setting).provide(:screen) do
  def value
    # If the file does not currently exist, assume it will be empty. Do not wait for this file to be created in case we are in no-op mode
    return [] unless File.exist? resource[:filename]
    JSON.load(File.new(resource[:filename])).map { |o| o[resource[:id_property]] }
  end

  def value=(newvalue)
    # Wait for the file to exist before accessing its value in case Minecraft is still starting up.
    wait_until_exists!
    current = value
    (current - newvalue).each do |to_remove|
      Puppet.debug "Need to remove #{to_remove}"
      screencmd sprintf(resource[:remove_command], to_remove)
    end
    (newvalue - current).each do |to_add|
      Puppet.debug "Need to add #{to_add}"
      screencmd sprintf(resource[:add_command], to_add)
    end
  end

  private
  def screencmd(cmd)
    execute(['screen', '-p', '0', '-S', resource[:instance], '-X', 'eval', %Q(stuff "#{cmd}"\\015)],
	    failonfail: true, uid: resource[:user])
  end

  def wait_until_exists!
    Timeout.timeout(60) do
      until File.exist? resource[:filename]
        Puppet.info "#{resource[:filename]} does not yet exist, waiting for Minecraft to create it..."
        sleep 5
      end
    end
  rescue Timeout::Error
    raise Puppet::Error, "#{resource[:filename]} does not exist after 60 seconds, cannot manage settings"
  end
end
